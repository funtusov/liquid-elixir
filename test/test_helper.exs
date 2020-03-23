ExUnit.start(exclude: [:skip])

defmodule Liquid.Helpers do
  def render(text, data \\ %{}) do
    text |> Liquid.Template.parse() |> Liquid.Template.render(data) |> elem(1)
  end
end

defmodule Liquid.CustomFilters do
  def t(key, %{localization_json: localization, locale: locale}, params = %{"count" => count}) do
    locale = locale || "en"

    count =
      if is_binary(count) do
        case Integer.parse(count) do
          {i, _} -> i
          :error -> nil
        end
      else
        count
      end

    count = if count > 0, do: Gettext.Plural.plural(locale, count) + 1, else: 0

    value =
      case count do
        0 -> localization[key <> ".zero"]
        1 -> localization[key <> ".one"]
        2 -> localization[key <> ".two"]
        _ -> localization[key <> ".others"]
      end || localization[key <> ".others"] || key

    t(value, params)
  end

  def t(key, %{localization_json: localization}, params) do
    t(localization[key] || key, params)
  end

  def t(key, %{localization_json: localization}) do
    t(key, localization, %{})
  end

  def t(value, params) when params == %{}, do: value

  def t(value, params) do
    Enum.reduce(params, value, fn {key, value}, result ->
      Regex.replace(~r/{{\s*([^\s]+)\s*}}/, result, "{{\\g{1}}}")
      |> String.replace("{{#{key}}}", value)
    end)
  end

  def img_url("url", %{"gravity" => "bottom", "img_url" => "300x300"}) do
    "url"
  end

  def img_url("url", %{"img_url" => "master"}) do
    "master"
  end

  def img_url("url", _) do
    "no-size"
  end
end

Application.put_env(:liquid, :custom_filters, %{
  t: Liquid.CustomFilters,
  img_url: Liquid.CustomFilters
})
