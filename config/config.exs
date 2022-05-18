import Config

config :deconzex, :network, %{
  pan_id: 0xFF13,
  address: 0x0000,
  channel_mask: [11],
  security_mode: 3,
  predefined_nwk_pan_id: true,
  network_key: nil
}

config :deconzex, :timeout, 1000

config :deconzex, :device, %{
  serial_port: "ttyACM0",
  serial_speed: 38400,
  keepalive_s: 120
}
