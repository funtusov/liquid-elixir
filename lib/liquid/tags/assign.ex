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
      value =
        if String.starts_with?(from, "[") && String.ends_with?(from, "]") do
          from_parts =
            from
            |> String.slice(1, String.length(from) - 2)
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.map(fn value ->
              {value, _} =
                value
                |> Variable.create()
                |> Variable.lookup(context)

              value
            end)

          from_parts
        else
          {from_value, _} =
            from
            |> Variable.create()
            |> Variable.lookup(context)

          from_value
        end

      result_assign = context.assigns |> put_in(Enum.map(to, &Access.key(&1, %{})), value)
      context = %{context | assigns: result_assign}
      {output, context}
    end
  end
end
