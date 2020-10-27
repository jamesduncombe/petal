defmodule Petal.Hasher.CRC32 do
  @moduledoc """
  Wraps Erlangs CRC32 implementation.
  """

  @behaviour Petal.Hasher

  @impl true
  def hash(payload) do
    payload
    |> :erlang.crc32()
  end
end
