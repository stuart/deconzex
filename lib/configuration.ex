defmodule Configuration.Device do
  defstruct nwk_address: 0,
            ieee_address: "",
            is_child: false,
            link_key: "",
            rx_counter: 0,
            tx_counter: 0
end

defmodule Configuration do
  defstruct metadata: %{version: 1, date: ""},
            coordinator_ieee: "",
            pan_id: "",
            security_level: 0,
            nwk_update_id: 0,
            channel: 11,
            channel_mask: [],
            network_key: %{},
            sequence_number: 0,
            frame_counter: 0,
            devices: []
end
