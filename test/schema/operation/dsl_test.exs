defmodule Webql.Schema.Operation.DslTest do
  use ExUnit.Case, async: true

  defmodule AddOperation do
    use Webql.Schema.Operation

    operation do
      input(:lhs, :int)
      input(:rhs, :int)
      resolve(fn %{"lhs" => lhs, "rhs" => rhs} -> {:ok, %{"sum" => lhs + rhs}} end)
      output(:sum, :int)
    end
  end

  test "stores operation inputs, resolver, and outputs in declaration order" do
    assert [
             %Webql.Schema.Operation.Dsl.Input{name: :lhs, type: :int},
             %Webql.Schema.Operation.Dsl.Input{name: :rhs, type: :int},
             %Webql.Schema.Operation.Dsl.Resolve{resolver: resolver},
             %Webql.Schema.Operation.Dsl.Output{name: :sum, type: :int}
           ] = Spark.Dsl.Extension.get_entities(AddOperation, [:operation])

    assert resolver.(%{"lhs" => 1, "rhs" => 1}) == {:ok, %{"sum" => 2}}
  end
end
