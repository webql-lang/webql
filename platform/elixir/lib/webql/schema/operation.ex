defmodule Webql.Schema.Operation do
  @moduledoc """
  WebQL schema operations.

  ## Examples

      defmodule MyApp.Schema.MathOperation do
     	  use Webql.Schema.Operation

        operation do
          input :lhs, :int
          input :rhs, :int
          resolve fn params -> {:ok, %{out: params.l + params.r}} end
          output :out, :int
        end
      end
  """
  @moduledoc version: "0.1.0"

  use Spark.Dsl,
    default_extensions: [extensions: [Webql.Schema.Operation.Dsl]]
end
