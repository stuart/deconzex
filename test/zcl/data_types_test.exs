defmodule ZCL.DataTypesTest do
  use ExUnit.Case

  alias ZCL.DataTypes

  describe "Null" do
    test "serialize" do
      assert <<0x00>> == DataTypes.serialize(:nodata, nil)
    end

    test "is not discrete or analog" do
      refute DataTypes.is_discrete(:nodata)
      refute DataTypes.is_analog(:nodata)
    end

    test "deserialize" do
      assert nil == DataTypes.deserialize(<<0x00>>)
    end

    test "deserialize fails when data is wrong size" do
      assert {:error, "Incorrect size data for type: nodata."} =
               DataTypes.deserialize(<<0x00, 0x01>>)
    end
  end

  describe "General Data" do
    test "serialize" do
      assert <<0x08, 0x34>> == DataTypes.serialize(:data8, <<0x34>>)
      assert <<0x09, 0x12, 0x34>> == DataTypes.serialize(:data16, <<0x12, 0x34>>)
      assert <<0x0A, 0x12, 0x34, 0x56>> == DataTypes.serialize(:data24, <<0x12, 0x34, 0x56>>)

      assert <<0x0B, 0x12, 0x34, 0x56, 0x78>> ==
               DataTypes.serialize(:data32, <<0x12, 0x34, 0x56, 0x78>>)

      assert <<0x0C, 0x12, 0x34, 0x56, 0x78, 0x9A>> ==
               DataTypes.serialize(:data40, <<0x12, 0x34, 0x56, 0x78, 0x9A>>)

      assert <<0x0D, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC>> ==
               DataTypes.serialize(:data48, <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC>>)

      assert <<0x0E, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE>> ==
               DataTypes.serialize(:data56, <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE>>)

      assert <<0x0F, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0>> ==
               DataTypes.serialize(:data64, <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0>>)
    end

    test "serialize returns error if data is wrong length" do
      assert {:error, "Binary is the wrong length for the data type."} =
               DataTypes.serialize(:data16, <<0x03>>)
    end

    test "is discrete" do
      assert DataTypes.is_discrete(:data8)
      assert DataTypes.is_discrete(:data16)
      assert DataTypes.is_discrete(:data32)
      assert DataTypes.is_discrete(:data40)
      assert DataTypes.is_discrete(:data48)
      assert DataTypes.is_discrete(:data56)
      assert DataTypes.is_discrete(:data64)
    end

    test "is not analog" do
      refute DataTypes.is_analog(:data8)
      refute DataTypes.is_analog(:data16)
      refute DataTypes.is_analog(:data24)
      refute DataTypes.is_analog(:data32)
      refute DataTypes.is_analog(:data40)
      refute DataTypes.is_analog(:data48)
      refute DataTypes.is_analog(:data56)
      refute DataTypes.is_analog(:data64)
    end

    test "deserialize" do
      assert <<0x34>> == DataTypes.deserialize(<<0x08, 0x34>>)
      assert <<0x12, 0x34>> == DataTypes.deserialize(<<0x09, 0x12, 0x34>>)
      assert <<0x12, 0x34, 0x56>> == DataTypes.deserialize(<<0x0A, 0x12, 0x34, 0x56>>)
      assert <<0x12, 0x34, 0x56, 0x78>> == DataTypes.deserialize(<<0x0B, 0x12, 0x34, 0x56, 0x78>>)

      assert <<0x12, 0x34, 0x56, 0x78, 0x9A>> ==
               DataTypes.deserialize(<<0x0C, 0x12, 0x34, 0x56, 0x78, 0x9A>>)

      assert <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC>> ==
               DataTypes.deserialize(<<0x0D, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC>>)

      assert <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE>> ==
               DataTypes.deserialize(<<0x0E, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE>>)

      assert <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0>> ==
               DataTypes.deserialize(<<0x0F, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0>>)
    end
  end

  describe "Boolean" do
    test "serialize" do
      assert <<0x10, 0x00>> = DataTypes.serialize(:bool, false)
      assert <<0x10, 0x01>> = DataTypes.serialize(:bool, true)
    end

    test "da type" do
      assert DataTypes.is_discrete(:bool)
      refute DataTypes.is_analog(:bool)
    end

    test "deserialize" do
      assert true == DataTypes.deserialize(<<0x10, 0x01>>)
      assert false == DataTypes.deserialize(<<0x10, 0x00>>)
    end
  end

  describe "Bitmaps" do
    test "serialize" do
      assert <<0x18, 0x34>> == DataTypes.serialize(:map8, <<0x34>>)
      assert <<0x19, 0x12, 0x34>> == DataTypes.serialize(:map16, <<0x12, 0x34>>)
      assert <<0x1A, 0x12, 0x34, 0x56>> == DataTypes.serialize(:map24, <<0x12, 0x34, 0x56>>)

      assert <<0x1B, 0x12, 0x34, 0x56, 0x78>> ==
               DataTypes.serialize(:map32, <<0x12, 0x34, 0x56, 0x78>>)

      assert <<0x1C, 0x12, 0x34, 0x56, 0x78, 0x9A>> ==
               DataTypes.serialize(:map40, <<0x12, 0x34, 0x56, 0x78, 0x9A>>)

      assert <<0x1D, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC>> ==
               DataTypes.serialize(:map48, <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC>>)

      assert <<0x1E, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE>> ==
               DataTypes.serialize(:map56, <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE>>)

      assert <<0x1F, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0>> ==
               DataTypes.serialize(:map64, <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0>>)
    end

    test "is discrete" do
      assert DataTypes.is_discrete(:map8)
      assert DataTypes.is_discrete(:map16)
      assert DataTypes.is_discrete(:map24)
      assert DataTypes.is_discrete(:map32)
      assert DataTypes.is_discrete(:map40)
      assert DataTypes.is_discrete(:map48)
      assert DataTypes.is_discrete(:map56)
      assert DataTypes.is_discrete(:map64)
    end

    test "is not analog" do
      refute DataTypes.is_analog(:map8)
      refute DataTypes.is_analog(:map16)
      refute DataTypes.is_analog(:map24)
      refute DataTypes.is_analog(:map32)
      refute DataTypes.is_analog(:map40)
      refute DataTypes.is_analog(:map48)
      refute DataTypes.is_analog(:map56)
      refute DataTypes.is_analog(:map64)
    end
  end

  describe "Unsigned Integers" do
    test "serialize" do
      assert <<0x20, 0xA4>> = DataTypes.serialize(:uint8, 164)
      assert <<0x21, 0xA4, 0x00>> = DataTypes.serialize(:uint16, 164)
      assert <<0x22, 0x36, 0xBB, 0x01>> = DataTypes.serialize(:uint24, 113_462)
      assert <<0x23, 0x36, 0xBB, 0x01, 0x00>> = DataTypes.serialize(:uint32, 113_462)
      assert <<0x24, 0x36, 0xBB, 0x01, 0x00, 0x00>> = DataTypes.serialize(:uint40, 113_462)
      assert <<0x25, 0x36, 0xBB, 0x01, 0x00, 0x00, 0x00>> = DataTypes.serialize(:uint48, 113_462)

      assert <<0x26, 0x36, 0xBB, 0x01, 0x00, 0x00, 0x00, 0x00>> =
               DataTypes.serialize(:uint56, 113_462)

      assert <<0x27, 0x36, 0xBB, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00>> =
               DataTypes.serialize(:uint64, 113_462)
    end

    test "are analog" do
      assert DataTypes.is_analog(:uint8)
      assert DataTypes.is_analog(:uint16)
      assert DataTypes.is_analog(:uint32)
      assert DataTypes.is_analog(:uint40)
      assert DataTypes.is_analog(:uint48)
      assert DataTypes.is_analog(:uint56)
      assert DataTypes.is_analog(:uint64)
    end

    test "are not discrete" do
      refute DataTypes.is_discrete(:uint8)
      refute DataTypes.is_discrete(:uint16)
      refute DataTypes.is_discrete(:uint32)
      refute DataTypes.is_discrete(:uint40)
      refute DataTypes.is_discrete(:uint48)
      refute DataTypes.is_discrete(:uint56)
      refute DataTypes.is_discrete(:uint64)
    end

    test "deserialize" do
      assert 164 = DataTypes.deserialize(<<0x20, 0xA4>>)
      assert 164 = DataTypes.deserialize(<<0x21, 0xA4, 0x00>>)
      assert 113_462 = DataTypes.deserialize(<<0x22, 0x36, 0xBB, 0x01>>)
      assert 113_462 = DataTypes.deserialize(<<0x23, 0x36, 0xBB, 0x01, 0x00>>)
      assert 113_462 = DataTypes.deserialize(<<0x24, 0x36, 0xBB, 0x01, 0x00, 0x00>>)
      assert 113_462 = DataTypes.deserialize(<<0x25, 0x36, 0xBB, 0x01, 0x00, 0x00, 0x00>>)
      assert 113_462 = DataTypes.deserialize(<<0x26, 0x36, 0xBB, 0x01, 0x00, 0x00, 0x00, 0x00>>)

      assert 113_462 =
               DataTypes.deserialize(<<0x27, 0x36, 0xBB, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00>>)
    end

    test "deserialize returns an error when data is the wrong length" do
      assert {:error, "Incorrect size data for type: uint16."} =
               DataTypes.deserialize(<<0x21, 0xA4>>)
    end
  end

  describe "Signed integers" do
    test "serialize" do
      assert <<0x28, 0xFF>> = DataTypes.serialize(:int8, -1)
      assert <<0x29, 0x71, 0xFB>> = DataTypes.serialize(:int16, -1167)
      assert <<0x2A, 0xCA, 0x44, 0xFE>> = DataTypes.serialize(:int24, -113_462)
      assert <<0x2B, 0x9B, 0xC0, 0xBA, 0xFF>> = DataTypes.serialize(:int32, -4_538_213)
      assert <<0x2C, 0x00, 0xE1, 0xF5, 0x05, 0x00>> = DataTypes.serialize(:int40, 100_000_000)

      assert <<0x2D, 0x29, 0x07, 0x5E, 0xA6, 0x70, 0xFD>> =
               DataTypes.serialize(:int48, -2_814_707_366_103)

      assert <<0x2E, 0x00, 0x20, 0x4A, 0xA9, 0xD1, 0x01, 0x00>> =
               DataTypes.serialize(:int56, 2_000_000_000_000)

      assert <<0x2F, 0xFE, 0xF1, 0x30, 0xA6, 0x4B, 0x9B, 0xB6, 0x01>> =
               DataTypes.serialize(:int64, 123_456_789_012_345_342)
    end

    test "are analog" do
      assert DataTypes.is_analog(:uint8)
      assert DataTypes.is_analog(:uint16)
      assert DataTypes.is_analog(:uint32)
      assert DataTypes.is_analog(:uint40)
      assert DataTypes.is_analog(:uint48)
      assert DataTypes.is_analog(:uint56)
      assert DataTypes.is_analog(:uint64)
    end

    test "are not discrete" do
      refute DataTypes.is_discrete(:uint8)
      refute DataTypes.is_discrete(:uint16)
      refute DataTypes.is_discrete(:uint32)
      refute DataTypes.is_discrete(:uint40)
      refute DataTypes.is_discrete(:uint48)
      refute DataTypes.is_discrete(:uint56)
      refute DataTypes.is_discrete(:uint64)
    end

    test "deserialize" do
      assert -1 = DataTypes.deserialize(<<0x28, 0xFF>>)
      assert -1167 = DataTypes.deserialize(<<0x29, 0x71, 0xFB>>)
      assert -113_462 = DataTypes.deserialize(<<0x2A, 0xCA, 0x44, 0xFE>>)
      assert -4_538_213 = DataTypes.deserialize(<<0x2B, 0x9B, 0xC0, 0xBA, 0xFF>>)
      assert 100_000_000 = DataTypes.deserialize(<<0x2C, 0x00, 0xE1, 0xF5, 0x05, 0x00>>)

      assert -2_814_707_366_103 =
               DataTypes.deserialize(<<0x2D, 0x29, 0x07, 0x5E, 0xA6, 0x70, 0xFD>>)

      assert 2_000_000_000_000 =
               DataTypes.deserialize(<<0x2E, 0x00, 0x20, 0x4A, 0xA9, 0xD1, 0x01, 0x00>>)

      assert 123_456_789_012_345_342 =
               DataTypes.deserialize(<<0x2F, 0xFE, 0xF1, 0x30, 0xA6, 0x4B, 0x9B, 0xB6, 0x01>>)
    end
  end

  describe "Enumerations" do
    test "serialize" do
      assert <<0x30, 0x08>> = DataTypes.serialize(:enum8, 8)
      assert <<0x31, 0x58, 0x02>> = DataTypes.serialize(:enum16, 600)
    end

    test "are not analog" do
      refute DataTypes.is_analog(:enum8)
      refute DataTypes.is_analog(:enum16)
    end

    test "are discrete" do
      assert DataTypes.is_discrete(:enum8)
      assert DataTypes.is_discrete(:enum16)
    end

    test "deserialize" do
      assert 8 = DataTypes.deserialize(<<0x30, 0x08>>)
      assert 600 = DataTypes.deserialize(<<0x31, 0x58, 0x02>>)
    end
  end

  describe "Floating Point" do
    test "serialize" do
      assert <<0x38, 0x12, 0x34>> = DataTypes.serialize(:semi, <<0x12, 0x34>>)
      assert <<0x39, 0x00, 0x00, 0x00, 0x00>> = DataTypes.serialize(:single, 0.0)
      assert <<0x39, 195, 245, 72, 64>> = DataTypes.serialize(:single, 3.14)

      assert <<0x3A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>> =
               DataTypes.serialize(:double, 0.0)

      assert <<0x3A, 31, 133, 235, 81, 184, 30, 9, 64>> = DataTypes.serialize(:double, 3.14)
    end

    test "are analog" do
      assert DataTypes.is_analog(:single)
      assert DataTypes.is_analog(:double)
    end

    test "deserialize" do
      assert <<0x12, 0x34>> = DataTypes.deserialize(<<0x38, 0x12, 0x34>>)
      assert 3.140000104904175 = DataTypes.deserialize(<<0x39, 195, 245, 72, 64>>)
      assert 3.14 = DataTypes.deserialize(<<0x3A, 31, 133, 235, 81, 184, 30, 9, 64>>)
    end
  end

  describe "Octet Strings and Character Strings" do
    test "serialize" do
      assert <<0x41, 0x03, 0xAA, 0xBB, 0xCC>> = DataTypes.serialize(:octstr, <<0xAA, 0xBB, 0xCC>>)
      assert <<0x42, 0x05, "Hello">> == DataTypes.serialize(:string, "Hello")

      assert <<0x43, 0x07, 0x00, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66>> =
               DataTypes.serialize(:octstr16, <<0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66>>)

      assert <<0x44, 0x16, 0x00, "This is a long string.">> =
               DataTypes.serialize(:string16, "This is a long string.")
    end

    test "deserialize" do
      assert <<0xAA, 0xBB, 0xCC>> = DataTypes.deserialize(<<0x41, 0x03, 0xAA, 0xBB, 0xCC>>)
      assert "Hello" == DataTypes.deserialize(<<0x42, 0x05, "Hello">>)

      assert <<0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66>> =
               DataTypes.deserialize(
                 <<0x43, 0x07, 0x00, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66>>
               )

      assert "This is a long string." =
               DataTypes.deserialize(<<0x44, 0x16, 0x00, "This is a long string.">>)
    end
  end

  describe "Array, Set, Bag" do
    test "serialize" do
      assert <<0x48, 0x04, 0x00, 0x20, 1, 0x20, 2, 0x20, 3, 0x20, 4>> =
               DataTypes.serialize(:array, :uint8, [1, 2, 3, 4])
    end

    #
    # test "serialize nested array" do
    #   assert <<>> = DataTypes.serialize(:array, [:array, :uint8], [[1,2,3],[4,5]])
    # end
  end

  describe "Time and Date" do
    test "serialize" do
      assert <<0xE0, 23, 12, 7, 4>> = DataTypes.serialize(:tod, ~T[23:12:07.041])
      assert <<0xE1, 110, 11, 4, 4>> = DataTypes.serialize(:date, ~D[2010-11-04])
      {:ok, dt} = DateTime.from_unix(1_653_702_402)
      assert <<0xE2, 130, 59, 36, 42>> = DataTypes.serialize(:utc, dt)
    end

    test "utc serialization value is correct" do
      {:ok, ndt} = NaiveDateTime.new(~D[2022-05-14], ~T[11:01:45])
      {:ok, dt} = DateTime.from_naive(ndt, "Etc/UTC")

      {:ok, ndt} = NaiveDateTime.new(~D[2000-01-01], ~T[00:00:00])
      {:ok, firstjan2000} = DateTime.from_naive(ndt, "Etc/UTC")

      <<0xE2, val::32-little>> = DataTypes.serialize(:utc, dt)
      assert val == DateTime.diff(dt, firstjan2000, :second)
    end

    test "deserialize" do
      assert ~T[23:12:07.04] = DataTypes.deserialize(<<0xE0, 23, 12, 7, 4>>)
      assert ~D[2010-11-04] = DataTypes.deserialize(<<0xE1, 110, 11, 4, 4>>)
      {:ok, dt} = DateTime.from_unix(1_653_702_402)
      assert dt == DataTypes.deserialize(<<0xE2, 130, 59, 36, 42>>)
    end
  end

  describe "Identifiers" do
    test "serialize" do
      assert <<0xE8, 0x1F, 0x02>> = DataTypes.serialize(:clusterID, 543)
      assert <<0xE9, 0x35, 0x00>> = DataTypes.serialize(:attributeID, 53)
      assert <<0xEA, 0x11, 0x22, 0x33, 0x00>> = DataTypes.serialize(:bacOID, 0x00332211)
    end

    test "deserialize" do
      assert 543 = DataTypes.deserialize(<<0xE8, 0x1F, 0x02>>)
      assert 53 = DataTypes.deserialize(<<0xE9, 0x35, 0x00>>)
      assert 0x00332211 = DataTypes.deserialize(<<0xEA, 0x11, 0x22, 0x33, 0x00>>)
    end
  end

  describe "Miscellaneous" do
    test "serialize" do
      assert 0x8899AABBCCDDEEFF =
               DataTypes.deserialize(<<0xF0, 0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88>>)

      assert <<0xF1, 0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33,
               0x22, 0x11,
               0x00>> = DataTypes.serialize(:key128, 0x00112233445566778899AABBCCDDEEFF)

      assert <<0x11, 0x22, 0x33, 0x44>> = DataTypes.serialize(:opaque, <<0x11, 0x22, 0x33, 0x44>>)
      assert {:error, "Opaque values must be binary."} = DataTypes.serialize(:opaque, 12)
    end

    test "deserialize" do
      assert <<0xF0, 0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88>> =
               DataTypes.serialize(:eui64, 0x8899AABBCCDDEEFF)

      assert 0x00112233445566778899AABBCCDDEEFF =
               DataTypes.deserialize(
                 <<0xF1, 0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88, 0x77, 0x66, 0x55, 0x44,
                   0x33, 0x22, 0x11, 0x00>>
               )

      assert {:error, "Opaque or unknown data type."} =
               DataTypes.deserialize(<<0x11, 0x22, 0x33, 0x44>>)
    end
  end
end
