defmodule Webql.Schema.Operation.BuilderTest do
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

  test "builds an operation tuple from an operation module" do
    assert {
             "AddOperation",
             {
               :operation,
               %{
                 "lhs" => {:input, "lhs", "Int"},
                 "rhs" => {:input, "rhs", "Int"}
               },
               {:resolver, resolver},
               %{
                 "sum" => {:output, "sum", "Int"}
               }
             }
           } = Webql.Schema.Operation.Builder.build(AddOperation)

    assert resolver.(%{"lhs" => 1, "rhs" => 1}) == {:ok, %{"sum" => 2}}
  end
end
