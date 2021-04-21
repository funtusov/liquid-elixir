defprotocol Liquid.Matcher do
  @fallback_to_any true
  @doc "Assigns context to values"
  def match(_, _)
end

defimpl Liquid.Matcher, for: Liquid.Context do
  @doc """
  `Liquid.Matcher` protocol implementation for `Liquid.Context`
  """

  def match(current, []), do: current

  def match(%{assigns: assigns, presets: presets}, [key | _] = parts) when is_binary(key) do
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

    Liquid.Matcher.match(current, parts)
  end
end

defimpl Liquid.Matcher, for: Map do
  def match(current, []), do: current

  # def match(current, ["size" | _]), do: current |> map_size

  def match(current, [<<?[, index::binary>> | parts]) do
    index = index |> String.split("]") |> hd |> String.replace(Liquid.quote_matcher(), "")
    match(current, [index | parts])
  end

  def match(current, [name | parts]) when is_binary(name) do
    current |> Liquid.Matcher.match(name) |> Liquid.Matcher.match(parts)
  end

  def match(current, key) when is_binary(key), do: current[key]
end

defimpl Liquid.Matcher, for: List do
  def match(current, []), do: current

  def match(current, ["size" | _]), do: current |> Enum.count()

  def match(current, [<<?[, index::binary>> | parts]) do
    index = index |> String.split("]") |> hd |> String.to_integer()

    if current == [] do
      nil
    else
      case Enum.fetch(current, index) do
        {:ok, value} -> Liquid.Matcher.match(value, parts)
        _ -> nil
      end
    end
  end

  def match(_, _) do
    nil
  end
end

defimpl Liquid.Matcher, for: Any do
  def match(nil, _), do: nil

  def match(current, []), do: current

  def match(true, _), do: nil

  @doc """
  Match size for strings:
  """
  def match(current, ["size" | _]) when is_binary(current), do: current |> String.length()

  def match(current, [name | parts]) when is_map(current) and is_binary(name) do
    current |> Liquid.Matcher.match(name) |> Liquid.Matcher.match(parts)
  end

  def match(current, key) when is_map(current) and is_binary(key) do
    key =
      if Map.has_key?(current, :__struct__),
        do: key |> Liquid.Atomizer.to_existing_atom(),
        else: key

    current |> Map.get(key)
  end

  def match(_current, key) when is_binary(key), do: nil
  def match(current, [key | _]) when is_binary(current), do: key
end
