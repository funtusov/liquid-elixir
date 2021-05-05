defprotocol Liquid.Matcher do
  @fallback_to_any true
  @doc "Assigns context to values"
  def match(_, _)
  def match(_, _, _)
end

defimpl Liquid.Matcher, for: Liquid.Context do
  @doc """
  `Liquid.Matcher` protocol implementation for `Liquid.Context`
  """

  def match(current, parts), do: match(current, parts, %{})

  def match(current, [], _), do: current

  def match(%{assigns: assigns, presets: presets}, [key | _] = parts, _) when is_binary(key) do
    current =
      cond do
        assigns |> Map.has_key?(key) ->
          assigns

        presets |> Map.has_key?(key) ->
          presets |> Liquid.Context.cleanup_presets()

        !is_nil(Map.get(assigns, key |> Liquid.Atomizer.to_existing_atom())) ->
          assigns

        !is_nil(Map.get(presets, key |> Liquid.Atomizer.to_existing_atom())) ->
          presets |> Liquid.Context.cleanup_presets()

        is_map(assigns) and Map.has_key?(assigns, :__struct__) ->
          assigns

        true ->
          nil
      end

    Liquid.Matcher.match(current, parts, assigns)
  end
end

defimpl Liquid.Matcher, for: Map do
  def match(current, parts), do: match(current, parts, %{})

  def match(current, [], _), do: current

  # def match(current, ["size" | _]), do: current |> map_size

  def match(current, [<<?[, index::binary>> | parts], assigns) do
    index = index |> String.split("]") |> hd |> String.replace(Liquid.quote_matcher(), "")
    match(current, [index | parts], assigns)
  end

  def match(current, [name | parts], assigns) when is_binary(name) do
    current |> Liquid.Matcher.match(name, assigns) |> Liquid.Matcher.match(parts, assigns)
  end

  def match(current, key, _) when is_binary(key), do: current[key]
end

defimpl Liquid.Matcher, for: List do
  def match(current, parts), do: match(current, parts, %{})

  def match(current, [], _), do: current

  def match(current, ["size" | _], _), do: current |> Enum.count()

  def match(current, [<<?[, index::binary>> | parts], assigns) do
    index = index |> String.split("]") |> hd

    index =
      cond do
        Regex.match?(~r/^\d+$/, index) ->
          String.to_integer(index)

        index == "" ->
          0

        true ->
          case Liquid.Appointer.parse_name(index) do
            %{parts: parts} -> assigns |> Liquid.Matcher.match(parts, assigns)
            %{literal: literal} -> literal |> String.to_integer()
          end
      end

    if current == [] do
      nil
    else
      case Enum.fetch(current, index) do
        {:ok, value} -> Liquid.Matcher.match(value, parts, assigns)
        _ -> nil
      end
    end
  end

  def match(_, _, _) do
    nil
  end
end

defimpl Liquid.Matcher, for: Any do
  def match(current, parts), do: match(current, parts, %{})

  def match(nil, _, _), do: nil

  def match(current, [], _), do: current

  def match(true, _, _), do: nil

  @doc """
  Match size for strings:
  """
  def match(current, ["size" | _], _) when is_binary(current), do: current |> String.length()

  def match(current, [name | parts], assigns) when is_map(current) and is_binary(name) do
    current |> Liquid.Matcher.match(name, assigns) |> Liquid.Matcher.match(parts, assigns)
  end

  def match(current, key, _) when is_map(current) and is_binary(key) do
    key =
      if Map.has_key?(current, :__struct__),
        do: key |> Liquid.Atomizer.to_existing_atom(),
        else: key

    current |> Map.get(key)
  end

  def match(_current, key, _) when is_binary(key), do: nil
  def match(current, [key | _], _) when is_binary(current), do: key
end
