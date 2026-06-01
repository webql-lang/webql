defmodule Webql do
  @moduledoc """
  Defines and runs WebQL instances.

  ## Examples

      defmodule MyApp.Webql do
        use Webql,
          memory: MyApp.Webql.Memory.new/0,
          engine: MyApp.Webql.Engine.new/0
      end
  """
  @moduledoc version: "0.1.0"

  @doc """
  Creates a new WebQL instance.
  """
  @callback new(memory :: term(), engine :: term()) :: term()

  @doc """
  Runs an operation with the given parameters.
  """
  @callback run(webql :: term(), source :: binary(), dsl :: module(), params :: map()) :: map()

  @doc """
  Returns the configured memory instance.
  """
  @callback __memory__() :: term()

  @doc """
  Returns the configured engine instance.
  """
  @callback __engine__() :: term()

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour Webql

      @impl Webql
      def new(memory \\ __memory__(), engine \\ __engine__()) do
        Webql.new(memory, engine)
      end

      @impl Webql
      def run(webql \\ new(), source, dsl, params) do
        Webql.run(webql, source, dsl, params)
      end

      @impl Webql
      def __memory__, do: Keyword.get(unquote(opts), :memory, Webql.__memory__())

      @impl Webql
      def __engine__, do: Keyword.get(unquote(opts), :engine, Webql.__engine__())

      defoverridable new: 2, run: 3
    end
  end

  @doc false
  def new(memory, engine) do
    :webql.new(memory, engine)
  end

  @doc false
  def run(webql, source, dsl, params)
      when is_binary(source) and is_atom(dsl) and is_map(params) do
    schema = Webql.Schema.Builder.build(dsl)
    :webql.run(webql, source, schema, params)
  end

  @doc false
  def __memory__(), do: :webql@memory@kv.new()

  @doc false
  def __engine__(), do: :webql@engine@basic.new()
end
