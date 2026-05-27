defmodule Webql.Schema.DslTest do
  use ExUnit.Case, async: true

  defmodule SearchOperation do
    use Webql.Schema.Operation
  end

  defmodule Schema do
    use Webql.Schema

    ports([:text, :integer])
    operations([SearchOperation])
  end

  test "stores schema ports" do
    assert Spark.Dsl.Extension.get_opt(Schema, [:webql], :ports) == [:text, :integer]
  end

  test "stores schema operations" do
    assert Spark.Dsl.Extension.get_opt(Schema, [:webql], :operations) == [SearchOperation]
  end
end
