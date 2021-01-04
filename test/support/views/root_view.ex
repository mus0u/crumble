defmodule TestWeb.RootView do
  use Phoenix.View,
    root: "test/support/templates",
    namespace: TestWeb

  use Crumble,
    templates: [
      index: {:roots, :list},
      show: {:root, :single}
    ]

  def fields(:index), do: [:id, :foo, :bars]
  def fields(:show), do: [:id, :foo, :bars]
end
