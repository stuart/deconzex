defmodule Deconzex.DeviceSupervisor do
  use Supervisor

  @moduledoc """
  Supervisor that runs the serial port to the Conbee device and the
  device interface genserver. 
  """
  @spec start_link(term) :: {:ok, pid} | {:error, term}
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Circuits.UART, [name: :uart]},
      {Deconzex.Device, []}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
