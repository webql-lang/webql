defmodule Webql.MixProject do
  use Mix.Project

  @app :webql
  @version "0.1.0-alpha.1"
  @description "A typed query language and runtime for building executable data graphs."

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      description: @description,
      docs: docs(),
      package: package(),
      erlc_paths: [
        "build/prod/erlang/webql/_gleam_artefacts",
        "build/prod/erlang/gleam_stdlib/_gleam_artefacts"
      ],
      elixirc_paths: ["lib"],
      test_paths: ["test"],
      dialyzer: dialyzer(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      filter_modules: ~r/^Elixir\.Webql(\.|$)/
    ]
  end

  defp package do
    [
      name: "webql",
      description: @description,
      licenses: ["Apache-2.0"],
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
      exclude_files: ["_test\\.beam"],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.3", only: :dev, runtime: false},
      {:spark, "~> 2.7.0"}
    ]
  end
end
