defmodule Deconzex.DeviceSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Circuits.UART, [name: :uart]},
      {Deconzex.Device, []}
    ]

    Supervisor.init(children, strategy: :one_for_all, name: __MODULE__)
  end
end
