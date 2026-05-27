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

  use Spark.Dsl,
    default_extensions: [extensions: [Webql.Schema.Dsl]]
end
