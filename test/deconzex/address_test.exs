defmodule Deconzex.AddressTest do
  use ExUnit.Case

  test "address modes" do
    assert :group = Deconzex.Address.mode(%Deconzex.Address{group: 1234})
    assert :nwk = Deconzex.Address.mode(%Deconzex.Address{nwk: 1234})
    assert :ieee = Deconzex.Address.mode(%Deconzex.Address{ieee: 1234})
    assert :ieee = Deconzex.Address.mode(%Deconzex.Address{ieee: 1234, group: 34, nwk: 12345})
  end

  test "address mode ids" do
    assert 1 = Deconzex.Address.mode_id(:group)
    assert 2 = Deconzex.Address.mode_id(:nwk)
    assert 3 = Deconzex.Address.mode_id(:ieee)
  end
end
