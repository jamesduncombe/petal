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
    size_of_field = floor(@bit_size_of_field / 8)
    bitfield = for _n <- 1..size_of_field, into: <<>>, do: <<0>>

    {:ok, bitfield}
  end

  def handle_call({:add, item}, _from, bitfield) do
    pos = hash(item)
    byte_n = Integer.floor_div(pos, 8)

    Logger.debug("Position in bitfield is: #{pos}")
    Logger.debug("Lives in byte: #{byte_n}")

    # New bitfield with bit set in place
    n_bitfield = 1 <<< (64 - pos)

    # OR the fields together
    bitfield = :binary.decode_unsigned(bitfield) ||| n_bitfield

    # Encode and pad it back to size
    encoded = :binary.encode_unsigned(bitfield)
    pad_length = 8 - floor(bit_size(encoded) / 8)
    padder = for _n <- 1..pad_length, into: <<>>, do: <<0>>
    new_bitfield = padder <> encoded

    # Push out bitfield back into the state
    {:reply, :ok, new_bitfield}
  end

  def handle_call({:check, item}, _from, bitfield) do
    offset_before_bit = hash(item) - 1

    case bitfield do
      <<_head::bitstring-size(offset_before_bit), 1::1, _rest::bitstring>> ->
        Logger.debug("Found")
        {:reply, :ok, bitfield}

      _ ->
        Logger.debug("Not found")
        {:reply, {:error, "Not found"}, bitfield}
    end
  end

  def handle_call(:inspect, _from, bitfield) do
    bitfield
    |> pretty_print()
    |> IO.puts()

    {:reply, :ok, bitfield}
  end

  # Helpers

  # Hashes the payload
  @spec hash(payload :: binary()) :: pos_integer()
  defp hash(payload) do
    payload
    |> :erlang.adler32()
    |> rem(@bit_size_of_field)
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
