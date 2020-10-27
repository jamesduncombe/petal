defmodule Petal.Hasher do
  @moduledoc """
  Define the behaviour of hashers.
  """

  @doc """
  Takes in a `payload` and hashes using the underlying implementation.
  """
  @callback hash(payload :: String.t()) :: pos_integer()
end
