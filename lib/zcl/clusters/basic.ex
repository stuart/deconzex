defmodule ZCL.Cluster.Basic do
  alias ZCL.Attribute
  use ZCL.ClusterDefinition

  @callback factory_reset() :: :ok
  @optional_callback :factory_reset

  def id do
    0x0000
  end

  def name do
    "Basic"
  end

  def dependencies do
    []
  end

  def global_attributes do
    [
      %Attribute{
        key: :cluster_revision,
        id: 0xFFFD,
        name: "Cluster Revision",
        data_type: :uint16,
        default: 1
      }
    ]
  end

  # Output attributes
  def server_attributes do
    [
      %Attribute{
        key: :zcl_version,
        id: 0x0000,
        name: "ZCLVersion",
        data_type: :uint8,
        default: 2,
        optional: false
      },
      %Attribute{
        key: :application_version,
        id: 0x0001,
        name: "Application Version",
        data_type: :uint8,
        default: 0
      },
      %Attribute{
        key: :stack_version,
        id: 0x0002,
        name: "Stack Version",
        data_type: :uint8,
        default: 0
      },
      %Attribute{
        key: :hardware_version,
        id: 0x0003,
        name: "Hardware Version",
        data_type: :uint8,
        default: 0
      },
      %Attribute{
        key: :manufacturer,
        id: 0x0004,
        name: "Manufacturer Name",
        data_type: :string,
        default: "",
        max_length: 32
      },
      %Attribute{
        key: :model,
        id: 0x0005,
        name: "Model Identifier",
        data_type: :string,
        default: "",
        max_length: 32
      },
      %Attribute{
        key: :date_code,
        id: 0x0006,
        name: "Date Code",
        data_type: :string,
        default: "",
        max_length: 16
      },
      %Attribute{
        key: :power_source,
        id: 0x0008,
        name: "Power Source",
        data_type: :enum8,
        default: 0,
        optional: false
      },
      %Attribute{
        key: :location_description,
        id: 0x0010,
        name: "Location Description",
        data_type: :string,
        default: "",
        writeable: true
      },
      %Attribute{
        key: :physical_environment,
        id: 0x0011,
        name: "Physical Environment",
        data_type: :enum8,
        default: 0,
        writeable: true
      },
      %Attribute{
        key: :device_enabled,
        id: 0x0012,
        name: "Device Enabled",
        data_type: :boolean,
        default: true,
        writeable: true
      },
      %Attribute{
        key: :alarm_mask,
        id: 0x0013,
        name: "Alarm Mask",
        data_type: :map8,
        default: true,
        writeable: true
      },
      %Attribute{
        key: :disable_local_config,
        id: 0x0012,
        name: "Disable Local Config",
        data_type: :map8,
        default: true,
        writeable: true
      },
      %Attribute{
        key: :build_id,
        id: 0x4000,
        name: "SW Build ID",
        data_type: :string,
        default: ""
      }
    ]
  end

  # Input attributes
  def client_attributes do
    []
  end

  def server_commands() do
    %{0x00 => :factory_reset}
  end

  def client_commands() do
    %{}
  end

  defp physical_environments do
    %{
      0x00 => "Unspecified Environment",
      0x01 => "Atrium",
      0x02 => "Bar",
      0x03 => "Courtyard",
      0x04 => "Bathroom",
      0x05 => "Bedroom",
      0x06 => "Billiard Room",
      0x07 => "Utility Room",
      0x08 => "Description",
      0x09 => "Cellar",
      0x0A => "Storage Closet",
      0x0B => "Theater",
      0x0C => "Office",
      0x0D => "Deck",
      0x0E => "Den",
      0x0F => "Dining Room",
      0x10 => "Electrical Room",
      0x11 => "Elevator",
      0x12 => "Entry",
      0x13 => "Family Room",
      0x14 => "Main Floor",
      0x15 => "Upstairs",
      0x16 => "Downstairs Basement/Lower Level",
      0x17 => "Gallery",
      0x18 => "Game Room",
      0x19 => "Garage",
      0x1A => "Gym",
      0x1B => "Hallway",
      0x1C => "House",
      0x1D => "Kitchen",
      0x1E => "Laundry Room",
      0x1F => "Library",
      0x20 => "Master Bedroom",
      0x21 => "Mud Room",
      0x22 => "Nursery",
      0x23 => "Pantry",
      0x24 => "Office",
      0x25 => "Outside",
      0x26 => "Pool",
      0x27 => "Porch",
      0x28 => "Sewing Room",
      0x29 => "Sitting Room",
      0x2A => "Stairway",
      0x2B => "Yard",
      0x2C => "Attic",
      0x2D => "Hot Tub",
      0x2E => "Living Room",
      0x2F => "Sauna",
      0x30 => "Shop/Workshop",
      0x31 => "Guest Bedroom",
      0x32 => "Guest Bath",
      0x33 => "Powder Room",
      0x34 => "Back Yard",
      0x35 => "Front Yard",
      0x36 => "Patio",
      0x37 => "Driveway",
      0x38 => "Sun Room",
      0x39 => "Living Room",
      0x3A => "Spa",
      0x3B => "Whirlpool",
      0x3C => "Shed",
      0x3D => "Equipment Storage",
      0x3E => "Hobby/Craft Room",
      0x3F => "Fountain",
      0x40 => "Pond",
      0x41 => "Reception Room",
      0x42 => "Breakfast Room",
      0x43 => "Nook",
      0x44 => "Garden",
      0x45 => "Balcony",
      0x46 => "Panic Room",
      0x47 => "Terrace",
      0x48 => "Roof",
      0x49 => "Toilet",
      0x4A => "Toilet Main",
      0x4B => "Outside Toilet",
      0x4C => "Shower Room",
      0x4D => "Study",
      0x4E => "Front Garden",
      0x4F => "Back Garden",
      0x50 => "Kettle",
      0x51 => "Television",
      0x52 => "Stove",
      0x53 => "Microwave",
      0x54 => "Toaster",
      0x55 => "Vacuum",
      0x56 => "Appliance",
      0x57 => "Front Door",
      0x58 => "Back Door",
      0x59 => "Fridge Door",
      0x60 => "Medication Cabinet Door",
      0x61 => "Wardrobe Door",
      0x62 => "Front Cupboard Door",
      0x63 => "Other Door",
      0x64 => "Waiting Room",
      0x65 => "Triage Room",
      0x66 => "Doctor’s Office",
      0x67 => "Patient’s Private Room",
      0x68 => "Consultation Room",
      0x69 => "Nurse Station",
      0x6A => "Ward",
      0x6B => "Corridor",
      0x6C => "Operating Theatre",
      0x6D => "Dental Surgery Room",
      0x6E => "Medical Imaging Room",
      0x6F => "Decontamination Room",
      0xFF => "Unknown Environment"
    }
  end

  defp power_sources do
    %{
      0x00 => "Unknown",
      0x01 => "Mains (single phase)",
      0x02 => "Mains (3 phase)",
      0x03 => "Battery",
      0x04 => "DC source",
      0x05 => "Emergency mains constantly powered",
      0x06 => "Emergency mains and transfer switch"
    }
  end
end
