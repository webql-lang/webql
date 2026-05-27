defmodule Webql.Builder do
  @moduledoc """
  Builds a WebQL runner into a valid schema value.
  """
  @moduledoc version: "0.1.0"

  @doc """
  Builds from a DSL source and converts the value into a valid WebQL schema value.
  """
  @doc version: "0.1.0"
  @spec build(schema :: module()) :: {:schema, map(), list(tuple())}
  def build(schema) do
    ports =
      schema
      |> Spark.Dsl.Extension.get_opt([:webql], :ports, [])
      |> Enum.map(
        &{:port,
         &1
         |> to_string()
         |> Macro.camelize()}
      )

    operations =
      schema
      |> Spark.Dsl.Extension.get_opt([:webql], :operations, [])
      |> Enum.map(&Webql.Schema.Builder.build/1)
      |> Map.new(fn {name, operation} -> {to_string(name), operation} end)

    {:schema, operations, ports}
  end
end
