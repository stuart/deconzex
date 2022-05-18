defmodule Deconzex.Slip do
  @behaviour Circuits.UART.Framing

  @slip_end 0xC0
  @slip_esc 0xDB
  @slip_esc_end 0xDC
  @slip_esc_esc 0xDD

  @moduledoc """
    A framer for Circuits.UART using the Seriail Line Internet Protocol (SLIP)
    as described in rfc1055.
  """

  def init(_args) do
    {:ok, <<>>}
  end

  def add_framing(data, rx_buffer) when is_binary(data) do
    {:ok, do_encode(data, <<>>), rx_buffer}
  end

  def frame_timeout(rx_buffer) do
    # On a timeout, just return whatever was in the buffer
    {:ok, [rx_buffer], <<>>}
  end

  def flush(:transmit, rx_buffer), do: rx_buffer
  def flush(:receive, _rx_buffer), do: <<>>
  def flush(:both, _rx_buffer), do: <<>>

  def remove_framing(data, rx_buffer) do
    process_data(rx_buffer <> data, [])
  end

  defp process_data(data, messages) do
    case do_decode(data, <<>>) do
      {:ok, <<>>} -> {:ok, messages}
      {:ok, message} -> {:ok, messages ++ [message], <<>>}
      {:ok, <<>>, rest} -> process_data(rest, messages)
      {:ok, message, rest} -> process_data(rest, messages ++ [message])
      {:in_frame, partial} -> {:in_frame, messages, partial}
    end
  end

  # ESC END
  defp do_decode(<<@slip_esc, @slip_esc_end, rest::binary>>, current_frame) do
    do_decode(rest, current_frame <> <<@slip_end>>)
  end

  # ESC ESC
  defp do_decode(<<@slip_esc, @slip_esc_esc, rest::binary>>, current_frame) do
    do_decode(rest, current_frame <> <<@slip_esc>>)
  end

  defp do_decode(<<>>, frame) do
    {:in_frame, frame}
  end

  # END
  defp do_decode(<<@slip_end>>, frame) do
    {:ok, frame}
  end

  defp do_decode(<<@slip_end, rest::binary>>, frame) do
    {:ok, frame, rest}
  end

  # Data Byte
  defp do_decode(<<byte::8, rest::binary>>, current_frame) do
    do_decode(rest, current_frame <> <<byte>>)
  end

  defp do_encode(<<>>, result) do
    <<@slip_end>> <> result <> <<@slip_end>>
  end

  defp do_encode(<<@slip_end, rest::binary>>, result) do
    do_encode(rest, result <> <<@slip_esc, @slip_esc_end>>)
  end

  defp do_encode(<<@slip_esc, rest::binary>>, result) do
    do_encode(rest, result <> <<@slip_esc, @slip_esc_esc>>)
  end

  defp do_encode(<<byte::8, rest::binary>>, result) do
    do_encode(rest, result <> <<byte>>)
  end
end
