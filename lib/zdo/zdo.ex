defmodule ZDO do
  # initialize the APS, NWK layser and SSP.
  # and any other zigbee device layer other than end applications residing over
  # endpints.
  # Assenbm config froom end applications to determine and implement the functions described.

  # PRIMARY DISCOVERY CACHE DEVICE
  # state machine: undiscovered, discovered registered unregistered

  # DEVICE AND SERVICE DISCOVERY mandatory

  # Mandatory functions
  #
  # NWK_addr_rsp

  # IEEE_addr_rsp

  # Node_desc_rsp

  # Power_desc_rsp

  # Simple_desc_rsp
  # Active_EP_rsp
  # Match_desc_rsp
  # Device_annce
  # Parent_annce
  # Parent_annce_rsp

  # SECURITY MANAGER

  # NETWORK MANAGER mandatory

  # BINDING MANAGER

  # NODE MANAGER - Coord + ruter only

  # GROUP MANAGER

  def nwk_addr_req(seq, destination_address, address, request_type \\ 0x00, start_index \\ 0x00) do
    request = %Deconzex.APS.Request{
      request_id: seq,
      destination_address: destination_address,
      destination_endpoint: 0,
      profile_id: 0,
      cluster_id: 0x0000,
      source_endpoint: 0,
      asdu: <<seq::8, address::64, request_type::8, start_index::8>>
    }
  end

  def nwk_addr_resp() do
  end
end
