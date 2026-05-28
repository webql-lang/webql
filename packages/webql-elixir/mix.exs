defmodule Webql.MixProject do
  use Mix.Project

  @app :webql

  def project do
    [
      app: @app,
      version: "1.0.0",
      elixir: "~> 1.17",
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
        {:gleam_stdlib, ">= 0.44.0 and < 2.0.0", compile: false, app: false},
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
