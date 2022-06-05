defmodule ZCL.Cluster do
  @moduledoc """
     A process running a cluster.

     The behaviour ZCL.Cluster describes the behaviour required by
     clusters used on startup of a cluster process.

  """
  use GenServer

  @doc """
    The state of a cluster is stored as:
      mode: either :client or :server

      cluster_module: the name of a module implementing the ZCL.Cluster behaviour.

      attribute_values: the stored attribute values. Any attribute missing a value will
      return the default attribute value as described in `server_attributes` or `client_attributes`
      Any keys not in the appropriate attribute list be ignored.

      app_data: any application specific data that the application requires to have,
      stored on a per-cluster basis.
  """
  defstruct mode: :server,
            callback_module: nil,
            cluster_module: nil,
            attribute_values: %{},
            app_data: nil

  defmacro __using__(cluster_def) do
    quote do
      @behaviour Map.get(unquote(cluster_def), :cluster_module)

      def start_link() do
        ZCL.Cluster.start_link(unquote(cluster_def))
      end
    end
  end

  @type server :: GenServer.server()

  @doc """
    Call this to start a cluster within an applications supervision tree.

    mode: :client or :server
    cluster_module: a module implementing the ZCL.Cluster behaviour
    attribute_values: initial attribute values to be set.
    app_data: initial application data to be set.

    Returns {:ok, pid} or {:error, reason}
  """
  @spec start_link(%__MODULE__{}) :: {:ok, pid} | {:error, term}
  def start_link(%__MODULE__{} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  @doc """
    Set an attribute on the cluster.

    cluster: the pid of the cluster to set the attribute on.
    attribute_key: the key of the attribute to be set
    value: the value to set.

    Returns: :ok | {:error, :invalid_value} | {:error, :unknown_attribute}
  """
  @spec set_attribute(server(), atom, term) ::
          :ok | {:error, :invalid_value} | {:error, :unknown_attribute}
  def set_attribute(cluster, attribute_key, value) do
    GenServer.call(cluster, {:set_attribute, attribute_key, value})
  end

  @doc """
    Sets an attribute without checking for errors.
    If the attribute is invalid or not found this will raise an error.

    Returns :ok.
  """
  @spec set_attribute!(server(), atom, term) :: :ok
  def set_attribute!(cluster, attribute_key, value) do
    GenServer.cast(cluster, {:set_attribute, attribute_key, value})
  end

  @doc """
    Returns an attribute value from the cluster.

    cluster: the pid of the cluster to get the attribute from.
    attribute_key: the key of the attribute to get.
  """
  @spec get_attribute(server(), atom) :: term
  def get_attribute(cluster, attribute_key) do
    GenServer.call(cluster, {:get_attribute, attribute_key})
  end

  @doc """
    Sets the application specific data for this cluster.

  """
  @spec set_app_data(server, term) :: :ok
  def set_app_data(cluster, app_data) do
    :ok
  end

  @doc """
    Returns the application specific data for this cluster.
  """

  @spec get_app_data(server) :: term
  def get_app_data(cluster) do
  end

  def command(cluster, command_key, args \\ []) do
    GenServer.call(cluster, {:command, command_key, args})
  end

  # GenServer Callbacks
  @impl true
  def init(%__MODULE__{} = state) do
    values = initialize_attribute_values(state.mode, state.cluster_module, state.attribute_values)
    {:ok, %{state | attribute_values: values}}
  end

  @impl true
  def handle_call({:get_attribute, attribute_key}, _from, state) do
    {:reply, Map.get(state.attribute_values, attribute_key, {:error, :unknown_attribute}), state}
  end

  def handle_call({:set_attribute, attribute_key, value}, _from, state) do
    case validate(state.mode, state.cluster_module, attribute_key, value) do
      {:error, reason} ->
        {:reply, {:error, reason}, state}

      {:ok, value} ->
        {:reply, :ok,
         %{state | attribute_values: Map.put(state.attribute_values, attribute_key, value)}}
    end
  end

  def handle_call({:command, command_key, args}, _from, %__MODULE__{mode: :server} = state)
      when is_atom(command_key) do
    {:reply, Kernel.apply(state.callback_module, command_key, args), state}
  end

  def handle_call({:command, command_id, args}, _from, %__MODULE__{mode: :server} = state)
      when is_integer(command_id) do
    command_key = Map.fetch!(state.cluster_module.server_commands, command_id)
    {:reply, Kernel.apply(state.callback_module, command_key, args), state}
  end

  def handle_call({:command, command_key, args}, _from, %__MODULE__{mode: :client} = state)
      when is_atom(command_key) do
    case Enum.find(state.cluster_module.client_commands, fn({id, key}) -> key == command_key end) do
      {:ok, _} -> {:reply, Kernel.apply(state.callback_module, command_key, args), state}
      _ -> {:error, :unknown_command}
    end
  end

  def handle_call({:command, command_id, args}, _from, %__MODULE__{mode: :client} = state)
      when is_integer(command_id) do
    command_key = Map.fetch!(state.cluster_module.client_commands, command_id)
    {:reply, Kernel.apply(state.callback_module, command_key, args), state}
  end

  @impl true
  def handle_cast({:set_attribute, attribute_key, value}, state) do
    {:noreply, state}
  end

  defp initialize_attribute_values(:server, cluster_module, attribute_values) do
    Enum.reduce(cluster_module.server_attributes, attribute_values, fn attribute,
                                                                       attribute_values ->
      Map.put_new(attribute_values, attribute.key, attribute.default)
    end)
  end

  defp initialize_attribute_values(:client, cluster_module, attribute_values) do
    Enum.reduce(cluster_module.client_attributes, attribute_values, fn attribute,
                                                                       attribute_values ->
      Map.put_new(attribute_values, attribute.key, attribute.default)
    end)
  end

  defp validate(:server, cluster_module, attribute_key, value) do
    attributes = cluster_module.server_attributes()
    attribute = find_attribute(attributes, attribute_key)

    if(attribute != nil) do
      ZCL.Attribute.validate(attribute, value)
    else
      {:error, :unknown_attribute}
    end
  end

  defp validate(:client, cluster_module, attribute_key, value) do
    attributes = cluster_module.client_attributes()
    attribute = find_attribute(attributes, attribute_key)

    if(attribute != nil) do
      ZCL.Attribute.validate(attribute, value)
    else
      {:error, :unknown_attribute}
    end
  end

  defp find_attribute(attribute_list, key) do
    Enum.find(attribute_list, fn attribute -> attribute.key == key end)
  end
end
