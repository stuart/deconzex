defmodule ZCL.Cluster.Basic do
  alias ZCL.Attribute

  # Basic cluster for Server

  def id do
    0x0000
  end

  def server_attributes do
    [
      %Attribute{id: 0x0000, name: "ZCLVersion", data_type: :uint8, default: 0x02},
      %Attribute{id: 0x0001, name: "Application Version", data_type: :uint8, default: 0},
      %Attribute{id: 0x0002, name: "Stack Version", data_type: :uint8, default: 0},
      %Attribute{id: 0x0003, name: "HW Version", data_type: :uint8, default: 0},
      %Attribute{id: 0x0004, name: "Manufacturer Name", data_type: :string, default: ""},
      %Attribute{id: 0x0005, name: "Model Identifier", data_type: :string, default: ""},
      %Attribute{id: 0x0006, name: "Date Code", data_type: :string, default: ""},
      %Attribute{id: 0x0008, name: "Power Source", data_type: :enum8, default: 0},
      %Attribute{
        id: 0x0010,
        name: "Location Description",
        data_type: :string,
        default: "",
        access: :rw
      },
      %Attribute{
        id: 0x0011,
        name: "Physical Environment",
        data_type: :enum8,
        default: 0,
        access: :rw
      },
      %Attribute{
        id: 0x0012,
        name: "Device Enabled",
        data_type: :boolean,
        default: true,
        access: :rw
      },
      %Attribute{id: 0x0013, name: "Alarm Mask", data_type: :map8, default: true, access: :rw},
      %Attribute{
        id: 0x0012,
        name: "Disable Local Config",
        data_type: :map8,
        default: true,
        access: :rw
      },
      %Attribute{id: 0x4000, name: "SW Build ID", data_type: :string, default: ""}
    ]
  end

  def client_attributes do
    []
  end

  def command(0x00) do
    factory_reset()
  end

  defp factory_reset() do
    nil
  end
end
