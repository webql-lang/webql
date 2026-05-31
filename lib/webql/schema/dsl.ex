defmodule Webql.Schema.Dsl do
  @moduledoc """
  DSL for defining a WebQL instance.
  """
  @moduledoc version: "0.1.0-alpha.1"

  @webql %Spark.Dsl.Section{
    name: :webql,
    top_level?: true,
    schema: [
      ports: [
        type: {:list, :atom},
        required: true,
        doc: "Global WebQL ports"
      ],
      operations: [
        type: {:list, :module},
        required: true,
        doc: "Operation modules for this WebQL schema"
      ]
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@webql]
end
