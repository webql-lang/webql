defmodule WebqlTest do
  use ExUnit.Case

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

  defmodule Instance do
    use Webql
  end

  test "introspects a schema through the WebQL API" do
    assert Webql.introspect(AddSchema) ==
             {:schema,
              [
                {:operation, "AddOperation", [{:input, "lhs", "Int"}, {:input, "rhs", "Int"}],
                 [{:output, "sum", "Int"}]}
              ], ["Int"]}
  end

  test "injects introspect/1 into WebQL instances" do
    assert Instance.introspect(AddSchema) == Webql.introspect(AddSchema)
  end
end
