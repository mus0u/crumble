defmodule TestWeb.FooView do
  use Phoenix.View,
    root: "test/support/templates",
    namespace: TestWeb

  use Crumble,
    templates: [
      index: {:foos, :list},
      show: {:foo, :single}
    ]

  def fields(:index), do: [:id, :name]
  def fields(:show), do: [:id, :name, :description]
end
