defmodule Webql.Schema.BuilderTest do
  use ExUnit.Case, async: true

  defmodule SearchOperation do
    use Webql.Schema

    operation do
      input(:query, :text)
      input(:limit, :integer)
      resolve(fn inputs -> {:ok, inputs} end)
      output(:result, :text)
      output(:count, :integer)
    end
  end

  test "builds an operator tuple from an operation schema" do
    assert {
             "SearchOperation",
             {
               :operator,
               %{
                 "query" => {:parameter, "query", "Text"},
                 "limit" => {:parameter, "limit", "Integer"}
               },
               %{
                 "result" => {:return, "result", "Text"},
                 "count" => {:return, "count", "Integer"}
               },
               {:resolver, resolver}
             }
           } = Webql.Schema.Builder.build(SearchOperation)

    assert resolver.(%{"query" => "webql"}) == {:ok, %{"query" => "webql"}}
  end

  defmodule Nested.SpecialName do
    use Webql.Schema

    operation do
      resolve(fn inputs -> inputs end)
    end
  end

  test "derives the operator name from the final module segment" do
    assert {
             "SpecialName",
             {:operator, %{}, %{}, {:resolver, resolver}}
           } = Webql.Schema.Builder.build(Nested.SpecialName)

    assert resolver.(%{}) == %{}
  end
end
