defmodule ZCL do
  use Application
  require Logger

  @status_ids %{
    success: 0x00,
    failure: 0x01,
    not_authorized: 0x7E,
    reserved_field_not_zero: 0x7F,
    malformed_command: 0x80,
    unsup_cluster_command: 0x81,
    unsup_general_command: 0x82,
    unsup_manuf_cluster_command: 0x83,
    unsup_manuf_general_command: 0x84,
    invalid_field: 0x85,
    unsupported_attribute: 0x86,
    invalid_value: 0x87,
    read_only: 0x88,
    insufficient_space: 0x89,
    duplicate_exists: 0x8A,
    not_found: 0x8B,
    unreportable_attribute: 0x8C,
    invalid_data_type: 0x8D,
    invalid_selector: 0x8E,
    write_only: 0x8F,
    inconsistent_startup_state: 0x90,
    defined_out_of_band: 0x91,
    inconsistent: 0x92,
    action_denied: 0x93,
    timeout: 0x94,
    abort: 0x95,
    invalid_image: 0x96,
    wait_for_data: 0x97,
    no_image_available: 0x98,
    require_more_image: 0x99,
    notification_pending: 0x9A,
    hardware_failure: 0xC0,
    software_failure: 0xC1,
    calibration_error: 0xC2,
    unsupported_cluster: 0xC3
  }

  @impl true
  def start(_type, _args) do
    Logger.info("Starting ZCL")
    {:ok, self()}
  end
end
