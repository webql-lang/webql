defmodule Webql.MixProject do
  use Mix.Project

  @app :webql
  @version "0.1.0-alpha.2"
  @description "A typed query language and runtime for building executable data graphs."

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      description: @description,
      build_tools: [:gleam, :mix],
      docs: docs(),
      package: package(),
      erlc_paths: erlc_paths(),
      elixirc_paths: ["lib"],
      test_paths: ["test"],
      aliases: aliases(),
      dialyzer: dialyzer(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.3", only: :dev, runtime: false},
      {:makeup_gleam, "~> 1.0", only: :dev, runtime: false},
      {:spark, "~> 2.7.0"}
    ]
  end

  defp aliases do
    [
      docs: [
        "cmd gleam build --target erlang",
        # NOTE: there is an active issue is being tracked for compiling bash files in the gleam pipeline.
        # https://github.com/gleam-lang/gleam/issues/4474
        "cmd rm -f build/#{Mix.env()}/erlang/*/_gleam_artefacts/gleam@@compile.erl",
        "cmd gleam docs build",
        &generate_gleam_extras/1,
        "docs"
      ]
    ]
  end

  defp erlc_paths do
    env = if Mix.env() == :prod, do: :prod, else: :dev

    [
      "build/#{env}/erlang/webql/_gleam_artefacts",
      "build/#{env}/erlang/gleam_stdlib/_gleam_artefacts"
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"] ++ gleam_doc_links(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules(),
      filter_modules: ~r/^Elixir\.Webql(\.|$)/
    ]
  end

  defp package do
    [
      name: "webql",
      description: @description,
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/webql-lang/webql"},
      build_tools: ["mix", "gleam"],
      files: [
        "gleam.toml",
        "manifest.toml",
        "lib",
        "src",
        "build/prod/erlang",
        "mix.exs",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp dialyzer do
    [
      paths: ["_build/#{Mix.env()}/lib/#{@app}/ebin"],
      exclude_files: [
        "gleam.*\\.beam$",
        "webql@.*\\.beam$"
      ],
      flags: [:no_missing_calls],
      list_unused_filters: false
    ]
  end

  defp groups_for_modules do
    [
      Webql: [Webql],
      Schema: ~r/^Webql\.Schema(\.|$)/
    ]
  end

  defp groups_for_extras do
    [
      Schema: ~r{^build/dev/exdoc_gleam/webql-schema\.md$},
      Introspection: ~r{^build/dev/exdoc_gleam/webql-introspection\.md$},
      Graph: ~r{^build/dev/exdoc_gleam/webql-graph\.md$},
      Compiler: ~r{^build/dev/exdoc_gleam/webql-compiler(?:-|\.md$)},
      Assembler: ~r{^build/dev/exdoc_gleam/webql-assembler(?:-|\.md$)},
      Engine: ~r{^build/dev/exdoc_gleam/webql-engine(?:-|\.md$)},
      Interpreter: [
        ~r{^build/dev/exdoc_gleam/webql\.md$},
        ~r{^build/dev/exdoc_gleam/webql-interpreter(?:-|\.md$)}
      ],
      Memory: ~r{^build/dev/exdoc_gleam/webql-memory(?:-|\.md$)},
      Diagnostic: ~r{^build/dev/exdoc_gleam/webql-diagnostic\.md$}
    ]
  end

  defp gleam_modules do
    "src/**/*.gleam"
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(fn path ->
      path
      |> Path.rootname()
      |> Path.relative_to("src")
    end)
  end

  defp gleam_doc_links do
    for module <- gleam_modules() do
      filename = String.replace(module, "/", "-")

      {
        Path.join("build/dev/exdoc_gleam", filename <> ".md"),
        title: module, filename: filename, source: "src/#{module}.gleam"
      }
    end
  end

  defp generate_gleam_extras(_extra) do
    File.rm_rf!("build/dev/exdoc_gleam")
    File.mkdir_p!("build/dev/exdoc_gleam")

    items_by_module =
      "build/dev/docs/webql"
      |> Path.join("search-data.json")
      |> File.read!()
      |> :json.decode()
      |> Map.fetch!("items")
      |> Enum.reject(&(&1["type"] == "module"))
      |> Enum.group_by(& &1["parentTitle"])

    for module <- gleam_modules() do
      filename = String.replace(module, "/", "-")
      path = Path.join("build/dev/exdoc_gleam", filename <> ".md")
      items = Map.get(items_by_module, module, [])

      body =
        [
          "# #{module}\n\n",
          gleam_doc_section("Types", items, "type"),
          gleam_doc_section("Values", items, "value")
        ]

      File.write!(path, IO.iodata_to_binary(body))
    end
  end

  defp gleam_doc_section(title, items, type) do
    items =
      items
      |> Enum.filter(&(&1["type"] == type))
      |> Enum.sort_by(& &1["title"])

    case items do
      [] ->
        []

      items ->
        [
          "## #{title}\n\n",
          for item <- items do
            doc =
              item["doc"]
              |> Kernel.||("")
              |> String.replace(~r/\nSynonyms:\n(.|\n)*\z/, "")
              |> String.trim()

            [
              "### ",
              item["title"],
              "\n\n",
              doc,
              "\n\n"
            ]
          end
        ]
    end
  end
end
