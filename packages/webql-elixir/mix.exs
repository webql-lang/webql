defmodule Webql.MixProject do
  use Mix.Project

  @app :webql

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.17",
      description: "A typed query language and runtime for building executable data graphs.",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      package: [
        name: "webql_ex",
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => "https://github.com/webql-lang/webql"}
      ],
      erlc_paths: [
        "deps/gleam_stdlib/src",
        "src",
        "../webql/build/dev/erlang/webql/_gleam_artefacts"
      ],
      elixirc_paths: [
        "lib",
        "src",
        "../webql/build/dev/erlang/webql/_gleam_artefacts"
      ],
      prune_code_paths: false,
      dialyzer: [
        paths: ["_build/#{Mix.env()}/lib/#{@app}/ebin"],
        exclude_files: ["_test\\.beam"],
        ignore_warnings: ".dialyzer_ignore.exs"
      ],
      deps: [
        {:dialyxir, "~> 1.4", runtime: false},
        {:ex_doc, "~> 0.40.3", only: :dev, runtime: false},
        {:spark, "~> 2.7.0"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
