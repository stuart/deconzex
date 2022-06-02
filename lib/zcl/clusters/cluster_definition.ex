defmodule ZCL.ClusterDefinition do
    @doc """
      Returns the cluster_id of the cluster.
    """
    @callback id() :: integer

    @doc """
      Returns the human readable name of the cluster.
    """
    @callback name() :: string

    @doc """
      Returns a list of cluster modules that this cluster depends on. An endpoint
      implementing this cluster must also implement these clusters.
    """
    @callback dependencies() :: [atom]

    @doc """
      Returns a list of the attributes exposed by a server/output cluster.
    """
    @callback server_attributes() :: [ZCL.Attribute.t()]

    @doc """
      Returns a list of the attributes exposed by a client/input cluster.
    """
    @callback client_attributes() :: [ZCL.Attribute.t()]

    @doc """
      Returns an MFA that must be implemented in the application code to handle
      server side commands.

      There will be one per server command code.
      The argument is the server command code integer as defined in the ZCL specification
      for the cluster.
    """
    @callback server_command(integer) :: {:ok, mfa} | {:error, term}

    @doc """
      Returns an MFA that must be implemented in the application code to handle
      client side commands.

      There will be one per client command code.
      The argument is the client command code integer as defined in the ZCL specification
      for the cluster.
    """
    @callback client_command(integer) :: {:ok, term} | {:error, term}

    def __using__ _args do
      quote do
        @behaviour ZCL.ClusterDefinition

      end
    end
end