defmodule Deconzex.APS.Request do
  defstruct request_id: 0,
            destination_address: Deconzex.Address.nwk(0x0000),
            destination_endpoint: 0,
            profile_id: 0,
            cluster_id: 0,
            source_endpoint: 0,
            asdu: <<>>
end
