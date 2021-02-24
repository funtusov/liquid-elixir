defmodule Liquid.Capture do
  alias Liquid.Block
  alias Liquid.Context
  alias Liquid.Template

  def parse(%Block{} = block, %Template{} = template) do
    {%{block | blank: true}, template}
  end

  def render(output, %Block{markup: markup, nodelist: content}, %Context{} = context) do
    {block_output, context} = Liquid.Render.render([], content, context)

    markup = String.trim(markup, "'") |> String.trim("\"")
    to = String.split(markup, ".")

    result_assign =
      context.assigns
      |> put_in(Enum.map(to, &Access.key(&1, %{})), block_output |> Liquid.Render.to_text())

    context = %{context | assigns: result_assign}
    {output, context}
  end
end
