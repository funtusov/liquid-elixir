defmodule Liquid.Context do
  defstruct assigns: %{},
            offsets: %{},
            registers: %{},
            presets: %{},
            blocks: [],
            extended: false,
            continue: false,
            break: false,
            template: nil,
            global_filter: nil,
            extra_tags: %{}

  def registers(context, key) do
    context.registers |> Map.get(key)
  end

  def locked_presets() do
    ["__private_labl_key__"]
  end

  def cleanup_presets(presets) do
    Map.drop(presets, ["__private_labl_key__"])
  end
end
