defmodule MercadinhoTest do
  use ExUnit.Case
  doctest Mercadinho

  test "greets the world" do
    assert Mercadinho.hello() == :world
  end
end
