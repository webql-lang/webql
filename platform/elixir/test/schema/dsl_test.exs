defmodule Webql.Schema.DslTest do
  use ExUnit.Case, async: true

  defmodule AddOperation do
    use Webql.Schema.Operation
  end

  defmodule Schema do
    use Webql.Schema

    ports([:int])
    operations([AddOperation])
  end

  test "stores schema ports" do
    assert Spark.Dsl.Extension.get_opt(Schema, [:webql], :ports) == [:int]
  end

  test "stores schema operations" do
    assert Spark.Dsl.Extension.get_opt(Schema, [:webql], :operations) == [AddOperation]
  end
end
