defmodule CrumbleTest do
  use ExUnit.Case

  alias Ecto.Association.NotLoaded
  alias Test.Structs.Foo
  alias TestWeb.FooView

  doctest Crumble

  test "defines render automatically for each template" do
    index_structs = [%Foo{name: "struct 1"}, %Foo{name: "struct 2"}]

    assert FooView.render("index.json", foos: index_structs) == [
             %{id: "88888888-4444-4444-4444-bbbbbbbbbbbb", name: "struct 1"},
             %{id: "88888888-4444-4444-4444-bbbbbbbbbbbb", name: "struct 2"}
           ]

    show_struct = %Foo{name: "test struct", description: "super good"}

    assert FooView.render("show.json", foo: show_struct) == %{
             id: "88888888-4444-4444-4444-bbbbbbbbbbbb",
             name: "test struct",
             description: "super good"
           }
  end

  test "defines a NotLoaded fallback for each assign" do
    assert FooView.render("index.json", foos: %NotLoaded{}) == false
    assert FooView.render("show.json", foo: %NotLoaded{}) == false
  end
end
