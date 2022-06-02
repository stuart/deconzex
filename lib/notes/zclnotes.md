# Global
clusterRevision
attributeReportingStatus; 0 pending, 1 complete

Persistent data across power cycles but not factory reset.
configuration
APS group table, APS binding.


Frame format:

<<frame_control::8, manufacturere_code::16, transaction_id::8, command_id::8, payload::binary>>

<<frame_type::2, manufacturer_specific::1, direction::1, disable_default_response::1, reserved::3>> = frame_control

frame types : 0 global for all clusters, 1 specific or local to a cluster
direction : 1 server -> client, 0 client -> server
disable_default_response: 0 send default response, 1 only send response if there is an error. Set to 1 for all response frames sent
  as a result of previous frame.
manufacturere_code: identifies manufacturer
transaction_id ; sequence number.
command_id: if frame_type = 0
  non-reserved value from table 2-3
  else cluster specific command

frame payload varies according to command.

## Global Commands
table 2-3
@commands = %{
  0x00 => read_attributes,
  0x01 => read_attributes_response,
  0x02 => write_attributes,
  0x03 => write_attributes_undivided,
  0x04 => write_attributes_response,
  0x05 => write_attributes_no_response,
  0x06 => configure_reporting,
  0x07 => configure_reporting_response,
  0x08 => read_reporting_configuration,
  0x09 => read_reporting_configuration_response,
  0x0a => report_attributes,
  0x0b => default_response,
  0x0c => discover_attributes,
  0x0d => discover_attributes_response,
  0x0e => read_attributes_structured,
  0x0f => write_attributes_structured,
  0x10 => write_attributes_structured_response,
  0x11 => discover_commands_received,
  0x12 => discover_commands_received_response,
  0x13 => discover_commands_generated,
  0x14 => discover_commands_generated_response,
  0x15 => discover_attributes_extended,
  0x16 => discover_attributes_extended_response,
}


### Read Attributes

header <> <<attribute_id::16, attribute_id::16 etc...>>

### Read Attributes Response

header <> attribute status <> attribute status <> ...
<<attribute_id::16, unsupported_attribute::8>> = attribute status when error.
<<attribute_id::16, success::8, data_type::8, value::binary>> = attribute status.

### Write Attributes

header <> write attr data <> write attr data ...
<<attribute_id::16, data_type::8, value::binary>> = write attr data

### Write Attributes Undivided

same as write attributes but if any one cannot be written, none will be written.

### Write Attributes Response

statuses = success, unsupported_attribute, read_only, invalid_data_type, invalid_value, not_authorized
header <> <<status::8, attribute_id::116>> ...etc

Only failed status are included. If none fail then payload is just <<success::8>>

### Write Attributes No Response

same as write attributes but no response is sent.

### Configure Reporting
array struct set or bag cannot be reported.
header <> attr_reporting_configuration_record <> ...

configure to Send reports.
<<0::8 = direction, attribute_id::16, attribute_data_type::8, min_reporting_int::16, max_reporting_int::16, reportable_change::binary>>
The receiver of the Configure Reporting command SHALL Configure Reporting to send to each destination as resolved by the bindings for the cluster hosting the attributes to be reported.

configure to Recieve reports.
<<1::8 = direction, attribute_id::16, reportable_change::binary, timeout::16>>
This indicates to the receiver of the Configure Reporting command that the sender has configured its reporting mechanism to transmit reports and that, based on the current state of the sender’s bindings, the sender will send reports to the receiver.

min interval 0x0000 means no minimum.
max interval 0xFFFF means send no reports. 0x0000 means no interval but only on change.

if min = 0xffff and max = 0x0000 then set back to defaults.

reportable change is how much value changes in order to be reportabble, field is ommitted for discrete data types.

timeout 0x0000 means never time out
### Configure Reporting Response

statuses : unsupported_attribute, unreportable_attribute, invalid_data_type, invalid_value

<<status::8, direction::8, attribute_id::16>>
drop successful fields if all success just <<success::8>>

### Read Reporting Configuraton

header <> <<direction::8, attribute_id::16>>...etc

### Read Reporting Configuraton Response
same fields as configure reporting.
also status could be not_found if there is no reporting config for an attribute.

### Report Attributes
Fires according to Reporting configuration.
header <> <<attribute_id::16, data_type::8, value::16>>, ...etc  

Note on consolidation of timing. 2.5.11.2.5

### Default Response
header <> <<command::8, status::8>>

Sent when:
1. recieves unicast command that is not default response
2. no other response is sent for that transaction_id
3. disable_default_response is 0 or there is an error
4. the command's "effect on reciept" clause doesnt override this.

if command is not supported:
  unsupported_cluster_command
  unsupported_general_command
  UNSUP_MANUF_CLUSTER_COMMAND or UNSUP_MANUF_GENERAL_COMMAND
  Unsupported_cluter

### Discover Attributes
header <> <<start_attriute_id::16, max_attributes::8>>

### Discover Attributes Response

header <> <<discovery_complete::8>> <> <<attr_id::16, data_type::8>> ...etc  


### Read Attribbutes Structured Command
header <> <<attribute_id_1::16, selector_1, .... attribute_id_n, selector_n>>
<<indicator::8, index::16, index::16 ....>> = selector


### Cluster and endpoint discovery
Commissioning cluster client side.
Only one on a device.

0x0015 Comissioning

0 1 Startup parameters
2   Join parameters
3   End device parameters
4   Concentrator parameters

0,1 Startup parameters
eg. address, panid channel_mask,

Join params, scan attempts, time between scans etc.

End device, IndirectPollRate, ParentRetryThreshold
Concentrator for routing

Commands Recieved each has a response generated.
Restart Device
Save Startup Parameters
Restore Startup Parameters
Reset Startup Parameters

00-50-C2-77-10-00-00-00 Global commissioning Panid









#### Supervision Tree Structure for a Server

Application
(DeviceSupervisor) -> EndpointSupervisor -> Endpoints -> ClusterSupervisor -> Clusters
                   -> Global Cluster Supervisor -> Global Clusters
                   -> ZCL frame handler

Clusters store and retrieve their own data via cluster callback modules.
They may store data using Mnesia, ETS or DETS or otherwise.

Both local and remote data are accessed via the ZCL protocol.

driver receives ZCL frame.
   ZCL.frame handler passes the frame to the appropriate endpoint and cluster.
   Cluster calls it's callback module to process the request
   Cluster responds by messaging ZCL frame handler with a response
   ZCL frame handler frames up the response and passes it to Driver.

initiating a request:
   Client application calls endpoint with a request
   Endpoint Sends message to ZCL frame handler to build request frame
   Endpoint awaits response and passes it to client application

A coordinatior application may build a model of remote endpoints / clusters
Need to implement this. DETS or Mnesia?

### Supervision Tree Structure for a Client  
