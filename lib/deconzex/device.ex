defmodule Deconzex.Device do
  use GenServer
  require Logger
  alias Deconzex.{Protocol, SerialPort}

  @moduledoc """
      Controls the connection to the Conbee device, sends and recieves frames
      to and from it and forwards them to the appropriate handlers in the
      higher layers.
  """
  defstruct uart: nil,
            seq: 0,
            listeners: [],
            data_listeners: [],
            uart_connected: false

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
    GenServer.call(__MODULE__, :connect)
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

  def read_firmware_version() do
    GenServer.cast(__MODULE__, {&Protocol.read_firmware_version_request/1, [], self()})

    await do
      frame -> frame
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

  def enqueue_send_data(%Deconzex.APS.Request{} = request) do
    GenServer.cast(__MODULE__, {&Protocol.enqueue_send_data_request/2, [request], self()})

    await do
      frame -> frame
    end
  end

  ### Server

  @impl true
  def init([]) do
    Process.send_after(self(), :watchdog, 1000)
    {:ok, %__MODULE__{uart: :uart, seq: 0, listeners: [], uart_connected: false}}
  end

  @impl true
  def handle_call(:connect, _from, %{uart_connected: false} = state) do
    {:reply, :ok, %{state | uart_connected: SerialPort.connect(state.uart)}}
  end

  def handle_call(:connect, _from, %{uart_connected: true} = state) do
    {:noreply, %{state | uart_connected: true}}
  end

  def handle_call(:get_seq, _from, state) do
    {:reply, state.seq, state}
  end

  def handle_call(:uart_connected, _from, state) do
    {:reply, state.uart_connected, state}
  end

  @impl true
  def handle_cast(
        {protocol_command, args, listener},
        %{uart_connected: true} = state
      ) do
    SerialPort.write(state.uart, apply(protocol_command, [state.seq | args]))

    {:noreply,
     %{
       state
       | seq: Integer.mod(state.seq + 1, 256),
         listeners: [{listener, state.seq} | state.listeners]
     }}
  end

  def handle_cast(
        {protocol_command, args, listener},
        %{uart_connected: false} = state
      ) do
    connection = SerialPort.connect(state.uart)

    if connection do
      SerialPort.write(state.uart, apply(protocol_command, [state.seq | args]))
    end

    {:noreply,
     %{
       state
       | seq: Integer.mod(state.seq + 1, 256),
         listeners: [{listener, state.seq} | state.listeners],
         uart_connected: connection
     }}
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

  def handle_info({:circuits_uart, _serial_port, data}, state) do
    Logger.debug("Data from UART: #{inspect(data)}")
    frames = Deconzex.Protocol.decode(data)
    Logger.debug("Received frames: #{inspect(frames)}")

    unused_listeners =
      Enum.reduce(frames, state.listeners, fn frame, listeners ->
        handle_frame(frame, listeners, state.data_listeners)
      end)

    {:noreply, %{state | listeners: unused_listeners}}
  end

  # Keep the watchdog timer on the Conbee going.
  def handle_info(:watchdog, state) do
    Logger.debug("Resetting Conbee watchdog timer.")
    keepalive_s = Application.fetch_env!(:deconzex, :device)[:keepalive_s]

    Process.send_after(self(), :watchdog, keepalive_s * 1000)
    write_parameter(:watchdog_ttl, keepalive_s * 2)
    {:noreply, state}
  end

  defp handle_frame(
         %{command: :device_state_changed, apsde_data_flags: %{aps_data_indication: 1}} = frame,
         listeners,
         data_listeners
       ) do
    Logger.info("Data indication frame recieved.")
    Enum.each(data_listeners, fn listener -> Logger.debug("Sending frame") end)
    do_handle_frame(frame, listeners)
  end

  defp handle_frame(frame, listeners, _) do
    do_handle_frame(frame, listeners)
  end

  defp do_handle_frame(frame, listeners) do
    valid_listeners = Enum.filter(listeners, fn {_, s} -> s == frame.seq end)
    Enum.each(valid_listeners, fn {pid, _} -> send(pid, frame) end)
    listeners -- valid_listeners
  end
end
