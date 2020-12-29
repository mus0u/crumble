defmodule Crumble do
  @moduledoc """
  Documentation for `Crumble`.
  """

  @callback fields(atom) :: list

  defp behaviour_declaration do
    quote do
      @behaviour unquote(__MODULE__)

      # TODO: replace fields/1 callback with module attributes, which should
      # eliminate unnecessary View.render calls on relationships when they
      # aren't included in a given template's fields - this requires moving code
      # generation to the before_compile callback (as module attributes are not
      # yet available in __using__)

      # @before_compile unquote(__MODULE__)
      # Module.register_attribute(__MODULE__, :crumble_opts, persist: true)
      # Module.put_attribute(__MODULE__, :crumble_opts, unquote(crumble_opts))
    end
  end

  defp fallback_defs(templates) do
    unique_assign_names =
      templates
      |> Enum.map(fn {_template, {assign_name, _mult}} -> assign_name end)
      |> Enum.uniq()

    for assign_name <- unique_assign_names do
      quote do
        def render(_any, %{unquote(assign_name) => %Ecto.Association.NotLoaded{}}), do: false
      end
    end
  end

  defp template_defs(templates) do
    for {template, {assign_name, multiplicity}} <- templates do
      template_string = Atom.to_string(template) <> ".json"

      case multiplicity do
        :single ->
          quote do
            def render(unquote(template_string), %{unquote(assign_name) => object}) do
              Map.take(object, fields(unquote(template)))
            end
          end

        :list ->
          quote do
            def render(unquote(template_string), %{unquote(assign_name) => list}),
              do: Enum.map(list, &Map.take(&1, fields(unquote(template))))
          end
      end
    end
  end

  defmacro __using__([]) do
    raise """

    to use Crumble, you must specify which templates should be defined, along
    with the name of the related assign, and whether it represents a single
    object or a list of objects; then define the appropriate fields callback for
    each template, indicating which fields should be rendered for that template.

    for example:

      defmodule ExampleWeb.FooView do
        use Crumble, templates: [
          show: {:foo, :single},
          index: {:foos, :list},
          delete: {:foo, :single}
        ]

        @impl true
        def fields(:show), do: [:id, :name, :description]
        def fields(:index), do: [:id, :name]
        def fields(:delete), do: [:id]
      end
    """
  end

  defmacro __using__(crumble_opts) do
    templates = Keyword.get(crumble_opts, :templates, [])

    [behaviour_declaration() | fallback_defs(templates)] ++ template_defs(templates)
  end

  # TODO: move code generation to this callback instead, explained above

  # defmacro __before_compile__(_env) do
  #   crumble_opts = Module.get_attribute(env.module, :crumble_opts, [])
  #   templates = Keyword.get(crumble_opts, :templates, [])

  # fallbacks handled above, just generate regular template defs now
  #   template_defs(templates)
  # end
end
