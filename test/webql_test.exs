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

  defmodule ConfiguredInstance do
    use Webql, memory: :configured_memory, engine: :configured_engine
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

  test "provides default memory and engine instances" do
    assert {:memory, _new, {:kv, _values}, _get, _set, _merge} = Webql.__memory__()

    assert {:engine, _handle_run, _handle_start_plan, _handle_finish_plan, _handle_start_batch,
            _handle_finish_batch, _handle_start_step, _handle_finish_step} = Webql.__engine__()
  end

  test "injects configured memory and engine accessors into WebQL instances" do
    assert ConfiguredInstance.__memory__() == :configured_memory
    assert ConfiguredInstance.__engine__() == :configured_engine
  end

  test "injects new/0 using configured memory and engine" do
    assert ConfiguredInstance.new() == {:webql, :configured_memory, :configured_engine}
  end

  test "injects new/2 for explicit memory and engine" do
    assert ConfiguredInstance.new(:memory, :engine) == {:webql, :memory, :engine}
  end
end
