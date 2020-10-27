defmodule PetalTest do
  use ExUnit.Case

  alias Petal.Worker

  test "add/1" do
    assert :ok == Worker.add("james")
  end

  test "check/1" do
    Worker.add("james")
    assert :ok == Worker.check("james")

    assert {:error, "Not found"} == Worker.check("jame")
  end
end
