defmodule Petal.Hasher.Adler32 do
  @moduledoc """
  Wraps Erlangs Adler32 implementation.
  """

  @behaviour Petal.Hasher

  @impl true
  def hash(payload) do
    payload
    |> :erlang.adler32()
  end
end
