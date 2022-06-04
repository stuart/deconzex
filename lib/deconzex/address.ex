defmodule Deconzex.Address do
  @address_mode_both 0x04
  @address_mode_ieee 0x03
  @address_mode_nwk 0x02
  @address_mode_group 0x01

  @type mode :: :group | :nwk | :ieee
  @type mode_id :: 1 | 2 | 3

  @type t :: {mode(), integer}

  @spec group(integer) :: t()
  def group(addr) do
    {:group, addr}
  end

  @spec nwk(integer) :: t()
  def nwk(addr) do
    {:nwk, addr}
  end

  @spec ieee(integer) :: t()
  def ieee(addr) do
    {:ieee, addr}
  end

  @spec mode(t()) :: mode()
  def mode({mode, _addr}) do
    mode
  end

  @spec addr(t()) :: integer
  def addr({_mode, addr}) do
    addr
  end

  @spec mode_id(mode()) :: mode_id()
  def mode_id(:group) do
    @address_mode_group
  end

  def mode_id(:nwk) do
    @address_mode_nwk
  end

  def mode_id(:ieee) do
    @address_mode_ieee
  end

  @spec serialize(t()) :: binary
  def serialize({:ieee, addr}) do
    <<@address_mode_ieee::8, addr::64-little>>
  end

  def serialize({:nwk, addr}) do
    <<@address_mode_nwk::8, addr::16-little>>
  end

  def serialize({:group, addr}) do
    <<@address_mode_group::8, addr::16-little>>
  end

  @spec deserialize(binary) :: {t(), binary} | {[t()], binary}
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
