defmodule Deconzex.ParametersTest do
  use ExUnit.Case

  test "fetching a parameter from the id" do
    assert :mac_address = Deconzex.Parameters.find(1)
  end

  test "fetching a nonexistent parameter id" do
    assert :unknown = Deconzex.Parameters.find(20)
  end

  test "fetching a parameter id from the parameter atom" do
    assert 5 = Deconzex.Parameters.id(:nwk_panid)
  end

  test "fetching a parameter id for nonexistent parameter" do
    assert 0 = Deconzex.Parameters.id(:unknown)
  end

  test "deserializing a malformed parameter" do
    assert {:error, :cannot_deserialize_value} =
             Deconzex.Parameters.deserialize(:mac_address, <<0x12>>)
  end

  test "serializing a malformed parameter" do
    assert {:error, :cannot_serialize_value} = Deconzex.Parameters.serialize(:unknown, 10)
  end

  test "serializing an unsigned 8 bit parameter" do
    assert <<11>> = Deconzex.Parameters.serialize(:current_channel, 11)
  end

  test "deserializing an unsigned 8 bit parameter" do
    assert 11 = Deconzex.Parameters.deserialize(:current_channel, <<11>>)
  end

  test "serializing an unsigned 16 bit parameter" do
    assert <<0xEF, 0xCD>> = Deconzex.Parameters.serialize(:protocol_version, 0xCDEF)
  end

  test "deserializing an unsigned 16 bit parameter" do
    assert 0x1234 = Deconzex.Parameters.deserialize(:protocol_version, <<0x34, 0x12>>)
  end

  test "serializing an unsigned 32 bit parameter" do
    assert <<0x78, 0x56, 0x34, 0x12>> = Deconzex.Parameters.serialize(:watchdog_ttl, 0x12345678)
  end

  test "deserializing an unsigned 32 bit parameter" do
    assert 0x12345678 = Deconzex.Parameters.deserialize(:watchdog_ttl, <<0x78, 0x56, 0x34, 0x12>>)
  end

  test "serializing an unsigned 64 bit parameter" do
    assert <<0xEF, 0xCD, 0xAB, 0x90, 0x78, 0x56, 0x34, 0x12>> =
             Deconzex.Parameters.serialize(:mac_address, 0x1234567890ABCDEF)
  end

  test "deserializing an unsigned 64 bit parameter" do
    assert 0x1234567890ABCDEF =
             Deconzex.Parameters.deserialize(
               :mac_address,
               <<0xEF, 0xCD, 0xAB, 0x90, 0x78, 0x56, 0x34, 0x12>>
             )
  end

  test "serializing a boolean" do
    assert <<1::8>> = Deconzex.Parameters.serialize(:aps_designated_coordinator, true)
    assert <<0::8>> = Deconzex.Parameters.serialize(:aps_designated_coordinator, false)
  end

  test "deserializing a boolean" do
    assert true == Deconzex.Parameters.deserialize(:predifined_nwk_panid, <<0x01>>)
    assert false == Deconzex.Parameters.deserialize(:predifined_nwk_panid, <<0x00>>)
  end

  test "serializing the channel mask" do
    assert <<0x00, 0x02, 0x08, 0x00>> = Deconzex.Parameters.serialize(:channel_mask, [11, 17])
  end

  test "deserializing the channel mask" do
    assert [11] = Deconzex.Parameters.deserialize(:channel_mask, <<0x00, 0x00, 0x08, 0x00>>)
    assert [26] = Deconzex.Parameters.deserialize(:channel_mask, <<0x04, 0x00, 0x00, 0x00>>)

    assert [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26] =
             Deconzex.Parameters.deserialize(:channel_mask, <<0x07, 0xFF, 0xF8, 0x00>>)
  end
end
