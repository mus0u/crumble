defmodule CrumbleTest do
  use ExUnit.Case
  doctest Crumble

  test "greets the world" do
    assert Crumble.hello() == :world
  end
end
