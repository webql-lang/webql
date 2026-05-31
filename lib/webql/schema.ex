defmodule Webql.Schema do
  @moduledoc """
  The primary WebQL schema.

  ## Examples

      defmodule MyApp.Schema do
        use Webql.Schema

        ports [:string, :int, :float]
        operations [MyApp.Schema.MathOperation]
      end
  """
  @moduledoc version: "0.1.0-alpha.1"

  use Spark.Dsl,
    default_extensions: [extensions: [Webql.Schema.Dsl]]
end
