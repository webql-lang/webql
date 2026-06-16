defmodule Webql do
  @moduledoc """
  Defines WebQL helpers.

  ## Examples

      defmodule MyApp.Webql do
        use Webql
      end
  """
  @moduledoc version: "0.1.0"

  @doc """
  Returns introspection results for a WebQL schema.
  """
  @callback introspect(dsl :: module()) :: map()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Webql

      @impl Webql
      def introspect(dsl) do
        Webql.introspect(dsl)
      end

      defoverridable introspect: 1
    end
  end

  @doc false
  def introspect(dsl) when is_atom(dsl) do
    schema = Webql.Schema.Builder.build(dsl)
    :webql.introspect(schema)
  end
end
