defmodule Petal.BytesTest do
  use ExUnit.Case
  doctest Petal.Bytes

  alias Petal.Bytes

  test "byte_size_of_field/1" do
    assert Bytes.byte_size_of_field(64) == 8
  end

  test "ceil_bits/1" do
    assert Bytes.ceil_bits(100) == 104
  end

  test "pad_encoded_payload/2" do
    payload = <<1, 2, 3>>

    assert Bytes.pad_encoded_payload(1, payload) == <<0, 1, 2, 3>>
  end

  test "generate_n_bytes/1" do
    assert Bytes.generate_n_bytes(2) == <<0, 0>>
  end

  test "exists?/2" do
    bitfield = <<0, 0, 1, 0>>
    # Should hit a bit at offset 24 (n + 1)
    assert Bytes.exists?(23, bitfield)
  end
end
