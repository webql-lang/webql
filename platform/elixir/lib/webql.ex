defmodule Webql do
  @doc """
  Runs an operation with the given parameters.
  """
  @callback run(source :: binary(), schema :: module(), params :: map()) :: map()

  @doc """
  Compile-time options for a WebQL instance.
  """
  @callback __opts__() :: Keyword.t()

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour Webql

      @impl Webql
      def __opts__ do
        Keyword.merge(Webql.__opts__(), unquote(opts))
      end

      @impl Webql
      def run(source, schema, params) do
        Webql.run(__MODULE__, source, schema, params)
      end

      defoverridable Webql
    end
  end

  @doc false
  def run(webql, source, schema, params)
      when is_binary(source) and is_atom(schema) and is_map(params) do
    opts = webql.__opts__()

    engine = Keyword.fetch!(opts, :engine)
    memory = Keyword.fetch!(opts, :memory)

    schema = Webql.Schema.Builder.build(schema)

    schema
    |> :webql.new(memory, engine)
    |> :webql.run(source, params)
  end

  @doc false
  def __opts__ do
    Keyword.new()
    |> Keyword.put_new(:engine, :webql@engine@basic.new())
    |> Keyword.put_new(:memory, :webql@memory@kv.new())
  end
end
