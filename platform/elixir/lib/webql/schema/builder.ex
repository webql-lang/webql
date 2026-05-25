defmodule Webql.Schema.Builder do
  @moduledoc """
  Builds a WebQL operation into a valid document.
  """
  @moduledoc version: "0.1.0"

  alias Webql.Schema.Dsl.{Input, Output, Resolve}

  @doc """
  Builds from a DSL schema source and converts the value into a valid WebQL document.
  """
  @doc version: "0.1.0"
  @spec build(schema :: module()) ::
          {String.t(), {:operator, map(), map(), {:resolver, function()}}}
  def build(schema) do
    name =
      Module.split(schema)
      |> List.last()

    entities = Spark.Dsl.Extension.get_entities(schema, [:operation])

    operation =
      Enum.reduce(entities, %{parameters: %{}, returns: %{}, resolver: nil}, fn
        %Input{} = input, acc ->
          %{
            acc
            | parameters:
                Map.put(
                  acc.parameters,
                  to_string(input.name),
                  {:parameter, to_string(input.name), typename(input.type)}
                )
          }

        %Resolve{resolver: resolver}, acc ->
          %{acc | resolver: resolver}

        %Output{} = output, acc ->
          %{
            acc
            | returns:
                Map.put(
                  acc.returns,
                  to_string(output.name),
                  {:return, to_string(output.name), typename(output.type)}
                )
          }

        _other_dsl, parameters ->
          parameters
      end)

    {name,
     {
       :operator,
       operation.parameters,
       operation.returns,
       {:resolver, operation.resolver}
     }}
  end

  # PRIVATE FUNCTIONS
  # =================
  defp typename(type) do
    type
    |> to_string()
    |> Macro.camelize()
  end
end
