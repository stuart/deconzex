defmodule Deconzex.Address do
  @moduledoc """
    Handles the various address modes used by the protocol.
    The internal representation is `{mode, address}` but don't
    rely on this as it may change.
  """

  @address_mode_both 0x04
  @address_mode_ieee 0x03
  @address_mode_nwk 0x02
  @address_mode_group 0x01

  def group(addr) do
    {:group, addr}
  end

  def nwk(addr) do
    {:nwk, addr}
  end

  def ieee(addr) do
    {:ieee, addr}
  end

  def mode({mode, _addr}) do
    mode
  end

  def addr({_mode, addr}) do
    addr
  end

  def mode_id(:group) do
    @address_mode_group
  end

  def mode_id(:nwk) do
    @address_mode_nwk
  end

  def mode_id(:ieee) do
    @address_mode_ieee
  end

  def serialize({:ieee, addr}) do
    <<@address_mode_ieee::8, addr::64-little>>
  end

  def serialize({:nwk, addr}) do
    <<@address_mode_nwk::8, addr::16-little>>
  end

  def serialize({:group, addr}) do
    <<@address_mode_group::8, addr::16-little>>
  end

  def deserialize(<<@address_mode_group::8, addr::16-little, rest::binary>>) do
    {{:group, addr}, rest}
  end

  def deserialize(<<@address_mode_nwk::8, addr::16-little, rest::binary>>) do
    {{:nwk, addr}, rest}
  end

  def deserialize(<<@address_mode_ieee::8, addr::64-little, rest::binary>>) do
    {{:ieee, addr}, rest}
  end

  def deserialize(
        <<@address_mode_both::8, short_addr::16-little, extended_addr::64-little, rest::binary>>
      ) do
    {[{:nwk, short_addr}, {:ieee, extended_addr}], rest}
  end
end
