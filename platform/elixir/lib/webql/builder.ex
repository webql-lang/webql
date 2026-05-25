defmodule Webql.Builder do
  @moduledoc """
  Builds a WebQL runner into a valid document.
  """
  @moduledoc version: "0.1.0"

  @doc """
  Builds from a DSL source and converts the value into a valid WebQL document.
  """
  @doc version: "0.1.0"
  @spec build(schema :: module()) :: {:document, map(), list(tuple())}
  def build(schema) do
    typenames =
      schema
      |> Spark.Dsl.Extension.get_opt([:webql], :typenames, [])
      |> Enum.map(&{:typename, typename(&1)})

    operations =
      schema
      |> Spark.Dsl.Extension.get_opt([:webql], :operations, [])
      |> Enum.map(&Webql.Schema.Builder.build/1)
      |> Map.new(fn {name, operator} -> {to_string(name), operator} end)

    {:document, operations, typenames}
  end

  # PRIVATE FUNCTIONS
  # =================
  defp typename(type) do
    type
    |> to_string()
    |> Macro.camelize()
  end
end
