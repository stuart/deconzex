defmodule Deconzex.Parameters do
  use Bitwise

  @moduledoc """
    Conversion rules for the various network parameters.
  """

  @type t() ::
          :mac_address
          | :nwk_panid
          | :nwk_address
          | :nwk_extended_panid
          | :aps_designated_coordinator
          | :channel_mask
          | :aps_extended_panid
          | :trust_center_address
          | :security_mode
          | :predifined_nwk_panid
          | :network_key
          | :link_key
          | :current_channel
          | :protocol_version
          | :nwk_update_id
          | :watchdog_ttl
          | :nwk_frame_counter
          | :app_zdp_response_handling
          | :test

  @parameter_ids %{
    mac_address: 0x01,
    nwk_panid: 0x05,
    nwk_address: 0x07,
    nwk_extended_panid: 0x08,
    aps_designated_coordinator: 0x09,
    channel_mask: 0x0A,
    aps_extended_panid: 0x0B,
    trust_center_address: 0x0E,
    security_mode: 0x10,
    predifined_nwk_panid: 0x15,
    network_key: 0x18,
    link_key: 0x19,
    current_channel: 0x1C,
    protocol_version: 0x22,
    nwk_update_id: 0x24,
    watchdog_ttl: 0x26,
    nwk_frame_counter: 0x27,
    app_zdp_response_handling: 0x28,
    test: 0x1E
  }

  @parameters %{
    0x01 => :mac_address,
    0x05 => :nwk_panid,
    0x07 => :nwk_address,
    0x08 => :nwk_extended_panid,
    0x09 => :aps_designated_coordinator,
    0x0A => :channel_mask,
    0x0B => :aps_extended_panid,
    0x0E => :trust_center_address,
    0x10 => :security_mode,
    0x15 => :predifined_nwk_panid,
    0x18 => :network_key,
    0x19 => :link_key,
    0x1C => :current_channel,
    0x22 => :protocol_version,
    0x24 => :nwk_update_id,
    0x26 => :watchdog_ttl,
    0x27 => :nwk_frame_counter,
    0x28 => :app_zdp_response_handling,
    0x1E => :test
  }

  @parameter_formats %{
    mac_address: :u64,
    nwk_panid: :u16,
    nwk_address: :u16,
    nwk_extended_panid: :u64,
    aps_designated_coordinator: :boolean,
    channel_mask: :channel_mask,
    aps_extended_panid: :u64,
    trust_center_address: :u64,
    security_mode: :u8,
    predifined_nwk_panid: :boolean,
    network_key: :key,
    link_key: :link_key,
    current_channel: :u8,
    protocol_version: :u16,
    nwk_update_id: :u8,
    watchdog_ttl: :u32,
    nwk_frame_counter: :u32,
    app_zdp_response_handling: :u16,
    test: :binary
  }

  @spec find(integer) :: t()
  def find(parameter_id) do
    Map.get(@parameters, parameter_id, :unknown)
  end

  @spec id(atom) :: integer
  def id(parameter) do
    Map.get(@parameter_ids, parameter, 0)
  end

  @spec deserialize(t(), binary) :: term
  def deserialize(parameter, value) do
    do_deserialize(Map.get(@parameter_formats, parameter), value)
  end

  @spec serialize(t(), term) :: binary
  def serialize(parameter, value) do
    do_serialize(Map.get(@parameter_formats, parameter), value)
  end

  defp do_deserialize(:u8, <<value::8>>) do
    value
  end

  defp do_deserialize(:u16, <<value::16-little>>) do
    value
  end

  defp do_deserialize(:u32, <<value::32-little>>) do
    value
  end

  defp do_deserialize(:u64, <<value::64-little>>) do
    value
  end

  defp do_deserialize(:boolean, <<0x01>>) do
    true
  end

  defp do_deserialize(:boolean, <<0x00>>) do
    false
  end

  defp do_deserialize(:key, <<_::8, value::binary>>) do
    value
  end

  defp do_deserialize(:channel_mask, <<mask::32>>) do
    Enum.reduce(26..11, [], fn channel, acc ->
      case(bsl(1, channel) &&& mask) do
        0 -> acc
        _ -> [channel | acc]
      end
    end)
  end

  defp do_deserialize(:binary, value) do
    value
  end

  defp do_deserialize(_, _) do
    {:error, :cannot_deserialize_value}
  end

  defp do_serialize(:u8, value) do
    <<value::8>>
  end

  defp do_serialize(:u16, value) do
    <<value::16-little>>
  end

  defp do_serialize(:u32, value) do
    <<value::32-little>>
  end

  defp do_serialize(:u64, value) do
    <<value::64-little>>
  end

  defp do_serialize(:boolean, true) do
    <<0x01>>
  end

  defp do_serialize(:boolean, false) do
    <<0x00>>
  end

  defp do_serialize(:key, value) do
    <<0x00>> <> value
  end

  defp do_serialize(:channel_mask, value) do
    <<Enum.reduce(value, 0, fn channel, acc -> bor(acc, channel_to_mask_bit(channel)) end)::32>>
  end

  defp do_serialize(:binary, value) do
    value
  end

  defp do_serialize(_, _) do
    {:error, :cannot_serialize_value}
  end

  defp channel_to_mask_bit(channel) when channel in 11..26 do
    bsl(1, channel)
  end

  defp channel_to_mask_bit(_) do
    0
  end
end
