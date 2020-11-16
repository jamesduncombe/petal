defmodule Petal.Bytes do
  @moduledoc """
  Collection of functions for working with byte arrays.
  """

  @doc """
  Return the size in bytes from bits.
  """
  @spec byte_size_of_field(size :: pos_integer()) :: pos_integer()
  def byte_size_of_field(size), do: div(size, 8)

  @doc """
  Round up the bits so that they are divisible by 8.
  """
  @spec ceil_bits(size :: pos_integer()) :: pos_integer()
  def ceil_bits(size), do: ceil(size / 8) * 8

  @doc ~S"""
  Pad the `encoded` payload to `n` bytes.

  ## Examples

      iex> Petal.Bytes.pad_encoded_payload(1, <<1>>)
      <<0, 1>>

  """
  @spec pad_encoded_payload(n :: pos_integer(), encoded :: binary()) :: binary()
  def pad_encoded_payload(0, encoded), do: encoded

  def pad_encoded_payload(n, encoded) do
    padder = generate_n_bytes(n)
    padder <> encoded
  end

  @doc """
  Generate a binary that is `n` bytes long.
  """
  @spec generate_n_bytes(n :: pos_integer()) :: binary()
  def generate_n_bytes(n) do
    for _n <- 1..n, into: <<>>, do: <<0>>
  end

  @doc ~S"""
  Check for the existance of the set bit from `offset` in `bitfield`.

  ## Examples

      iex> Petal.Bytes.exists?(23, <<0,0,1,0>>)
      true

  """
  @spec exists?(offset :: pos_integer(), bitfield :: binary()) :: true | false
  def exists?(offset, bitfield) do
    case bitfield do
      <<_head::bitstring-size(offset), 1::1, _rest::bitstring>> ->
        true

      _ ->
        false
    end
  end
end
