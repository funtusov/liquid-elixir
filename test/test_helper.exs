ExUnit.start(exclude: [:skip])

defmodule Liquid.Helpers do
  def render(text, data \\ %{}) do
    text |> Liquid.Template.parse() |> Liquid.Template.render(data) |> elem(1)
  end
end

defmodule Liquid.CustomFilters do
  def t(
        key,
        %{localization: %{theme: localization, dynamic: dynamic}, locale: locale},
        params = %{"count" => count}
      ) do
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
        0 -> localization[key <> ".zero"] || dynamic[key <> ".zero"]
        1 -> localization[key <> ".one"] || dynamic[key <> ".one"]
        2 -> localization[key <> ".two"] || dynamic[key <> ".two"]
        _ -> localization[key <> ".others"] || dynamic[key <> ".others"]
      end || localization[key <> ".others"] || dynamic[key <> ".others"] || key

    t(value, params)
  end

  def t(key, %{localization: %{theme: localization, dynamic: dynamic}}, params) do
    t(localization[key] || dynamic[key] || key, params)
  end

  def t(key, %{localization: %{theme: localization, dynamic: dynamic}}) do
    t(key, localization || dynamic[key], %{})
  end

  def t(value, params) when params == %{}, do: value

  def t(value, params) do
    Enum.reduce(params, value, fn {key, value}, result ->
      Regex.replace(~r/{{\s*([^\s]+)\s*}}/, result, "{{\\g{1}}}")
      |> String.replace("{{#{key}}}", value)
    end)
  end

  def img_url("url", %{"sharpen" => "2", "img_url" => "300x300"}, _context) do
    "sharpen-2"
  end

  def img_url("url", %{"sharpen" => "0.5", "img_url" => "300x300"}, _context) do
    "sharpen-0.5"
  end

  def img_url("url", %{"sharpen" => "1.5", "img_url" => "300x300"}, _context) do
    "sharpen-1.5"
  end

  def img_url("url", %{"gravity" => "bottom", "img_url" => "300x300"}, _context) do
    "url"
  end

  def img_url("url", %{"img_url" => "master"}, _context) do
    "master"
  end

  def img_url("url", %{"img_url" => "400x400"}, _context) do
    "url"
  end

  def img_url("url", _, _) do
    "no-size"
  end

  def file_url("url", %{"gravity" => "bottom", "file_url" => "300x300"}, _context) do
    "url"
  end

  def file_url("url", %{"file_url" => "master"}, _context) do
    "master"
  end

  def file_url("url", _, _) do
    "no-size"
  end

  def color_to_hex(color, colors) do
    "#" <> colors[color]
  end
end

Application.put_env(:liquid, :custom_filters, %{
  t: Liquid.CustomFilters,
  img_url: Liquid.CustomFilters,
  file_url: Liquid.CustomFilters,
  color_to_hex: Liquid.CustomFilters
})
