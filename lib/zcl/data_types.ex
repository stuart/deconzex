defmodule ZCL.DataTypes do
  @types %{
    0x00 => {:nodata, 0, nil, nil},
    0x08 => {:data8, 8, nil, :discrete},
    0x09 => {:data16, 16, nil, :discrete},
    0x0A => {:data24, 24, nil, :discrete},
    0x0B => {:data32, 32, nil, :discrete},
    0x0C => {:data40, 40, nil, :discrete},
    0x0D => {:data48, 48, nil, :discrete},
    0x0E => {:data56, 56, nil, :discrete},
    0x0F => {:data64, 64, nil, :discrete},
    0x10 => {:bool, 8, <<0xFF>>, :discrete},
    0x18 => {:map8, 8, nil, :discrete},
    0x19 => {:map16, 16, nil, :discrete},
    0x1A => {:map24, 24, nil, :discrete},
    0x1B => {:map32, 32, nil, :discrete},
    0x1C => {:map40, 40, nil, :discrete},
    0x1D => {:map48, 48, nil, :discrete},
    0x1E => {:map56, 56, nil, :discrete},
    0x1F => {:map64, 64, nil, :discrete},
    0x20 => {:uint8, 8, 0xFF, :analog},
    0x21 => {:uint16, 16, 0xFFFF, :analog},
    0x22 => {:uint24, 24, 0xFFFFFF, :analog},
    0x23 => {:uint32, 32, 0xFFFFFFFF, :analog},
    0x24 => {:uint40, 40, 0xFFFFFFFFFF, :analog},
    0x25 => {:uint48, 48, 0xFFFFFFFFFFFF, :analog},
    0x26 => {:uint56, 56, 0xFFFFFFFFFFFFFFF, :analog},
    0x27 => {:uint64, 64, 0xFFFFFFFFFFFFFFFFF, :analog},
    0x28 => {:int8, 8, 0x80, :analog},
    0x29 => {:int16, 16, 0x8000, :analog},
    0x2A => {:int24, 24, 0x800000, :analog},
    0x2B => {:int32, 32, 0x80000000, :analog},
    0x2C => {:int40, 40, 0x8000000000, :analog},
    0x2D => {:int48, 48, 0x800000000000, :analog},
    0x2E => {:int56, 56, 0x80000000000000, :analog},
    0x2F => {:int64, 64, 0x8000000000000000, :analog},
    0x30 => {:enum8, 8, 0xFF, :discrete},
    0x31 => {:enum16, 16, 0xFF, :discrete},
    0x38 => {:semi, 16, :nan, :analog},
    0x39 => {:single, 32, :nan, :analog},
    0x3A => {:double, 64, :nan, :analog},
    0x41 => {:octstr, nil, nil, :discrete},
    0x42 => {:string, nil, nil, :discrete},
    0x43 => {:octstr16, nil, nil, :discrete},
    0x44 => {:string16, nil, nil, :discrete},
    0x48 => {:array, nil, nil, :discrete},
    0x4C => {:struct, nil, nil, :discrete},
    0x50 => {:set, nil, nil, :discrete},
    0x51 => {:bag, nil, nil, :discrete},
    0xE0 => {:tod, 32, 0xFFFFFFFF, :analog},
    0xE1 => {:date, 32, 0xFFFFFFFF, :analog},
    0xE2 => {:utc, 32, 0xFFFFFFFF, :analog},
    0xE8 => {:clusterID, 16, 0xFFFF, :discrete},
    0xE9 => {:attributeID, 16, 0xFFFF, :discrete},
    0xEA => {:bacOID, 32, 0xFFFFFFFF, :discrete},
    0xF0 => {:eui64, 64, 0xFFFFFFFFFFFFFFFF, :discrete},
    0xF1 => {:key128, 128, nil, :discrete},
    nil => {:opaque, nil, nil, :discrete},
    0xFF => :unknown
  }

  @type_ids %{
    nodata: 0x00,
    data8: 0x08,
    data16: 0x09,
    data24: 0x0A,
    data32: 0x0B,
    data40: 0x0C,
    data48: 0x0D,
    data56: 0x0E,
    data64: 0x0F,
    bool: 0x10,
    map8: 0x18,
    map16: 0x19,
    map24: 0x1A,
    map32: 0x1B,
    map40: 0x1C,
    map48: 0x1D,
    map56: 0x1E,
    map64: 0x1F,
    uint8: 0x20,
    uint16: 0x21,
    uint24: 0x22,
    uint32: 0x23,
    uint40: 0x24,
    uint48: 0x25,
    uint56: 0x26,
    uint64: 0x27,
    int8: 0x28,
    int16: 0x29,
    int24: 0x2A,
    int32: 0x2B,
    int40: 0x2C,
    int48: 0x2D,
    int56: 0x2E,
    int64: 0x2F,
    enum8: 0x30,
    enum16: 0x31,
    semi: 0x38,
    single: 0x39,
    double: 0x3A,
    octstr: 0x41,
    string: 0x42,
    octstr16: 0x43,
    string16: 0x44,
    array: 0x48,
    struct: 0x4C,
    set: 0x50,
    bag: 0x51,
    tod: 0xE0,
    date: 0xE1,
    utc: 0xE2,
    clusterID: 0xE8,
    attributeID: 0xE9,
    bacOID: 0xEA,
    eui64: 0xF0,
    key128: 0xF1,
    opaque: nil,
    unk: 0xFF
  }

  @data_map_types [
    :data8,
    :data16,
    :data24,
    :data32,
    :data40,
    :data48,
    :data56,
    :data64,
    :map8,
    :map16,
    :map24,
    :map32,
    :map40,
    :map48,
    :map56,
    :map64
  ]

  def id(type) do
    Map.get(@type_ids, type, nil)
  end

  def fetch_type(type_name) do
    Map.get(@types, type_name, nil)
  end

  def is_discrete(type_name) do
    type_id = id(type_name)
    {_, _, _, da} = fetch_type(type_id)

    case da do
      :discrete -> true
      _ -> false
    end
  end

  def is_analog(type_name) do
    type_id = id(type_name)
    {_, _, _, da} = fetch_type(type_id)

    case da do
      :analog -> true
      _ -> false
    end
  end

  def serialize(:opaque, value) when is_binary(value) do
    value
  end

  def serialize(:opaque, value) do
    {:error, "Opaque values must be binary."}
  end

  def serialize(type_name, value) when type_name in @data_map_types do
    type_id = id(type_name)
    {type_name, size, _, _} = fetch_type(type_id)

    if bit_size(value) == size do
      <<type_id::8>> <> value
    else
      {:error, "Binary is the wrong length for the data type."}
    end
  end

  def serialize(type_name, value) do
    case do_serialize(type_name, value) do
      {:error, reason} -> {:error, reason}
      {:ok, data} -> <<id(type_name)::8>> <> data
    end
  end

  def serialize(:array, internal_type, array) do
    Enum.reduce(array, <<id(:array)::8, length(array)::16-little>>, fn e, acc ->
      acc <> serialize(internal_type, e)
    end)
  end

  def deserialize(<<type_id::8, data::binary>>) do
    type = fetch_type(type_id)

    case do_deserialize(type, data) do
      {:ok, value} -> value
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_serialize(:nodata, _) do
    {:ok, <<>>}
  end

  defp do_serialize(:bool, true) do
    {:ok, <<0x01>>}
  end

  defp do_serialize(:bool, false) do
    {:ok, <<0x00>>}
  end

  defp do_serialize(:uint8, value) do
    {:ok, <<value::8>>}
  end

  defp do_serialize(:uint16, value) do
    {:ok, <<value::16-little>>}
  end

  defp do_serialize(:uint24, value) do
    {:ok, <<value::24-little>>}
  end

  defp do_serialize(:uint32, value) do
    {:ok, <<value::32-little>>}
  end

  defp do_serialize(:uint40, value) do
    {:ok, <<value::40-little>>}
  end

  defp do_serialize(:uint48, value) do
    {:ok, <<value::48-little>>}
  end

  defp do_serialize(:uint56, value) do
    {:ok, <<value::56-little>>}
  end

  defp do_serialize(:uint64, value) do
    {:ok, <<value::64-little>>}
  end

  defp do_serialize(:int8, value) do
    {:ok, <<value::8-signed-little>>}
  end

  defp do_serialize(:int16, value) do
    {:ok, <<value::16-signed-little>>}
  end

  defp do_serialize(:int24, value) do
    {:ok, <<value::24-signed-little>>}
  end

  defp do_serialize(:int32, value) do
    {:ok, <<value::32-signed-little>>}
  end

  defp do_serialize(:int40, value) do
    {:ok, <<value::40-signed-little>>}
  end

  defp do_serialize(:int48, value) do
    {:ok, <<value::48-signed-little>>}
  end

  defp do_serialize(:int56, value) do
    {:ok, <<value::56-signed-little>>}
  end

  defp do_serialize(:int64, value) do
    {:ok, <<value::64-signed-little>>}
  end

  defp do_serialize(:enum8, value) do
    {:ok, <<value::8>>}
  end

  defp do_serialize(:enum16, value) do
    {:ok, <<value::16-little>>}
  end

  # This one does not actually convert. Application has to supply the value
  # in the proper format.
  defp do_serialize(:semi, value) when is_binary(value) do
    {:ok, value}
  end

  defp do_serialize(:semi, _value) do
    {:error, "Semi precision numbers must be pre-encoded into binary form."}
  end

  defp do_serialize(:single, value) do
    {:ok, <<value::32-float-little>>}
  end

  defp do_serialize(:double, value) do
    {:ok, <<value::64-float-little>>}
  end

  defp do_serialize(type, <<value::binary>>)
       when type in [:octstr, :string] and byte_size(value) < 255 do
    {:ok, <<byte_size(value)::8, value::binary>>}
  end

  defp do_serialize(type, _value) when type in [:octstr, :string] do
    {:error, "Value is too long for type #{type}"}
  end

  defp do_serialize(type, <<value::binary>>)
       when type in [:octstr16, :string16] and byte_size(value) < 0xFFFF do
    {:ok, <<byte_size(value)::16-little, value::binary>>}
  end

  defp do_serialize(type, _value) when type in [:octstr16, :string16] do
    {:error, "Value is too long for type #{type}"}
  end

  defp do_serialize(:tod, %Time{} = value) do
    {microsecond, _precision} = value.microsecond
    hundredths = div(microsecond, 10000)
    {:ok, <<value.hour::8, value.minute::8, value.second::8, hundredths::8>>}
  end

  defp do_serialize(:date, %Date{} = value) do
    {:ok, <<value.year - 1900::8, value.month, value.day, Date.day_of_week(value)>>}
  end

  defp do_serialize(:utc, %DateTime{} = value) do
    # Jan 1 2000 in unix time.
    dt = DateTime.to_unix(value) - 946_684_800
    {:ok, <<dt::32-little>>}
  end

  defp do_serialize(type, value) when type in [:clusterID, :attributeID] do
    {:ok, <<value::16-little>>}
  end

  defp do_serialize(:bacOID, value) do
    {:ok, <<value::32-little>>}
  end

  defp do_serialize(:eui64, value) do
    {:ok, <<value::64-little>>}
  end

  defp do_serialize(:key128, value) do
    {:ok, <<value::128-little>>}
  end

  defp do_serialize(type, value) do
    {:error, "Cannot serialize #{inspect(value)} as type #{type}"}
  end

  ##### DESERIALIZE #####
  defp do_deserialize({type, _, invalid, _}, data) when invalid == data do
    {:error, "Invalid value"}
  end

  defp do_deserialize({type, size, _, _}, data) when is_number(size) and size != bit_size(data) do
    {:error, "Incorrect size data for type: #{type}."}
  end

  defp do_deserialize({:nodata, _, _, _}, <<>>) do
    {:ok, nil}
  end

  defp do_deserialize({type, size, _, _}, data) when type in @data_map_types do
    {:ok, data}
  end

  defp do_deserialize({:bool, _, _, _}, <<0x00>>) do
    {:ok, false}
  end

  defp do_deserialize({:bool, _, _, _}, <<0x01>>) do
    {:ok, true}
  end

  defp do_deserialize({:uint8, _, _, _}, <<data::8>>) do
    {:ok, data}
  end

  defp do_deserialize({:uint16, _, _, _}, <<data::16-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:uint24, _, _, _}, <<data::24-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:uint32, _, _, _}, <<data::32-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:uint40, _, _, _}, <<data::40-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:uint48, _, _, _}, <<data::48-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:uint56, _, _, _}, <<data::56-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:uint64, _, _, _}, <<data::64-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:int8, _, _, _}, <<data::8-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:int16, _, _, _}, <<data::16-little-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:int24, _, _, _}, <<data::24-little-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:int32, _, _, _}, <<data::32-little-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:int40, _, _, _}, <<data::40-little-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:int48, _, _, _}, <<data::48-little-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:int56, _, _, _}, <<data::56-little-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:int64, _, _, _}, <<data::64-little-signed>>) do
    {:ok, data}
  end

  defp do_deserialize({:enum8, _, _, _}, <<data::8>>) do
    {:ok, data}
  end

  defp do_deserialize({:enum16, _, _, _}, <<data::16-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:semi, _, _, _}, data) do
    {:ok, data}
  end

  defp do_deserialize({:single, _, _, _}, <<data::32-float-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:double, _, _, _}, <<data::64-float-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:octstr, _, _, _}, <<len::8, data::binary>>) do
    {:ok, data}
  end

  defp do_deserialize({:string, _, _, _}, <<len::8, data::binary>>) do
    {:ok, data}
  end

  defp do_deserialize({:octstr16, _, _, _}, <<len::16, data::binary>>) do
    {:ok, data}
  end

  defp do_deserialize({:string16, _, _, _}, <<len::16, data::binary>>) do
    {:ok, data}
  end

  defp do_deserialize({:tod, _, _, _}, <<hour::8, minute::8, second::8, hundredth::8>>) do
    Time.new(hour, minute, second, {hundredth * 10000, 2})
  end

  defp do_deserialize({:date, _, _, _}, <<year::8, month::8, day_of_month::8, day_of_week::8>>) do
    Date.new(year + 1900, month, day_of_month)
  end

  defp do_deserialize({:utc, _, _, _}, <<dt::32-little>>) do
    DateTime.from_unix(dt + 946_684_800)
  end

  defp do_deserialize({:clusterID, _, _, _}, <<data::16-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:attributeID, _, _, _}, <<data::16-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:bacOID, _, _, _}, <<data::32-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:eui64, _, _, _}, <<data::64-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:key128, _, _, _}, <<data::128-little>>) do
    {:ok, data}
  end

  defp do_deserialize({:array, _, _, _}, <<type_id::8, data::binary>>) do
    {type, size, _, _} = fetch_type(type_id)
    do_deserialize_array(data, [])
  end

  defp do_deserialize(nil, _data) do
    {:error, "Opaque or unknown data type."}
  end

  defp do_deserialize_array(<<>>, array) do
    array
  end

  defp do_deserialize_array(data, array) do
  end
end
