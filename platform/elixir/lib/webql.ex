defmodule Webql do
  @moduledoc """
  Defines and runs WebQL instances.
  """
  use Spark.Dsl,
    default_extensions: [extensions: [Webql.Dsl]]

  @doc """
  Runs an operation with the given inputs.
  """
  @callback run(source :: binary(), inputs :: map()) :: map()

  @doc """
  Compile-time options for a WebQL instance.
  """
  @callback __opts__() :: Keyword.t()

  @doc false
  @impl Spark.Dsl
  def handle_opts(opts) do
    opts = Macro.escape(opts)

    quote location: :keep do
      @behaviour Webql

      @impl Webql
      def __opts__ do
        Keyword.merge(Webql.__opts__(), unquote(opts))
      end

      @impl Webql
      def run(source, inputs) do
        Webql.run(__MODULE__, source, inputs)
      end

      defoverridable Webql
    end
  end

  @doc false
  def run(webql, source, inputs) when is_binary(source) and is_map(inputs) do
    opts = webql.__opts__()

    engine = Keyword.fetch!(opts, :engine)
    memory = Keyword.fetch!(opts, :memory)

    document = Webql.Builder.build(webql)

    document
    |> :webql.new(memory, engine)
    |> :webql.run(source, inputs)
  end

  @doc false
  def __opts__ do
    Keyword.new()
    |> Keyword.put_new(:engine, :webql@engine@basic.new())
    |> Keyword.put_new(:memory, :webql@memory@kv.new())
  end
end
