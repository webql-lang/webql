defmodule Webql.Schema do
  @moduledoc """
  WebQL schema definitions.
  """

  use Spark.Dsl,
    default_extensions: [extensions: [Webql.Schema.Dsl]]
end
