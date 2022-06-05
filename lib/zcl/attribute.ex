defmodule ZCL.Attribute do
  alias ZCL.DataTypes

  @moduledoc """
    Handling ZCL attributes 
  """
  defstruct id: 0,
            key: :none,
            name: "",
            data_type: :none,
            default: nil,
            optional: true,
            readable: true,
            writeable: false,
            reportable: false,
            max_length: 0

  @type t :: %__MODULE__{}

  def extended_attribute_info(%__MODULE__{} = attr) do
    <<attr.id::16, attr.data_type::8, attr.readable::1, attr.writeable::1, attr.reportable::1,
      0x00::5>>
  end

  # Validate data by trying to serialize it.
  # Assume that if it serializes then it is okay.
  def validate(%__MODULE__{} = attribute, value) do
    case DataTypes.serialize(attribute.data_type, value) do
      {:error, reason} -> {:error, :invalid_value}
      data -> {:ok, value}
    end
  end
end
