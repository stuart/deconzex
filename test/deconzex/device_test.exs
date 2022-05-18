defmodule Deconzex.DeviceTest do
  use ExUnit.Case
  alias Deconzex.Device

  test "connects to the serial port" do
    Device.connect()
    assert Device.uart_connected()
  end
end
