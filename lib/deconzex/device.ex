defmodule Deconzex.Device do
  use GenServer
  require Logger
  alias Deconzex.{Protocol, SerialPort}

  @moduledoc """
      Controls the connection to the Conbee device, sends and recieves frames
      to and from it and forwards them to the appropriate handlers in the
      higher layers.
  """
  defstruct uart: nil, seq: 0, listeners: [], uart_connected: false

  defmacro await(do: block) do
    quote do
      receive do
        unquote(block)
      after
        Application.get_env(:deconzex, :timeout, 1000) ->
          {:error, :timeout}
      end
    end
  end

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    connect()
    {:ok, pid}
  end

  def connect do
    GenServer.cast(__MODULE__, :connect)
  end

  def get_seq() do
    GenServer.call(__MODULE__, :get_seq)
  end

  def uart_connected() do
    GenServer.call(__MODULE__, :uart_connected)
  end

  def restart() do
    GenServer.cast(__MODULE__, :restart)
  end

  def read_firmware_version do
    GenServer.cast(__MODULE__, {&Protocol.read_firmware_version_request/1, [], self()})

    await do
      %{major_version: major, minor_version: minor, platform: platform} ->
        {major, minor, platform}
    end
  end

  def read_parameter(parameter) do
    GenServer.cast(__MODULE__, {&Protocol.read_parameter_request/2, [parameter], self()})

    await do
      %{status: :success, value: value} -> value
      %{status: :invalid_value} -> {:error, :invalid_value}
      %{status: :unsupported} -> {:error, :unsupported}
    end
  end

  def write_parameter(parameter, value) do
    GenServer.cast(__MODULE__, {&Protocol.write_parameter_request/3, [parameter, value], self()})

    await do
      %{status: :success} -> :ok
      %{status: :invalid_value} -> {:error, :invalid_value}
      %{status: :unsupported} -> {:error, :unsupported}
      frame -> frame
    end
  end

  def join_network do
    GenServer.cast(__MODULE__, {&Protocol.change_network_state/2, [:net_connected], self()})

    await do
      frame -> frame
    end
  end

  def leave_network do
    GenServer.cast(__MODULE__, {&Protocol.change_network_state/2, [:net_offline], self()})

    await do
      frame -> frame
    end
  end

  def device_state do
    GenServer.cast(__MODULE__, {&Protocol.device_state_request/1, [], self()})

    await do
      frame -> frame
    end
  end

  ### Server

  @impl true
  def init([]) do
    Process.send_after(self(), :watchdog, 1000)
    {:ok, %__MODULE__{uart: :uart, seq: 0, listeners: []}}
  end

  @impl true
  def handle_call(:get_seq, _from, state) do
    {:reply, state.seq, state}
  end

  def handle_call(:uart_connected, _from, state) do
    {:reply, state.uart_connected, state}
  end

  @impl true
  def handle_cast(:connect, state) do
    {:noreply, %{state | uart_connected: SerialPort.connect(state.uart)}}
  end

  def handle_cast(
        {protocol_command, args, listener},
        %{uart: uart, seq: seq, listeners: listeners} = state
      ) do
    SerialPort.write(state.uart, apply(protocol_command, [seq | args]))

    {:noreply,
     %{state | seq: Integer.mod(seq + 1, 256), listeners: [{listener, seq} | listeners]}}
  end

  def handle_cast(:resart, state) do
    Logger.info("Restarting Conbee device.")
    write_parameter(:watchdog_ttl, 2)
    {:no_reply, state}
  end

  def handle_cast(_data, state) do
    Logger.error("Unhandled cast")
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_uart, serial_port, {:error, :eio}}, state) do
    Logger.error("Lost serial port connection to #{serial_port}")
    {:stop, :lost_connection, state}
  end

  def handle_info({:circuits_uart, _serial_port, data}, %{listeners: listeners} = state) do
    Logger.debug("Data from UART: #{inspect(data)}")
    frames = Deconzex.Protocol.decode(data)
    Logger.debug("Received frames: #{inspect(frames)}")

    unused_listeners =
      Enum.reduce(frames, listeners, fn frame, listeners -> handle_frame(frame, listeners) end)

    {:noreply, %{state | listeners: unused_listeners}}
  end

  # Keep the watchdog timer on the Conbee going.
  def handle_info(:watchdog, state) do
    Logger.debug("Resetting watchdog timer.")
    keepalive_s = Application.fetch_env!(:deconzex, :device)[:keepalive_s]

    Process.send_after(self(), :watchdog, keepalive_s * 1000)
    write_parameter(:watchdog_ttl, keepalive_s * 2)
    {:noreply, state}
  end

  defp handle_frame(%{seq: seq} = frame, listeners) do
    valid_listeners = Enum.filter(listeners, fn {_, s} -> s == seq end)
    Enum.each(valid_listeners, fn {pid, _} -> send(pid, frame) end)
    listeners -- valid_listeners
  end
end
