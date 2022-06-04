defmodule Deconzex.SerialPort do
  require Logger

  @moduledoc """
    A wrapper around handling Circuits.UART functionality
  """
  @spec connect(pid) :: boolean
  def connect(uart) do
    serial_config = Application.fetch_env!(:deconzex, :device)
    serial_port = Map.get(serial_config, :serial_port, "ttyACM0")
    serial_speed = Map.get(serial_config, :serial_speed, 38400)

    Logger.info("Opening serial port #{serial_port}")

    Circuits.UART.configure(uart, framing: {Deconzex.Slip, []})

    case Circuits.UART.open(uart, serial_port,
           speed: serial_speed,
           active: true
         ) do
      :ok ->
        Logger.info("Serial port connected.")
        true

      {:error, :enoent} ->
        Logger.error("Cannot find the serial port #{serial_port}.")
        false

      error ->
        Logger.error("Error from UART: #{inspect(error)}")
        false
    end
  end

  @spec write(pid, binary) :: :ok
  def write(uart, frame) do
    Logger.debug("Sending data to UART: #{inspect(frame)}")
    Circuits.UART.write(uart, frame)
  end

  @spec handle_connection_lost(pid, String.t()) :: :ok
  def handle_connection_lost(_uart, serial_port) do
    Logger.error("Lost serial port connection to #{serial_port}")
  end
end
