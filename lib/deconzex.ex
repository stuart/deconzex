defmodule Deconzex do
  use Application
  alias Deconzex.Device
  require Logger

  @moduledoc """
  Documentation for `Deconzex`.
  """
  def start(_type, _args) do
    Logger.info("Starting Deconzex App")
    resp = Deconzex.DeviceSupervisor.start_link({})

    if Device.uart_connected() do
      form_network()
    end

    resp
  end

  def get_version do
    Device.read_firmware_version()
  end

  def get_network_parameters do
    %{
      nwk_panid: Device.read_parameter(:nwk_panid),
      aps_extended_panid: Device.read_parameter(:aps_extended_panid),
      current_channel: Device.read_parameter(:current_channel),
      network_key: Device.read_parameter(:network_key),
      channel_mask: Device.read_parameter(:channel_mask)
    }
  end

  def form_network do
    Logger.info("Forming Network")
    %{status: :success} = Device.leave_network()
    :ok = Device.write_parameter(:aps_designated_coordinator, true)

    network_config = Application.fetch_env!(:deconzex, :network)
    channel_mask = Map.get(network_config, :channel_mask, [11])

    pan_id = Map.get(network_config, :pan_id, nil)
    :ok = Device.write_parameter(:nwk_panid, pan_id)
    network_update_id = Map.get(network_config, :network_update_id)
    network_key = Map.get(network_config, :network_key)

    %{status: :success} = Device.join_network()

    wait_for_network_status(:net_connected)
    Logger.info("Network connected")
  end

  def leave_network do
    Device.leave_network()
  end

  def permit_join(seconds, nwk_address) do
  end

  def reset do
  end

  def lqi do
  end

  def routing_table do
  end

  def node_descriptor(addr) do
  end

  def write(address, endpoint, profile_id, cluster_id, source_endpoint, asdu, radius \\ 0) do
  end

  def listen(endpoint, listener) do
  end

  defp wait_for_network_status(status) do
    do_wait_for_network_status(status, 0)
  end

  defp do_wait_for_network_status(status, 10) do
    {:error, :network_state_not_reached, status}
  end

  defp do_wait_for_network_status(status, count) do
    %{network_state: network_status} = Device.device_state()

    if network_status != status do
      Process.sleep(1000)
      do_wait_for_network_status(status, count + 1)
    end

    :ok
  end
end
