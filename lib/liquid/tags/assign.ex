defmodule Liquid.Assign do
  alias Liquid.Variable
  alias Liquid.Tag
  alias Liquid.Context

  def syntax, do: ~r/([\w\-]+)\s*=\s*(.*)\s*/

  def parse(%Tag{} = tag, %Liquid.Template{} = template), do: {%{tag | blank: true}, template}

  def render(output, %Tag{markup: markup}, %Context{} = context) do
    [[_, to, from]] = Regex.scan(~r/([\w\-]+|[\w\-\.]+)\s*=\s*(.*)\s*/, markup)
    to = String.split(to, ".")

    locked =
      Enum.reduce(Context.locked_presets(), false, fn preset, acc ->
        acc == true || preset in to
      end)

    if locked do
      {output, context}
    else
      {from_value, context} =
        from
        |> Variable.create()
        |> Variable.lookup(context)

      result_assign = context.assigns |> put_in(Enum.map(to, &Access.key(&1, %{})), from_value)
      context = %{context | assigns: result_assign}
      {output, context}
    end
  end
end
