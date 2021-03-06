defmodule Deconzex.Protocol do
  @moduledoc """
      Convert the serial data from Conbee devices into various
      maps of data and build frames for sending to Conbee devices.
  """
  require Logger

  alias Deconzex.Address

  defstruct command: 0, seq: 0, args: {}

  @command_device_state 0x07
  @command_change_network_state 0x08
  @command_read_parameter 0x0A
  @command_write_parameter 0x0B
  # @command_device_state_CHANGED 0x0E
  @command_version 0x0D
  @command_aps_data_request 0x12
  @command_aps_data_confirm 0x04
  @command_aps_data_indication 0x17
  # @command_MAC_POLL_INDICATION 0x1C
  # @command_MAC_BEACON_INDICATION 0x1F
  # @command_UPDATE_BOOTLOADER 0x21

  @commands %{
    0x07 => :device_state,
    0x08 => :change_network_state,
    0x0A => :read_parameter,
    0x0B => :write_parameter,
    0x0E => :device_state_changed,
    0x0D => :version,
    0x12 => :aps_data_request,
    0x04 => :aps_data_confirm,
    0x17 => :aps_data_indication,
    0x1C => :mac_poll_indication,
    0x1F => :mac_beacon_indication,
    0x21 => :update_bootloader
  }

  @statuses %{
    0x00 => :success,
    0x01 => :failure,
    0x02 => :busy,
    0x03 => :timeout,
    0x04 => :unsupported,
    0x05 => :error,
    0x06 => :no_network,
    0x07 => :invalid_value
  }

  @network_states %{
    0x00 => :net_offline,
    0x01 => :net_joining,
    0x02 => :net_connected,
    0x03 => :net_leaving
  }

  @network_state_ids %{
    net_offline: 0x00,
    net_joining: 0x01,
    net_connected: 0x02,
    net_leaving: 0x03
  }

  @spec read_firmware_version_request(integer) :: binary
  def read_firmware_version_request(seq) do
    make_frame(@command_version, seq, <<0::32>>)
  end

  @spec read_parameter_request(integer, atom) :: binary
  def read_parameter_request(seq, :network_key) do
    parameter_id = Deconzex.Parameters.id(:network_key)
    make_frame(@command_read_parameter, seq, <<0x02::16-little, parameter_id::16-little>>)
  end

  #
  # def read_parameter_request(seq, :link_key) do
  #   parameter_id = Deconzex.Parameters.id(:link_key)
  #   make_frame(@command_read_parameter, seq, <<0x02::16-little, parameter_id::16-little>>)
  # end

  def read_parameter_request(seq, parameter) do
    parameter_id = Deconzex.Parameters.id(parameter)
    make_frame(@command_read_parameter, seq, <<0x01::16-little, parameter_id::8>>)
  end

  @spec write_parameter_request(integer, atom, term) :: binary
  def write_parameter_request(seq, parameter, value) do
    parameter_id = Deconzex.Parameters.id(parameter)
    binary_value = Deconzex.Parameters.serialize(parameter, value)
    payload_len = byte_size(binary_value) + 1

    make_frame(
      @command_write_parameter,
      seq,
      <<payload_len::16-little, parameter_id::8, binary_value::binary>>
    )
  end

  @spec device_state_request(integer) :: binary
  def device_state_request(seq) do
    make_frame(@command_device_state, seq, <<0::24>>)
  end

  @spec change_network_state(integer, :net_offline | :net_joining | :net_connected | :net_leaving) ::
          binary
  def change_network_state(seq, network_state) do
    network_state_id = @network_state_ids[network_state]
    make_frame(@command_change_network_state, seq, <<network_state_id::8>>)
  end

  @spec read_received_data_request(integer) :: binary
  def read_received_data_request(seq) do
    make_frame(@command_aps_data_indication, seq, <<0::16-little>>)
  end

  @spec read_received_data_request(integer, integer) :: binary
  def read_received_data_request(seq, flags) do
    make_frame(@command_aps_data_indication, seq, <<1::16-little, flags::8>>)
  end

  @spec enqueue_send_data_request(integer, Deconzex.APS.Request.t()) :: binary
  def enqueue_send_data_request(seq, %Deconzex.APS.Request{} = request) do
    enqueue_send_data_request(
      seq,
      request.request_id,
      request.destination_address,
      request.destination_endpoint,
      request.profile_id,
      request.cluster_id,
      request.source_endpoint,
      request.asdu
    )
  end

  @spec enqueue_send_data_request(
          integer,
          integer,
          Address.t(),
          integer,
          integer,
          integer,
          integer,
          binary
        ) :: binary
  def enqueue_send_data_request(
        seq,
        request_id,
        address,
        dest_endpoint,
        profile_id,
        cluster_id,
        source_endpoint,
        asdu
      ) do
    asdu_length = byte_size(asdu)

    payload_len =
      case Address.mode(address) do
        :group -> asdu_length + 14
        :nwk -> asdu_length + 15
        :ieee -> asdu_length + 21
      end

    addr = Address.serialize(address)

    payload =
      <<payload_len::16-little, request_id::8, 0x00, addr::binary, dest_endpoint::8,
        profile_id::16-little, cluster_id::16-little, source_endpoint::8, asdu_length::16-little,
        asdu::binary, 0x04, 0x00>>

    make_frame(
      @command_aps_data_request,
      seq,
      payload
    )
  end

  @spec query_send_data_request(integer) :: binary
  def query_send_data_request(seq) do
    make_frame(@command_aps_data_confirm, seq, <<0::16>>)
  end

  @spec decode(binary) ::
          [map] | {:error, :unprocessable_frame} | {:error, :invalid_frame_length, term}
  def decode(raw_frame) do
    Logger.debug("Decoding raw frame: #{inspect(raw_frame)}")

    with {:ok, frame} <- Deconzex.Crc.check_crc(raw_frame),
         {:ok, frame} <- check_length(frame),
         {:ok, header, payload} <- process(frame) do
      [Map.merge(header, decode_payload(header, payload))]
    end
  end

  defp decode_payload(
         %{command: :version, status: :success},
         <<0x00, platform_id::8, minor_version::8, major_version::8, _::binary>>
       ) do
    platform =
      case platform_id do
        0x05 -> :conbee
        0x07 -> :conbee_II
        _ -> :unknown
      end

    %{
      major_version: major_version,
      minor_version: minor_version,
      platform: platform
    }
  end

  defp decode_payload(
         %{command: :read_parameter, status: :success},
         <<_payload_len::16, parameter_id::8, value::binary>>
       ) do
    parameter = Deconzex.Parameters.find(parameter_id)

    %{
      parameter: parameter,
      value: Deconzex.Parameters.deserialize(parameter, value)
    }
  end

  defp decode_payload(
         %{command: :read_parameter, status: :unsupported},
         <<_payload_len::16, _parameter_id::8, _value::binary>>
       ) do
    %{
      parameter: :unknown,
      value: <<>>
    }
  end

  defp decode_payload(
         %{command: :read_parameter, status: :invalid_value},
         <<_payload_len::16, parameter_id::8, value::binary>>
       ) do
    parameter = Deconzex.Parameters.find(parameter_id)

    %{
      parameter: parameter,
      value: Deconzex.Parameters.deserialize(parameter, value)
    }
  end

  defp decode_payload(
         %{command: :write_parameter},
         <<1::16-little, parameter_id::8>>
       ) do
    %{parameter: Deconzex.Parameters.find(parameter_id)}
  end

  defp decode_payload(
         %{command: command},
         <<_::2, request_free_slots::1, configuration_changed::1, indication::1, confirm::1,
           network_state::2, _rest::binary>>
       )
       when command in [:device_state, :device_state_changed] do
    %{
      network_state: @network_states[network_state],
      apsde_data_flags: %{
        confirm: confirm,
        indication: indication,
        request_free_slots: request_free_slots
      },
      configuration_changed: configuration_changed
    }
  end

  defp decode_payload(
         %{command: :change_network_state},
         <<network_state::8>>
       ) do
    %{
      network_state: @network_states[network_state]
    }
  end

  defp decode_payload(
         %{command: :aps_data_indication, status: :success},
         <<_payload_len::16, _::2, request_free_slots::1, configuration_changed::1, indication::1,
           confirm::1, network_state::2, payload::binary>>
       ) do
    {destination_address, <<destination_endpoint::8, payload::binary>>} =
      Address.deserialize(payload)

    {source_address, <<source_endpoint::8, payload::binary>>} = Address.deserialize(payload)

    <<profile_id::16-little, cluster_id::16-little, asdu_length::16-little, payload::binary>> =
      payload

    asdu = :binary.part(payload, {0, asdu_length})

    <<0x00, 0x00, lqi::8, 0x00, 0x00, 0x00, 0x00, rssi::8-signed>> =
      :binary.part(payload, {byte_size(payload) - 8, 8})

    %{
      network_state: @network_states[network_state],
      apsde_data_flags: %{
        confirm: confirm,
        indication: indication,
        request_free_slots: request_free_slots
      },
      configuration_changed: configuration_changed,
      destination_address: destination_address,
      destination_endpoint: destination_endpoint,
      source_address: source_address,
      source_endpoint: source_endpoint,
      profile_id: profile_id,
      cluster_id: cluster_id,
      asdu: asdu,
      lqi: lqi,
      rssi: rssi
    }
  end

  defp decode_payload(
         %{command: :aps_data_indication, status: _},
         <<_payload_len::16, _::2, request_free_slots::1, configuration_changed::1, indication::1,
           confirm::1, network_state::2, _payload::binary>>
       ) do
    %{
      network_state: @network_states[network_state],
      apsde_data_flags: %{
        confirm: confirm,
        indication: indication,
        request_free_slots: request_free_slots
      },
      configuration_changed: configuration_changed
    }
  end

  defp decode_payload(
         %{command: :mac_poll_indication},
         <<_payload_len::16-little, payload::binary>>
       ) do
    {source_address, payload} = Address.deserialize(payload)
    <<lqi::8, payload::binary>> = payload
    <<rssi::8-signed, payload::binary>> = payload

    {lifetime, timeout} =
      if byte_size(payload) > 0 do
        <<lt::32-little, to::32-little>> = payload
        {lt, to}
      else
        {0, 0}
      end

    %{
      source_address: source_address,
      lqi: lqi,
      rssi: rssi,
      lifetime: lifetime,
      timeout: timeout
    }
  end

  defp decode_payload(
         %{command: :mac_beacon_indication},
         <<_payload_len::16-little, source_address::16-little, panid::16-little, channel::8,
           flags::8, update_id::8, data::binary>>
       ) do
    %{
      source_address: {:nwk, source_address},
      nwk_panid: panid,
      nwk_channel: channel,
      beacon_flags: flags,
      update_id: update_id,
      data: data
    }
  end

  defp decode_payload(
         %{command: :aps_data_request},
         <<_payload_len::16, _::2, request_free_slots::1, configuration_changed::1, indication::1,
           confirm::1, network_state::2, req_id::8>>
       ) do
    %{
      network_state: @network_states[network_state],
      apsde_data_flags: %{
        confirm: confirm,
        indication: indication,
        request_free_slots: request_free_slots
      },
      configuration_changed: configuration_changed,
      request_id: req_id
    }
  end

  defp decode_payload(
         %{command: :aps_data_confirm},
         <<_payload_len::16, _::2, request_free_slots::1, configuration_changed::1, indication::1,
           confirm::1, network_state::2, req_id::8, payload::binary>>
       ) do
    {destination_address, payload} = Address.deserialize(payload)

    {destination_endpoint, source_endpoint, payload} =
      if Address.mode(destination_address) == :group do
        <<source_endpoint::8, payload::binary>> = payload
        {0, source_endpoint, payload}
      else
        <<destination_endpoint::8, source_endpoint::8, payload::binary>> = payload
        {destination_endpoint, source_endpoint, payload}
      end

    <<confirm_status::8, _::binary>> = payload

    %{
      network_state: @network_states[network_state],
      apsde_data_flags: %{
        confirm: confirm,
        indication: indication,
        request_free_slots: request_free_slots
      },
      configuration_changed: configuration_changed,
      request_id: req_id,
      destination_address: destination_address,
      destination_endpoint: destination_endpoint,
      source_endpoint: source_endpoint,
      confirm_status: confirm_status
    }
  end

  defp decode_payload(_, payload) do
    %{command: :unknown, payload: payload}
  end

  defp make_frame(command_id, seq, args) do
    len = byte_size(args) + 5

    <<command_id::8, seq::8, 0x00, len::16-little, args::binary>>
    |> Deconzex.Crc.add_crc()
  end

  defp check_length(<<_cmd::8, _seq::8, _status::8, frame_len::16-little, _rest::binary>> = frame) do
    if byte_size(frame) == frame_len do
      {:ok, frame}
    else
      Logger.error("Invalid frame length: #{inspect(frame)}")
      {:error, :invalid_frame_length, %{expected: byte_size(frame), received: frame_len}}
    end
  end

  defp process(<<cmd::8, seq::8, status::8, _frame_len::16-little, payload::binary>>) do
    {:ok, %{command: @commands[cmd], seq: seq, status: @statuses[status]}, payload}
  end

  defp process(frame) do
    Logger.error("Unprocessable frame: #{inspect(frame)}")
    {:error, :unprocessable_frame}
  end
end
