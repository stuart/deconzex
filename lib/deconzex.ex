defmodule Deconzex.NetworkParameters do
  defstruct nwk_panid: 0,
            aps_extended_panid: 0,
            current_channel: 0,
            network_key: <<>>,
            channel_mask: []

  @type t :: %__MODULE__{}
end

defmodule Deconzex do
  use Application
  alias Deconzex.{Device, NetworkParameters}
  require Logger

  @moduledoc """
    Documentation for `Deconzex`.
  """

  @doc """
    Starts the Conbee device. Will form or join a network if the
    device connects successfully over the serial port.
  """
  @impl true
  def start(_type, _args) do
    Logger.info("Starting Deconzex App")
    resp = Deconzex.DeviceSupervisor.start_link({})

    if Device.uart_connected() do
      form_network()
    end

    resp
  end

  @doc """
    Return the firmware version and platform of the device.
  """
  @spec get_version() :: %{
          major_version: integer,
          minor_version: integer,
          platform: atom
        }
  def get_version do
    Device.read_firmware_version()
  end

  @doc """
    Returns the network parameters set on the device.
  """
  @spec get_network_parameters() :: NetworkParameters.t()
  def get_network_parameters do
    %NetworkParameters{
      nwk_panid: Device.read_parameter(:nwk_panid),
      aps_extended_panid: Device.read_parameter(:aps_extended_panid),
      current_channel: Device.read_parameter(:current_channel),
      network_key: Device.read_parameter(:network_key),
      channel_mask: Device.read_parameter(:channel_mask)
    }
  end

  @doc """
    Create or join a network. This is called by the start function so normally
    should not be needed unless changing network parameters.
  """
  @spec form_network() :: :ok | {:error, :network_state_not_reached, :net_connected}
  def form_network() do
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

    case wait_for_network_status(:net_connected) do
      :ok ->
        Logger.info("Network connected")
        :ok

      error ->
        error
    end
  end

  @doc """
    Leave any existing network.
  """
  @spec leave_network() :: :ok | {:error, :network_state_not_reached, :net_offline}
  def leave_network do
    Device.leave_network()

    case wait_for_network_status(:net_offline) do
      :ok ->
        Logger.info("Network disconnected")
        :ok

      error ->
        error
    end
  end

  @doc """
    Accept join requests sent to this device.
  """
  @spec permit_join(integer, integer) :: :ok | {:error, atom}
  def permit_join(seconds, nwk_address) do
    :ok
  end

  @doc """
    Reset the device. Uses the watchdog timer. The device will take a couple of
    seconds to stop and will then restart.
  """
  @spec reset :: :ok
  def reset do
    :ok
  end

  def lqi do
  end

  def routing_table do
  end

  def node_descriptor(addr) do
  end

  @doc """
    Send a Zigbee message to the specified address, endpoint, profile and cluster.
    The asdu should be a binary formatted correctly by a higher level protocol.
  """
  def write(address, endpoint, profile_id, cluster_id, source_endpoint, asdu, radius \\ 0) do
  end

  @doc """
  Set a process as a listener of messages recieved by the device on the specified endpoint number.

  """
  @spec listen(integer, pid) :: :ok
  def listen(endpoint, listener) do
    :ok
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
