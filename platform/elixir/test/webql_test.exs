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

  test "runs an operation through the WebQL API" do
    source =
      "lhs: Int, rhs: Int -> sum: Int { add = AddOperation .lhs -> add.lhs .rhs -> add.rhs add.sum -> .sum }"

    assert Webql.run(Instance, source, AddSchema, %{"lhs" => 1, "rhs" => 1}) ==
             {:ok, %{"sum" => 2}}
  end

  test "injects run/3 into WebQL instances" do
    source =
      "lhs: Int, rhs: Int -> sum: Int { add = AddOperation .lhs -> add.lhs .rhs -> add.rhs add.sum -> .sum }"

    assert Instance.run(source, AddSchema, %{"lhs" => 1, "rhs" => 1}) ==
             {:ok, %{"sum" => 2}}
  end
end
