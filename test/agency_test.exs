defmodule AgencyTest do
  use ExUnit.Case
  doctest Agency

  test "greets the world" do
    assert Agency.hello() == :world
  end
end
