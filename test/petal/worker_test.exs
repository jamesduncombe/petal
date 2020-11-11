defmodule Petal.WorkerTest do
  use ExUnit.Case

  alias Petal.Worker

  test "add/1" do
    assert Worker.add("james") == :ok
  end

  test "check/1" do
    Worker.add("james")
    assert Worker.check("james") == :ok
    assert Worker.check("jame") == {:error, "Not found"}
  end
end
