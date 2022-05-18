defmodule Deconzex.ProtocolTest do
  use ExUnit.Case

  describe "encode requests" do
    test "read_firmware_version_request" do
      # Tested manually on DeconzexII
      assert << 0x0D, 0x01, 0x00, 0x09, 0, 0, 0, 0, 0, 0xE9, 0xFF >> =
               Deconzex.Protocol.read_firmware_version_request(1)
    end

    test "read_parameter_request" do
      assert << 0x0A, 0x01, 0x00, 0x08, 0x00, 0x01, 0x00, 0x01, _, _ >> =
               Deconzex.Protocol.read_parameter_request(1, :mac_address)
    end

    test "read network key" do
      assert <<10, 1, 0, 9, 0, 2, 0, 24, 0, 210, 255>> =
               Deconzex.Protocol.read_parameter_request(1, :network_key)
    end

    test "write_parameter_request" do
      command = 0x0B
      seq = 0x02
      payload_len = 9
      frame_len = 7 + payload_len
      parameter_id = 0x01
      addr = 0x1234567890ABCDEF

      expected =
        << command::8, seq::8, 0x00, frame_len::16-little, payload_len::16-little,
          parameter_id::8, addr::64-little, 0xCE, 0xFB>>

      assert Deconzex.Protocol.write_parameter_request(seq, :mac_address, addr) == expected
    end

    test "write network key parameter request" do
      # Docs don't mention the extra byte before the network key...
      key = <<119, 7, 213, 234, 125, 195, 199, 249, 35, 248, 142, 224, 207, 150, 254, 27>>

      assert <<0x0B, 0x05, 0x00, 25, 0, 18, 0, 0x18, 0x00, 119, 7, 213, 234, 125, 195, 199,
               249, 35, 248, 142, 224, 207, 150, 254, 27, _crc::16 >> = Deconzex.Protocol.write_parameter_request(5, :network_key, key)
    end

    test "device_state_request" do
      assert << 0x07, 0x01, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF >> =
               Deconzex.Protocol.device_state_request(1)
    end

    test "create_or_join_network_request" do
      assert << 0x08, 0x05, 0x00, 0x06, 0x00, 0x02, 0xEB, 0xFF >> =
               Deconzex.Protocol.change_network_state(5, :net_connected)
    end

    test "leave_network_request" do
      assert << 0x08, 0x05, 0x00, 0x06, 0x00, 0x00, 0xED, 0xFF >> =
               Deconzex.Protocol.change_network_state(5, :net_offline)
    end

    test "read_received_data_request" do
      assert << 0x17, 0xFF, 0x00, 0x07, 0x00, 0x00, 0x00, 0xE3, 0xFE >> =
               Deconzex.Protocol.read_received_data_request(255)
    end

    test "read_received_data_request with flags" do
      assert << 0x17, 0xFF, 0x00, 0x08, 0x00, 0x01, 0x00, 0x04, 0xDD, 0xFE >> =
               Deconzex.Protocol.read_received_data_request(255, 4)
    end

    test "enqueue_send_data_request" do
      profile_id = 0x1234
      cluster_id = 0x5678
      asdu = <<0x01, 0x02, 0x03, 0x04, 0x05, 0x06>>
      dest_address = 0xCDEF
      dest_endpoint = 16
      source_endpoint = 2
      req_id = 12

      assert <<0x12, 0x10, 0x00, 28, 0x00, 0x13, 0x00, 12, 0x00, 0x02, 0xEF, 0xCD, 16, 0x34,
               0x12, 0x78, 0x56, 0x02, 0x06, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x04, 0x00,
               160, 252 >> =
               Deconzex.Protocol.enqueue_send_data_request(
                 16,
                 req_id,
                 %Deconzex.Address{nwk: dest_address},
                 dest_endpoint,
                 profile_id,
                 cluster_id,
                 source_endpoint,
                 asdu
               )
    end

    test "query_send_data_request" do
      assert << 0x04, 0x02, 0x00, 0x07, 0x00, 0x00, 0x00, 243::8, 255::8 >> =
               Deconzex.Protocol.query_send_data_request(2)
    end
  end

  describe "decode responses" do
    test "firmware version response" do
      frame = << 0x0D, 0x23, 0x00, 0x09, 0x00, 0x00, 0x07, 0x33, 0x26, 0x67, 0xFF >>

      assert [
               %{
                 command: :version,
                 seq: 0x23,
                 status: :success,
                 major_version: 0x26,
                 minor_version: 0x33,
                 platform: :conbee_II
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "read parameter response" do
      frame =
        << 0x0A, 0x12, 0x00, 0x10, 0x00, 0x09, 0x00, 0x01, 0x01, 0x02, 0x03, 0x04, 0x05,
          0x06, 0x07, 0x08, 0xA6, 0xFF >>

      assert [
               %{
                 command: :read_parameter,
                 seq: 0x12,
                 status: :success,
                 parameter: :mac_address,
                 value: 0x0807060504030201
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "read_parameter response returns invalid_value" do
      frame = <<10, 14, 7, 8, 0, 1, 0, 25, 191, 255>>

      assert [
               %{
                 command: :read_parameter,
                 seq: 14,
                 status: :invalid_value,
                 parameter: :link_key,
                 value: {:error, :cannot_deserialize_value}
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "unsupported read parameter response" do
      frame = << 0x0A, 0x13, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00, 0xD7, 0xFF >>

      assert [
               %{
                 command: :read_parameter,
                 seq: 0x13,
                 status: :unsupported
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "write parameter response" do
      frame = << 0x0B, 0x02, 0x00, 0x08, 0x00, 0x01, 0x00, 0x0E, 0xDC, 0xFF >>

      assert [
               %{
                 command: :write_parameter,
                 seq: 0x02,
                 status: :success,
                 parameter: :trust_center_address
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "unsupported write parameter response" do
      frame = <<0x0B, 0x02, 0x04, 0x08, 0x00, 0x01, 0x00, 0x03, 0xE3, 0xFF>>

      assert [
               %{
                 command: :write_parameter,
                 seq: 0x02,
                 status: :unsupported,
                 parameter: :unknown
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "device state response" do
      frame = << 0x07, 0x03, 0x00, 0x08, 0x00, 0xFF, 0x00, 0x00, 0xEF, 0xFE >>

      assert [
               %{
                 command: :device_state,
                 seq: 0x03,
                 status: :success,
                 network_state: :net_leaving,
                 apsde_data_flags: %{confirm: 1, indication: 1, request_free_slots: 1},
                 configuration_changed: 1
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "create or join network response" do
      frame = << 0x08, 0x10, 0x00, 0x06, 0x00, 0x02, 0xE0, 0xFF >>

      assert [
               %{
                 command: :change_network_state,
                 seq: 0x10,
                 status: :success,
                 network_state: :net_connected
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "leave network response" do
      frame = << 0x08, 0x10, 0x00, 0x06, 0x00, 0x02, 0xE0, 0xFF >>

      assert [
               %{
                 command: :change_network_state,
                 seq: 0x10,
                 status: :success,
                 network_state: :net_connected
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "received data notification" do
      frame = << 0x0E, 0x03, 0x00, 0x07, 0x00, 0xFF, 0x00, 0xE9, 0xFE >>

      assert [
               %{
                 command: :device_state_changed,
                 seq: 0x03,
                 status: :success,
                 network_state: :net_leaving,
                 apsde_data_flags: %{confirm: 1, indication: 1, request_free_slots: 1},
                 configuration_changed: 1
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "read received data response: address mode 01 (group)" do
      frame =
        <<0x17, 0x01, 0x00, 34, 0, 0, 0, 0b00001010, 0x01, 0xFFBB::16-little, 0x1, 0x02,
          0xF134::16-little, 0x02, 0xDED1::16-little, 0xF134::16-little, 0x04::16-little, 0x01,
          0x01, 0x01, 0x01, 0::16, 200::8, 0::32, -40::8, 0x5B, 0xF8>>

      assert [
               %{
                 command: :aps_data_indication,
                 seq: 1,
                 status: :success,
                 network_state: :net_connected,
                 apsde_data_flags: %{confirm: 0, indication: 1, request_free_slots: 0},
                 configuration_changed: 0,
                 destination_address: %Deconzex.Address{group: 0xFFBB},
                 destination_endpoint: 1,
                 source_address: %Deconzex.Address{nwk: 0xF134},
                 source_endpoint: 2,
                 profile_id: 0xDED1,
                 cluster_id: 0xF134,
                 asdu: <<0x01, 0x01, 0x01, 0x01>>,
                 lqi: 200,
                 rssi: -40
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "read received data response: address mode 02 (nwk)" do
      frame =
        << 0x17, 0x01, 0x00, 34, 0, 0, 0, 0b00001010, 0x02, 0xFFBB::16-little, 0x1, 0x02,
          0xF134::16-little, 0x02, 0xDED1::16-little, 0xF134::16-little, 0x04::16-little, 0x02,
          0x03, 0x04, 0x05, 0::16, 200::8, 0::32, -40::8, 0x50, 0xF8>>

      assert [
               %{
                 destination_address: %Deconzex.Address{nwk: 0xFFBB},
                 destination_endpoint: 1,
                 source_address: %Deconzex.Address{nwk: 0xF134},
                 source_endpoint: 2
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "read received data response: address mode 03 (ieee)" do
      frame =
        << 0x17, 0x01, 0x00, 46, 0, 0, 0, 0b00001010, 0x03, 0xFFBB0000::64-little, 0x1, 0x03,
          0xF1340000::64-little, 0x02, 0xDED1::16-little, 0xF134::16-little, 0x04::16-little,
          0x02, 0x03, 0x04, 0x05, 0::16, 200::8, 0::32, -40::8, 0x42, 0xF8>>

      assert [
               %{
                 destination_address: %Deconzex.Address{ieee: 0xFFBB0000},
                 destination_endpoint: 1,
                 source_address: %Deconzex.Address{ieee: 0xF1340000},
                 source_endpoint: 2
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "read received data response: address mode 04 (nwk and ieee)" do
      frame =
        << 0x17, 0x01, 0x00, 48, 0, 0, 0, 0b00001010, 0x03, 0xFFBB0000::64-little, 0x1, 0x04,
          0xCDEF::16-little, 0xF1340000::64-little, 0x02, 0xDED1::16-little, 0xF134::16-little,
          0x04::16-little, 0x02, 0x03, 0x04, 0x05, 0::16, 200::8, 0::32, -40::8, 0x83, 0xF6>>

      assert [
               %{
                 destination_address: %Deconzex.Address{ieee: 0xFFBB0000},
                 destination_endpoint: 1,
                 source_address: %Deconzex.Address{nwk: 0xCDEF, ieee: 0xF1340000},
                 source_endpoint: 2
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "mac poll indication with no life time" do
      frame =
        << 0x1C, 0x01, 0x00, 0x0C, 0x00, 0x04, 0x00, 0x02, 0xABCD::16-little, 0xE1,
          -30::8-signed, 0x96, 0xFC>>

      assert [
               %{
                 command: :mac_poll_indication,
                 seq: 1,
                 source_address: %Deconzex.Address{nwk: 0xABCD},
                 lqi: 225,
                 rssi: -30
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "mac poll indication with lifetime and ieee address" do
      frame =
        << 0x1C, 0x01, 0x00, 0x1A, 0x00, 0x13, 0x00, 0x03, 0x1234ABCD::64-little, 0xE1,
          -30::8-signed, 200::32-little, 1000::32-little, 0x7F, 0xFA>>

      assert [
               %{
                 command: :mac_poll_indication,
                 seq: 1,
                 source_address: %Deconzex.Address{ieee: 0x1234ABCD},
                 lqi: 225,
                 rssi: -30,
                 lifetime: 200,
                 timeout: 1000
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "mac beacon indication" do
      frame =
        << 0x1F, 0x40, 0x00, 22, 0x00, 0x00, 0x00, 0xCDEF::16-little, 0x1234::16-little,
          0x20, 0x01, 0x10, 0x11111111::64-little, 0x14, 0xFD>>

      assert [
               %{
                 command: :mac_beacon_indication,
                 seq: 0x40,
                 status: :success,
                 source_address: %Deconzex.Address{nwk: 0xCDEF},
                 nwk_panid: 0x1234,
                 nwk_channel: 0x20,
                 beacon_flags: 0x01,
                 update_id: 0x10,
                 data: <<17, 17, 17, 17, 0, 0, 0, 0>>
               }
             ] == Deconzex.Protocol.decode(frame)
    end

    test "enque send data response" do
      frame =
        << 0x12, 0x20, 0x00, 0x09, 0x00, 0x00, 0x02, 0b00000110, 0x23, 0x9A, 0xFF >>

      assert [
               %{
                 command: :aps_data_request,
                 seq: 0x20,
                 status: :success,
                 apsde_data_flags: %{confirm: 1, indication: 0, request_free_slots: 0},
                 configuration_changed: 0,
                 request_id: 35
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "query send data state response with address mode 1" do
      frame =
        << 0x04, 0x02, 0x00, 0x12, 0x00, 0x0B, 0x00, 0b00000110, 0x23, 0x01, 0xEF, 0xCD,
          0x02, 0x01, 0::32, 0xF4, 0xFD>>

      assert [
               %{
                 command: :aps_data_confirm,
                 seq: 2,
                 apsde_data_flags: %{confirm: 1, indication: 0, request_free_slots: 0},
                 configuration_changed: 0,
                 request_id: 35,
                 destination_address: %Deconzex.Address{group: 0xCDEF},
                 source_endpoint: 2,
                 confirm_status: 1
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "query send data state response with address mode 2" do
      frame =
        << 0x04, 0x02, 0x00, 0x13, 0x00, 0x0C, 0x00, 0b00000110, 0x23, 0x02, 0xEF, 0xCD,
          0x02, 0xF0, 0x01, 0::32, 0x01, 0xFD>>

      assert [
               %{
                 command: :aps_data_confirm,
                 seq: 2,
                 apsde_data_flags: %{confirm: 1, indication: 0, request_free_slots: 0},
                 configuration_changed: 0,
                 request_id: 35,
                 destination_address: %Deconzex.Address{nwk: 0xCDEF},
                 destination_endpoint: 2,
                 source_endpoint: 240,
                 confirm_status: 1
               }
             ] = Deconzex.Protocol.decode(frame)
    end

    test "query send data state response with address mode 3" do
      frame =
        << 0x04, 0x02, 0x00, 0x19, 0x00, 0xF2, 0x00, 0b00000110, 0x23, 0x03, 0x78, 0x56,
          0x34, 0x12, 0x78, 0x56, 0x34, 0x12, 0x02, 0xF0, 0x01, 0::32, 0xA8, 0xFB>>

      assert [
               %{
                 command: :aps_data_confirm,
                 seq: 2,
                 apsde_data_flags: %{confirm: 1, indication: 0, request_free_slots: 0},
                 configuration_changed: 0,
                 request_id: 35,
                 destination_address: %Deconzex.Address{ieee: 0x1234567812345678},
                 destination_endpoint: 2,
                 source_endpoint: 240,
                 confirm_status: 1
               }
             ] = Deconzex.Protocol.decode(frame)
    end
  end
end
