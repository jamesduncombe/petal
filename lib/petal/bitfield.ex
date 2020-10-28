defmodule Petal.Bitfield do
  @moduledoc """
  Bitfield is the core structure about the Bloom filter.
  """

  @typedoc "Defines the core type"
  @type t :: %__MODULE__{
          bitfield: binary(),
          size: pos_integer()
        }

  defstruct bitfield: <<>>, size: 64
end

defimpl String.Chars, for: Petal.Bitfield do
  def to_string(item) do
    "Bitsize: #{item.size} Field data: #{do_pretty_print(item.bitfield)}"
  end

  defp do_pretty_print(bitfield, accm \\ [])

  defp do_pretty_print(<<bit::1>> = _bitfield, accm) do
    [bit_set(bit) | accm]
    |> Enum.reverse()
    |> Enum.join()
  end

  defp do_pretty_print(<<bit::1, rest::bitstring>> = _bitfield, accm) do
    do_pretty_print(rest, [bit_set(bit) | accm])
  end

  defp bit_set(1), do: "1"
  defp bit_set(_not_set), do: "0"
end
