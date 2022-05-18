defmodule Deconzex.Address do
  @address_mode_ieee 0x03
  @address_mode_nwk 0x02
  @address_mode_group 0x01

  defstruct group: nil, nwk: nil, ieee: nil

  def mode(%Deconzex.Address{ieee: addr}) when is_number(addr) do
    :ieee
  end

  def mode(%Deconzex.Address{nwk: addr}) when is_number(addr) do
    :nwk
  end

  def mode(%Deconzex.Address{group: addr}) when is_number(addr) do
    :group
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
end
