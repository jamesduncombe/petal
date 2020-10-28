defmodule Petal.Bitfield do
  @moduledoc """
  Bitfield is the core structure about the Bloom filter.
  """

  import Petal.Bytes, only: [generate_n_bytes: 1, byte_size_of_field: 1]

  @typedoc "Defines the core type"
  @type t :: %__MODULE__{
          bitfield: binary(),
          size: pos_integer()
        }

  defstruct bitfield: <<>>, size: 64

  @doc """
  Creates a new Bitfield.
  """
  @spec new(size :: pos_integer()) :: t()
  def new(size) do
    bitfield =
      size
      |> byte_size_of_field()
      |> generate_n_bytes()

    %__MODULE__{bitfield: bitfield, size: size}
  end
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
