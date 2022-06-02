defmodule ZCL.ClusterTest.TestServerCluster do
  use ZCL.Cluster, %ZCL.Cluster{
    mode: :server,
    callback_module: __MODULE__,
    cluster_module: ZCL.Cluster.Basic,
    attribute_values: %{manufacturer: "Ling Standard Products"}
  }

  @impl true
  def factory_reset do
    "Factory Reset"
  end
end


defmodule ZCL.ClusterTest.TestClientCluster do
  use ZCL.Cluster, %ZCL.Cluster{
    mode: :client,
    callback_module: __MODULE__,
    cluster_module: ZCL.Cluster.Basic,
    attribute_values: %{}
  }
end


defmodule ZCL.ServerClusterTest do
  use ExUnit.Case
  alias ZCL.ClusterTest.TestServerCluster

  setup _ctx do
    {:ok, cluster} = TestServerCluster.start_link()
    [cluster: cluster]
  end

  test "can start a Basic cluster with this as a callback module", %{cluster: cluster} do
    assert is_pid(cluster)
  end

  test "can read the default ZCLVersion attribute from the cluster", %{cluster: cluster} do
    assert 2 == ZCL.Cluster.get_attribute(cluster, :zcl_version)
  end

  test "can read the set manufacturer attribute for the cluster", %{cluster: cluster} do
    assert "Ling Standard Products" == ZCL.Cluster.get_attribute(cluster, :manufacturer)
  end

  test "can write an attribute", %{cluster: cluster} do
    assert :ok == ZCL.Cluster.set_attribute(cluster, :physical_environment, 0x02)
    assert 0x02 == ZCL.Cluster.get_attribute(cluster, :physical_environment)
  end

  test "can call the factory_reset via the command_key", %{cluster: cluster} do
    assert "Factory Reset" == ZCL.Cluster.command(cluster, :factory_reset)
  end

  test "calls factory_reset via the command id", %{cluster: cluster} do
    assert "Factory Reset" == ZCL.Cluster.command(cluster, 0x00)
  end
end


defmodule ZCL.ClientClusterTest do
  use ExUnit.Case
  alias ZCL.ClusterTest.TestClientCluster

  setup _ctx do
    {:ok, cluster} = TestClientCluster.start_link()
    [cluster: cluster]
  end

  test "can start a Basic cluster with this as a callback module", %{cluster: cluster} do
    assert is_pid(cluster)
  end

  test "cannot read the default ZCLVersion attribute from the cluster", %{cluster: cluster} do
    assert {:error, :unknown_attribute} == ZCL.Cluster.get_attribute(cluster, :zcl_version)
  end

  test "cannot write an attribute", %{cluster: cluster} do
    assert {:error, :unknown_attribute} == ZCL.Cluster.set_attribute(cluster, :physical_environment, 0x02)
  end

  test "cannot call the factory_reset via the command_key", %{cluster: cluster} do
    assert {:error, :unknown_command} == ZCL.Cluster.command(cluster, :factory_reset)
  end
end
