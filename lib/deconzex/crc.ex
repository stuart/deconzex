defmodule Deconzex.Crc do
  use Bitwise

  @moduledoc """
    CRC handling for the Conbee device serial protocol.
  """
  @spec add_crc(binary) :: binary
  def add_crc(frame) do
    frame <> crc(frame)
  end

  # Checks and strips off the CRC
  @spec check_crc(binary) ::
          {:ok, binary} | {:error, :invalid_crc, %{expected: binary, recieved: binary}}
  def check_crc(frame_with_crc) do
    crc = :binary.part(frame_with_crc, {byte_size(frame_with_crc), -2})
    frame = :binary.part(frame_with_crc, {0, byte_size(frame_with_crc) - 2})

    case crc(frame) == crc do
      true ->
        {:ok, frame}

      false ->
        {:error, :invalid_crc, %{expected: crc(frame), received: crc}}
    end
  end

  @spec crc(binary) :: binary
  def crc(frame) do
    crc = do_crc(frame, 0)
    crc = bnot(crc) + 1
    <<crc::16-little>>
  end

  defp do_crc(<<>>, crc) do
    crc
  end

  defp do_crc(<<byte::8, rest::binary>>, crc) do
    do_crc(rest, crc + byte)
  end
end
