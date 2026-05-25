defmodule Webql.Dsl do
  @moduledoc """
  DSL for defining a WebQL instance.
  """
  @moduledoc version: "0.1.0"

  @webql %Spark.Dsl.Section{
    name: :webql,
    top_level?: true,
    schema: [
      typenames: [
        type: {:list, :atom},
        required: true,
        doc: "Global WebQL typenames"
      ],
      operations: [
        type: {:list, :module},
        required: true,
        doc: "Operation modules for this WebQL document"
      ]
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@webql]
end
