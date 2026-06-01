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

  defmodule MockedInstance do
    use Webql, memory: {:configured_memory}, engine: {:configured_engine}
  end

  test "runs an operation through the WebQL API" do
    source =
      "lhs: Int, rhs: Int -> sum: Int { add = AddOperation .lhs -> add.lhs .rhs -> add.rhs add.sum -> .sum }"

    instance = Instance.new()

    assert Webql.run(instance, source, AddSchema, %{"lhs" => 1, "rhs" => 1}) ==
             {:ok, %{"sum" => 2}}
  end

  test "injects run/3 into WebQL instances" do
    source =
      "lhs: Int, rhs: Int -> sum: Int { add = AddOperation .lhs -> add.lhs .rhs -> add.rhs add.sum -> .sum }"

    assert Instance.run(source, AddSchema, %{"lhs" => 1, "rhs" => 1}) ==
             {:ok, %{"sum" => 2}}
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

  test "provides default memory and engine instances" do
    assert :memory = elem(Webql.__memory__(), 0)
    assert :engine = elem(Webql.__engine__(), 0)
  end

  test "injects configured memory and engine accessors into WebQL instances" do
    assert MockedInstance.__memory__() == {:configured_memory}
    assert MockedInstance.__engine__() == {:configured_engine}
  end

  test "injects new/0 using configured memory and engine" do
    assert MockedInstance.new() == {:webql, {:configured_memory}, {:configured_engine}}
  end

  test "injects new/2 for explicit memory and engine" do
    assert MockedInstance.new({:memory}, {:engine}) == {:webql, {:memory}, {:engine}}
  end
end
