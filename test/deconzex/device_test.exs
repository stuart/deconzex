defmodule Deconzex.DeviceTest do
  use ExUnit.Case
  alias Deconzex.Device

  test "connects to the serial port" do
    assert Device.uart_connected()
  end
end
