defmodule Webql.Schema.Operation.Builder do
  @moduledoc """
  Builds a WebQL operation into a valid schema operation.
  """
  @moduledoc version: "0.1.0-alpha.1"

  alias Webql.Schema.Operation.Dsl.{Input, Output, Resolve}

  @doc """
  Builds from a DSL schema source and converts the value into a valid WebQL operation.
  """
  @doc version: "0.1.0-alpha.1"
  @spec build(schema :: module()) ::
          {String.t(), {:operation, map(), {:resolver, function()}, map()}}
  def build(schema) do
    name =
      schema
      |> Module.split()
      |> List.last()

    entities = Spark.Dsl.Extension.get_entities(schema, [:operation])

    operation =
      Enum.reduce(entities, %{inputs: %{}, outputs: %{}, resolver: nil}, fn
        %Input{} = input, acc ->
          %{
            acc
            | inputs:
                Map.put(
                  acc.inputs,
                  to_string(input.name),
                  {
                    :input,
                    to_string(input.name),
                    input.type
                    |> to_string()
                    |> Macro.camelize()
                  }
                )
          }

        %Resolve{resolver: resolver}, acc ->
          %{acc | resolver: resolver}

        %Output{} = output, acc ->
          %{
            acc
            | outputs:
                Map.put(
                  acc.outputs,
                  to_string(output.name),
                  {
                    :output,
                    to_string(output.name),
                    output.type
                    |> to_string()
                    |> Macro.camelize()
                  }
                )
          }

        _other_dsl, operation ->
          operation
      end)

    {name,
     {
       :operation,
       operation.inputs,
       {:resolver, operation.resolver},
       operation.outputs
     }}
  end
end
