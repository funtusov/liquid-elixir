Code.require_file("../../test_helper.exs", __ENV__.file)

defmodule Liquid.AssignTest do
  use ExUnit.Case

  setup_all do
    Liquid.start()
    on_exit(fn -> Liquid.stop() end)
    :ok
  end

  test :assigned_variable do
    assert_result(".foo.", "{% assign foo = values %}.{{ foo[0] }}.", %{
      "values" => ["foo", "bar", "baz"]
    })

    assert_result(".bar.", "{% assign foo = values %}.{{ foo[1] }}.", %{
      "values" => ["foo", "bar", "baz"]
    })
  end

  test :assigned_variable_as_map do
    assert_result("Size:  M", "Size: {% assign variant.size = 'M'%} {{variant.size}}", %{
      "values" => ["foo", "bar", "baz"]
    })
  end

  test :assign_with_filter do
    assert_result(".bar.", "{% assign foo = values | split: ',' %}.{{ foo[1] }}.", %{
      "values" => "foo,bar,baz"
    })
  end

  test "assign string to var and then show" do
    assert_result("test", "{% assign foo = 'test' %}{{foo}}", %{})
  end

  describe "assign list" do
    test 'assign list / one string' do
      assert_result(".bar.", "{% assign foo = ['bar'] %}.{{foo[0]}}.", %{})
    end

    test 'assign list / one value' do
      assert_result(".foo-var.", "{% assign foo = [bar] %}.{{foo[0]}}.", %{"bar" => "foo-var"})
    end

    test 'assign list / multiple values' do
      assert_result(
        ".bar,foo-var,DeepMapValue,deep.map,112,-3.45,-42,3.14.",
        "{% assign foo = ['bar', bar, deep.map, 'deep.map', 112, -3.45, -42, deep.list[ind]] %}.{{foo | join: ','}}.",
        %{
          "bar" => "foo-var",
          "deep" => %{
            "map" => "DeepMapValue",
            "list" => ["one", 2, "three", 3.14]
          },
          "ind" => 3
        }
      )
    end
  end

  defp assert_result(expected, markup, assigns) do
    template = Liquid.Template.parse(markup)
    {:ok, result, _} = Liquid.Template.render(template, assigns)
    assert result == expected
  end
end
