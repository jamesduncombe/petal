defmodule Petal.Worker do
  @moduledoc """
  Handles the bulk of the Bloom filter operations.

  The general gist is to hash the payload, then modulo the number against the
  number of bits in the filter, then set that bit.
  """

  use GenServer
  use Bitwise

  require Logger

  @bit_size_of_field 64
  @byte_size_of_field div(@bit_size_of_field, 8)

  @hashers Application.fetch_env!(:petal, :hashers)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Client

  @doc """
  Add an `item` to the filter.
  """
  @spec add(item :: String.t()) :: :ok
  def add(item) do
    GenServer.call(__MODULE__, {:add, item})
  end

  @doc """
  Check for the existance of `item` in the filter.
  """
  @spec check(item :: String.t()) :: :ok | {:error, String.t()}
  def check(item) do
    GenServer.call(__MODULE__, {:check, item})
  end

  @doc """
  Inspect the current bloom filter contents.
  """
  @spec inspect() :: String.t()
  def inspect() do
    GenServer.call(__MODULE__, :inspect)
  end

  # Server

  def init(_args) do
    # Init the bitfield
    size_of_field = @byte_size_of_field
    bitfield = generate_n_bytes(size_of_field)

    {:ok, bitfield}
  end

  def handle_call({:add, item}, _from, bitfield) do
    # For each of the hash implementations build a
    new_bitfield =
      for hasher <- @hashers, reduce: bitfield do
        acc ->
          pos =
            hasher.hash(item)
            |> rem(@bit_size_of_field)

          # New bitfield with bit set in place
          n_bitfield = 1 <<< (@bit_size_of_field - pos - 1)

          # OR the fields together
          # Encode it back to binary
          encoded =
            :binary.decode_unsigned(acc)
            |> bor(n_bitfield)
            |> :binary.encode_unsigned()

          # Encode and pad it back to size
          pad_length = @byte_size_of_field - byte_size(encoded)
          pad_encoded_payload(pad_length, encoded)
      end

    # Push out bitfield back into the state
    {:reply, :ok, new_bitfield}
  end

  def handle_call({:check, item}, _from, bitfield) do
    ret =
      for hasher <- @hashers, into: [] do
        hasher.hash(item)
        |> rem(@bit_size_of_field)
        |> exists?(bitfield)
      end
      |> Enum.all?()
      |> format_return()

    {:reply, ret, bitfield}
  end

  def handle_call(:inspect, _from, bitfield) do
    bitfield
    |> pretty_print()
    |> IO.puts()

    {:reply, :ok, bitfield}
  end

  # Helpers

  # Pad the encoded payload
  defp pad_encoded_payload(0, encoded), do: encoded

  defp pad_encoded_payload(n, encoded) do
    padder = generate_n_bytes(n)
    padder <> encoded
  end

  defp generate_n_bytes(n) do
    for _n <- 1..n, into: <<>>, do: <<0>>
  end

  # Simply map from true|false to a decent return term
  defp format_return(true), do: :ok
  defp format_return(_false), do: {:error, "Not found"}

  # Check for the existance of the set bit from `offset` in `bitfield`
  @spec exists?(offset :: pos_integer(), bitfield :: binary()) :: true | false
  defp exists?(offset, bitfield) do
    case bitfield do
      <<_head::bitstring-size(offset), 1::1, _rest::bitstring>> ->
        true

      _ ->
        false
    end
  end

  # Pretty prints a the filter
  @spec pretty_print(bitfield :: bitstring()) :: String.t()
  defp pretty_print(bitfield) when is_bitstring(bitfield) do
    do_pretty_print(bitfield)
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
