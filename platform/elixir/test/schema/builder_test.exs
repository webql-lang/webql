defmodule Webql.Schema.BuilderTest do
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

  defmodule AddSchema do
    use Webql.Schema

    ports([:int])
    operations([AddOperation])
  end

  test "builds a schema tuple from a schema module" do
    assert {
             :schema,
             %{
               "AddOperation" => {
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
             },
             [{:port, "Int"}]
           } = Webql.Schema.Builder.build(AddSchema)

    assert resolver.(%{"lhs" => 1, "rhs" => 1}) == {:ok, %{"sum" => 2}}
  end
end
