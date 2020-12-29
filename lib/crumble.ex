defmodule Crumble do
  @moduledoc """
  Documentation for `Crumble`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Crumble.hello()
      :world

  """

  @callback fields(atom) :: list

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

    unique_assign_names =
      templates
      |> Enum.map(fn {_template, {assign_name, _mult}} -> assign_name end)
      |> Enum.uniq()

    [
      quote do
        @behaviour unquote(__MODULE__)
        # @before_compile unquote(__MODULE__)
        # Module.register_attribute(__MODULE__, :crumble_opts, persist: true)
        # Module.put_attribute(__MODULE__, :crumble_opts, unquote(crumble_opts))
      end
    ] ++
      for assign_name <- unique_assign_names do
        quote do
          def render(_any, %{unquote(assign_name) => %Ecto.Association.NotLoaded{}}), do: false
        end
      end ++
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

  # defmacro __before_compile__(_env) do
  #   crumble_opts = Module.get_attribute(env.module, :crumble_opts, [])
  #   templates = Keyword.get(crumble_opts, :templates, [])

  #   unique_assign_names =
  #     templates
  #     |> Enum.map(fn {_template, {assign_name, _mult}} -> assign_name end)
  #     |> Enum.uniq()

  #   for assign_name <- unique_assign_names do
  #     quote do
  #       def render(_any, %{unquote(assign_name) => %Ecto.Association.NotLoaded{}}), do: false
  #     end
  #   end ++
  #     for {template, {assign_name, multiplicity}} <- templates do
  #       template_string = Atom.to_string(template) <> ".json"

  #       case multiplicity do
  #         :single ->
  #           quote do
  #             def render(unquote(template_string), %{unquote(assign_name) => object}) do
  #               Map.take(object, fields(unquote(template)))
  #             end
  #           end

  #         :list ->
  #           quote do
  #             def render(unquote(template_string), %{unquote(assign_name) => list}),
  #               do: Enum.map(list, &Map.take(&1, fields(unquote(template))))
  #           end
  #       end
  #     end
  # end
end
