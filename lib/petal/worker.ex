defmodule Petal.Worker do
  @moduledoc """
  Handles the bulk of the Bloom filter operations.

  The general gist is to hash the payload, then modulo the number against the
  number of bits in the filter, then set that bit.
  """

  use GenServer
  use Bitwise

  require Logger

  import Petal.Bytes

  alias Petal.Bitfield

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

  def init(args) do
    # Init the bitfield
    size_of_field = Keyword.get(args, :size, 64)
    state = Bitfield.new(size_of_field)

    {:ok, state}
  end

  def handle_call({:add, item}, _from, state) do
    # For each of the hash implementations build a
    new_bitfield =
      for hasher <- @hashers, reduce: state.bitfield do
        acc ->
          pos =
            hasher.hash(item)
            |> rem(state.size)

          # New bitfield with bit set in place
          n_bitfield = 1 <<< (state.size - pos - 1)

          # OR the fields together
          # Encode it back to binary
          encoded =
            :binary.decode_unsigned(acc)
            |> bor(n_bitfield)
            |> :binary.encode_unsigned()

          # Encode and pad it back to size
          pad_length = byte_size(state.bitfield) - byte_size(encoded)
          pad_encoded_payload(pad_length, encoded)
      end

    {:reply, :ok, %{state | bitfield: new_bitfield}}
  end

  def handle_call({:check, item}, _from, bitfield) do
    ret =
      for hasher <- @hashers, into: [] do
        hasher.hash(item)
        |> rem(bitfield.size)
        |> exists?(bitfield.bitfield)
      end
      |> Enum.all?()
      |> format_return()

    {:reply, ret, bitfield}
  end

  def handle_call(:inspect, _from, bitfield) do
    {:reply, {:ok, bitfield}, bitfield}
  end

  # Helpers

  # Simply map from true|false to a decent return term
  defp format_return(true), do: :ok
  defp format_return(_false), do: {:error, "Not found"}
end
