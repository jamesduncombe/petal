defmodule Petal.BitfieldTest do
  use ExUnit.Case

  alias Petal.Bitfield

  describe "new/1" do
    test "returns a new bitfield of size `x`" do
      bitfield = Bitfield.new(64)
      assert bitfield.size == 64
      assert bitfield.bitfield == <<0, 0, 0, 0, 0, 0, 0, 0>>
    end
  end

  test "to_string/1" do
    bitfield = Bitfield.new(8)
    assert to_string(bitfield) =~ ~r/Field data: 00000000/
  end
end
