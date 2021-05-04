defmodule Liquid.Appointer do
  @moduledoc "A module to assign context for `Liquid.Variable`"
  alias Liquid.{Matcher, Variable}

  @literals %{
    "nil" => nil,
    "null" => nil,
    "" => nil,
    "true" => true,
    "false" => false,
    "blank" => :blank?,
    "empty" => :empty?
  }

  @integer ~r/^(-?\d+)$/
  @float ~r/^(-?\d[\d\.]+)$/
  @start_quoted_string ~r/^#{Liquid.quoted_string()}/

  @doc "Assigns context for Variable and filters"
  def assign(%Variable{literal: literal, parts: [], filters: filters}, context) do
    {literal, filters |> assign_context(context.assigns)}
  end

  def assign(
        %Variable{literal: nil, parts: parts, filters: filters},
        %{assigns: assigns} = context
      ) do
    {match(context, parts), filters |> assign_context(assigns)}
  end

  @doc "Verifies matches between Variable and filters, data types and parts"
  def match(%{assigns: assigns} = context, [key | _] = parts) when is_binary(key) do
    case assigns do
      %{^key => _value} -> match(assigns, parts)
      _ -> Matcher.match(context, parts)
    end
  end

  def match(current, []), do: current

  def match(current, [name | parts]) when is_binary(name) do
    current |> match(name) |> Matcher.match(parts)
  end

  def match(current, key) when is_binary(key), do: Map.get(current, key)

  @doc """
  Makes `Variable.parts` or literals from the given markup
  """
  @spec parse_name(String.t()) :: map()
  def parse_name(name, opts \\ []) do
    re1 = ~r/([a-z][a-z_\d]*):\s*\'([^\']*)\'/
    re2 = ~r/([a-z][a-z_\d]*):\s*\"([^\"]*)\"/
    re3 = ~r/([a-z][a-z_\d]*):\s*(.*)/

    value =
      cond do
        Keyword.get(opts, :parametrized) && Regex.match?(re1, name) ->
          [[_, var, value]] = Regex.scan(re1, name)
          %{"t_value" => {"#{var}", value}}

        Keyword.get(opts, :parametrized) && Regex.match?(re2, name) ->
          [[_, var, value]] = Regex.scan(re2, name)
          %{"t_value" => {"#{var}", value}}

        Keyword.get(opts, :parametrized) && Regex.match?(re3, name) ->
          [[_, var, value]] = Regex.scan(re3, name)
          %{"t_assign" => {"#{var}", value}}

        Map.has_key?(@literals, name) ->
          Map.get(@literals, name)

        Regex.match?(@integer, name) ->
          String.to_integer(name)

        Regex.match?(@float, name) ->
          String.to_float(name)

        Regex.match?(@start_quoted_string, name) ->
          Regex.replace(Liquid.quote_matcher(), name, "")

        true ->
          Liquid.variable_parser() |> Regex.scan(name) |> List.flatten()
      end

    if is_list(value), do: %{parts: value}, else: %{literal: value}
  end

  defp assign_context([], _), do: []

  defp assign_context([head | tail], assigns) do
    [name, args] = head
    parse_opts = [parametrized: name == :t || name == :img_url || name == :file_url]

    args =
      for arg <- args do
        parsed = parse_name(arg, parse_opts)

        cond do
          Map.has_key?(parsed, :parts) ->
            assigns |> Matcher.match(parsed.parts) |> to_string()

          Map.has_key?(assigns, :__struct__) ->
            key = String.to_atom(arg)
            if Map.has_key?(assigns, key), do: to_string(assigns[key]), else: arg

          is_map(parsed[:literal]) && not is_nil(parsed[:literal]["t_value"]) ->
            {key, value} = parsed[:literal]["t_value"]
            %{"#{key}" => value}

          is_map(parsed[:literal]) && not is_nil(parsed[:literal]["t_assign"]) ->
            {key, value} = parsed[:literal]["t_assign"]

            value =
              cond do
                is_integer(value) -> value
                Regex.match?(~r/^[0-9]+\d*$/, value) -> value
                true -> assigns |> Matcher.match(String.split(value, ".")) |> to_str()
              end

            %{"#{key}" => value}

          true ->
            if Map.has_key?(assigns, arg), do: to_string(assigns[arg]), else: arg
        end
      end

    [[name, args] | assign_context(tail, assigns)]
  end

  defp to_str(map) when is_map(map), do: Jason.encode!(map)
  defp to_str(list) when is_list(list), do: Jason.encode!(list)
  defp to_str(v), do: to_string(v)
end
