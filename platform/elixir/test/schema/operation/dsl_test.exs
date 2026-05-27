defmodule Webql.Schema.Operation.DslTest do
  use ExUnit.Case, async: true

  defmodule Operation do
    use Webql.Schema.Operation

    operation do
      input(:query, :text)
      resolve(fn _inputs -> :ok end)
      output(:result, :text)
    end
  end

  test "stores operation inputs, resolver, and outputs in declaration order" do
    assert [
             %Webql.Schema.Operation.Dsl.Input{name: :query, type: :text},
             %Webql.Schema.Operation.Dsl.Resolve{resolver: resolver},
             %Webql.Schema.Operation.Dsl.Output{name: :result, type: :text}
           ] = Spark.Dsl.Extension.get_entities(Operation, [:operation])

    assert is_function(resolver, 1)
  end

  defmodule MultipleFields do
    use Webql.Schema.Operation

    operation do
      input(:query, :text)
      input(:limit, :integer)
      resolve(fn _inputs -> :ok end)
      output(:result, :text)
      output(:count, :integer)
    end
  end

  test "supports multiple inputs and outputs" do
    assert [
             %Webql.Schema.Operation.Dsl.Input{name: :query, type: :text},
             %Webql.Schema.Operation.Dsl.Input{name: :limit, type: :integer},
             %Webql.Schema.Operation.Dsl.Resolve{resolver: resolver},
             %Webql.Schema.Operation.Dsl.Output{name: :result, type: :text},
             %Webql.Schema.Operation.Dsl.Output{name: :count, type: :integer}
           ] = Spark.Dsl.Extension.get_entities(MultipleFields, [:operation])

    assert is_function(resolver, 1)
  end
end
