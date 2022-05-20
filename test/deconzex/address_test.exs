defmodule AddressTest do
  use ExUnit.Case
  alias Deconzex.Address

  test "creating network address" do
    address  = Address.nwk(123)
    assert Address.mode(address) == :nwk
    assert Address.addr(address) == 123
  end

  test "creating group address" do
    address  = Address.group(123)
    assert Address.mode(address) == :group
    assert Address.addr(address) == 123
  end

  test "creating ieee address" do
    address  = Address.ieee(0x0102030405060708)
    assert Address.mode(address) == :ieee
    assert Address.addr(address) == 0x0102030405060708
  end

  test "address modes" do
    assert :group = Address.mode({:group, 1234})
    assert :nwk = Address.mode({:nwk, 1234})
    assert :ieee = Address.mode({:ieee, 1234})
  end

  test "address mode ids" do
    assert 1 = Address.mode_id(:group)
    assert 2 = Address.mode_id(:nwk)
    assert 3 = Address.mode_id(:ieee)
  end

  test "serialize ieee address" do
    address = Address.ieee(0x0102030405060708)
    assert <<0x03, 0x0102030405060708::64-little>> = Address.serialize(address)
  end

  test "deserialize ieee address" do
    addr = Address.ieee(0x0102030405060708)
    assert {addr, <<>>} == Address.deserialize(<<0x03, 0x0102030405060708::64-little>>)
  end

  test "serialize nwk address" do
    address = Address.nwk(0xCFFF)
    assert <<0x02, 0xCFFF::16-little>> = Address.serialize(address)
  end

  test "deserialize nwk address" do
    addr = Address.nwk(0x1234)
    assert {addr, <<>>} == Address.deserialize(<<0x02, 0x1234::16-little>>)
  end

    test "serialize group address" do
    address = Address.group(0xCFFF)
    assert <<0x01, 0xCFFF::16-little>> = Address.serialize(address)
  end

  test "deserialize group address" do
    addr = Address.group(0x1234)
    assert {addr, <<>>} == Address.deserialize(<<0x01, 0x1234::16-little>>)
  end

  test "deserialize address returns the rest of the data" do
    assert {_, <<0x01, 0x02, 0x03>>} = Address.deserialize(<<0x01, 0x1234::16-little, 0x01, 0x02, 0x03>>)
  end
end
