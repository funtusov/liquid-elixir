defmodule Liquid.TranslationFilterTest do
  use ExUnit.Case, async: false
  alias Liquid.Template

  test "get by index by variable" do
    expected = "b"
    markup = "{{foo[bar]}}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"foo" => ["a", "b", "c"], "bar" => 1}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "get by index by variable inside variable" do
    expected = "c"
    markup = "{{foo[bar[1]]}}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{"foo" => ["a", "b", "c"], "bar" => [1, 2, 3]}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / no size" do
    expected = "no-size"
    markup = "{{ 'url' | img_url, gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "file_url / no size" do
    expected = "no-size"
    markup = "{{ 'url' | file_url, gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / no size / master" do
    expected = "master"
    markup = "{{ 'url' | img_url: \"master\", gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "file_url / no size / master" do
    expected = "master"
    markup = "{{ 'url' | file_url: \"master\", gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url" do
    expected = "url"
    markup = "{{ 'url' | img_url: '300x300', gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / var" do
    expected = "url"
    markup = "{{ 'url' | img_url: size, gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"size" => "300x300"}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / var with underscore" do
    expected = "url"
    markup = "{{ 'url' | img_url: size_300, gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"size_300" => "300x300"}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / string digit value" do
    expected = "sharpen-2"
    markup = "{{ 'url' | img_url: size_300, sharpen: 002 }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"size_300" => "300x300"}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / integer value" do
    expected = "sharpen-2"
    markup = "{{ 'url' | img_url: size_300, sharpen: 2 }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"size_300" => "300x300"}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / float value" do
    expected = "sharpen-0.5"
    markup = "{{ 'url' | img_url: size_300, sharpen: 0.5 }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"size_300" => "300x300"}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / float value / 2" do
    expected = "sharpen-1.5"
    markup = "{{ 'url' | img_url: size_300, sharpen: 1.5 }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"size_300" => "300x300"}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / array value" do
    expected = "url"
    markup = "{{ 'url' | img_url: ssss[0] }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"ssss" => ["400x400"]}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "file_url" do
    expected = "url"
    markup = "{{ 'url' | file_url: '300x300', gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "img_url / variable" do
    expected = "url"
    markup = "{{ product.image_url | img_url: '300x300', gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"product" => %{"image_url" => "url"}}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "file_url / variable" do
    expected = "url"
    markup = "{{ product.image_url | file_url: '300x300', gravity: 'bottom' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <- Template.render(template, %{"product" => %{"image_url" => "url"}}) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with data key" do
    expected = "Product Localized Name"
    markup = "{{product.name | t: name: 'Andy', title: title, mama: 'papa' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{},
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             },
             "product" => %{"name" => "product_name"}
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with data key / no params" do
    expected = "Product Localized Name"
    markup = "{{product.name | t}}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{},
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             },
             "product" => %{"name" => "product_name"}
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with data key / wrong data" do
    expected = "name"
    markup = "{{product.name | t}}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{},
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             },
             "product" => "product_name"
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders" do
    expected = "layout.title.name"
    markup = "{{ 'layout.title.name' | t: name: 'Andy', title: title, mama: 'papa' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{}
               }
             }
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / 2" do
    expected = "[papa] Hello wip Andy!"
    markup = "{{ 'layout.title.name' | t: name: 'Andy', title: title, mama: 'papa' }}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{},
                 "dynamic" => %{"layout.title.name" => "[{{mama}}] Hello {{title}} {{name}}!"}
               }
             },
             "title" => "wip"
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / 2 / liquid syntax variants" do
    expected = "[papa] Hello wip Andy!"

    assigns = %{
      "__private_labl_key__" => %{
        "localization" => %{
          "theme" => %{
            "layout.title.name" => "[{{mama}}] Hello {{title}} {{name}}!"
          }
        }
      },
      "title" => "wip"
    }

    [
      {1,
       Template.parse("{{ 'layout.title.name' | t: name: 'Andy', title: title, mama: 'papa' }}")},
      {2, Template.parse("{{'layout.title.name'|t:name:'Andy',title:title,mama:'papa'}}")},
      {3,
       Template.parse("{{'layout.title.name'   |  t:name:'Andy',title:title,  mama:'papa' }}")},
      {4, Template.parse("{{'layout.title.name'|t:name:'Andy'  ,title: title,  mama: 'papa'}}")},
      {5,
       Template.parse("{{     'layout.title.name' |t:name:'Andy',  title:title,mama: 'papa'}}")}
    ]
    |> Enum.each(fn {case, template} ->
      with {:ok, result, _} <- Template.render(template, assigns) do
        if result != expected, do: IO.puts("Case #{case}")
        assert result == expected
      else
        {:error, message, _} ->
          if message != expected, do: IO.puts("Case #{case}")
          assert message == expected
      end
    end)
  end

  test "translation with placeholders / 2 / naming variants" do
    [
      {
        1,
        Template.parse("{{ 'layout.title.name' | t: name: 'Andy', title: title, mama: 'papa' }}"),
        %{
          "__private_labl_key__" => %{
            "localization" => %{
              "theme" => %{
                "layout.title.name" => "[{{mama}}] Hello {{title}} {{name}}!"
              }
            }
          },
          "title" => "wip"
        },
        "[papa] Hello wip Andy!"
      },
      {
        2,
        Template.parse("{{ 'layout' | t: name: 'Andy', title: title, mama: 'papa' }}"),
        %{
          "__private_labl_key__" => %{
            "localization" => %{
              "theme" => %{
                "layout" => "[{{mama}}] Hello {{title}} {{name}}!"
              }
            }
          },
          "title" => "wip"
        },
        "[papa] Hello wip Andy!"
      },
      {
        3,
        Template.parse(
          "{{ 'layout' | t: name: 'Andy', title: layout.title.index, mama: layout.title.second }}"
        ),
        %{
          "__private_labl_key__" => %{
            "localization" => %{
              "theme" => %{
                "layout" => "[{{mama}}] Hello {{title}} {{name}}!"
              },
              "dynamic" => %{"product_name" => "Product Localized Name"}
            }
          },
          "layout" => %{
            "title" => %{
              "index" => "Title!",
              "second" => "subtitle..."
            }
          }
        },
        "[subtitle...] Hello Title! Andy!"
      },
      {
        4,
        Template.parse(
          "{{ 'layout' | t: name: 'Andy', title: layout.title_index, mama: layout_title.second }}"
        ),
        %{
          "__private_labl_key__" => %{
            "localization" => %{
              "theme" => %{
                "layout" => "[{{mama}}] Hello {{title}} {{name}}!"
              },
              "dynamic" => %{"product_name" => "Product Localized Name"}
            }
          },
          "layout" => %{
            "title_index" => "Title!"
          },
          "layout_title" => %{
            "second" => "subtitle..."
          }
        },
        "[subtitle...] Hello Title! Andy!"
      }
    ]
    |> Enum.each(fn {case, template, assigns, expected} ->
      with {:ok, result, _} <- Template.render(template, assigns) do
        if result != expected, do: IO.puts("Case #{case}")
        assert result == expected
      else
        {:error, message, _} ->
          if message != expected, do: IO.puts("Case #{case}")
          assert message == expected
      end
    end)
  end

  test "translation with placeholders / 3" do
    expected = "[papa] Hello wip Andy!"
    markup = "{{ \"layout.title.name\" | t: name: \"Andy\", title: title, mama: \"papa\" }}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "layout.title.name" => "[{{mama}}] Hello {{title}} {{name}}!"
                 },
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             },
             "title" => "wip"
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / 4" do
    expected = "22"

    markup =
      "{{ \"layout.title.name\" | t: name: \"Andy\", title: title, mama: \"papa\" | downcase | size | upcase }}"

    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "layout.title.name" => "[{{mama}}] Hello {{title}} {{name}}!"
                 },
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             },
             "title" => "wip"
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / 5" do
    expected = "[papa] Hello &quot;Title&quot; Andy!"
    markup = "{{ \"layout.title.name\" | t: name: \"Andy\", title: '\"Title\"', mama: \"papa\" }}"
    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "layout.title.name" => "[{{mama}}] Hello {{title}} {{name}}!"
                 },
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             },
             "title" => "wip"
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / 6" do
    expected = "[papa] Hello \"Title\" Andy!"

    markup =
      "{{ \"layout.title.name_html\" | t: name: \"Andy\", title: '\"Title\"', mama: \"papa\" }}"

    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "layout.title.name_html" => "[{{mama}}] Hello {{title}} {{name}}!"
                 },
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             },
             "title" => "wip"
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / 7" do
    expected = "[papa] Hello Title Andy!"

    markup = "{{ \"layout.title.name\" | t: name: 'Andy', title: \"Title\", mama: 'papa' }}"

    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "layout.title.name" => "[{{mama}}] Hello {{title}} {{name}}!"
                 }
               }
             },
             "title" => "wip"
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / escaped parametrized html" do
    expected =
      "      \n      " <>
        "<h1>Welcome to my store. Please contact \n        " <>
        "&lt;a href=&quot;https://support.mystore.com&quot;&gt;support&lt;/a&gt;\n       " <>
        "should you need any assistance." <>
        "</h1>\n"

    markup = """
          {% capture link %}
            <a href="https://support.mystore.com">{{ 'layout.header.support_link' | t }}</a>
          {% endcapture %}
          <h1>{{ 'layout.header.welcome' | t: link: link }}</h1>
    """

    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "layout.header.support_link" => "support",
                   "layout.header.welcome" =>
                     "Welcome to my store. Please contact {{ link }} should you need any assistance."
                 },
                 "dynamic" => %{"product_name" => "Product Localized Name"}
               }
             }
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / not escaped parametrized html" do
    expected =
      "      \n      " <>
        "<h1>Welcome to my store. Please contact \n        " <>
        "<a href=\"https://support.mystore.com\">support</a>\n       " <>
        "should you need any assistance." <>
        "</h1>\n"

    markup = """
          {% capture link %}
            <a href="https://support.mystore.com">{{ 'layout.header.support_link' | t }}</a>
          {% endcapture %}
          <h1>{{ 'layout.header.welcome_html' | t: link: link }}</h1>
    """

    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "layout.header.support_link" => "support",
                   "layout.header.welcome_html" =>
                     "Welcome to my store. Please contact {{ link }} should you need any assistance."
                 }
               }
             }
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end

  test "translation with placeholders / pluralization" do
    expected =
      "<h1>one (1) order</h1>" <>
        "<h1>0: no orders</h1>" <>
        "<h1>0: no orders</h1>" <>
        "<h1>one (1) order</h1>" <>
        "<h1>one (1) order</h1>" <>
        "<h1>two orders [2]</h1>" <>
        "<h1>two orders [2]</h1>" <>
        "<h1>two orders [3]</h1>" <>
        "<h1>two orders [3]</h1>"

    markup =
      "<h1>{{ 'customer.orders.order_count' | t: count: customers.orders.count }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: 0 }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: \"0\" }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: 1 }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: \"1\" }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: 2 }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: \"2\" }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: 3 }}</h1>" <>
        "<h1>{{ 'customer.orders.order_count' | t: count: \"3\" }}</h1>"

    template = Template.parse(markup)

    with {:ok, result, _} <-
           Template.render(template, %{
             "__private_labl_key__" => %{
               "localization" => %{
                 "theme" => %{
                   "customer.orders.order_count.zero" => "{{count}}: no orders",
                   "customer.orders.order_count.one" => "one ({{count}}) order",
                   "customer.orders.order_count.two" => "two orders [{{count}}]",
                   "customer.orders.order_count.other" => "many orders: {{count}}"
                 }
               },
               "locale" => "fr"
             },
             "customers" => %{
               "orders" => %{
                 "count" => 1
               }
             }
           }) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end
end
