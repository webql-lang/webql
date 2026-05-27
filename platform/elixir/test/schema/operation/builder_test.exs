defmodule Webql.Schema.Operation.BuilderTest do
  use ExUnit.Case, async: true

  defmodule SearchOperation do
    use Webql.Schema.Operation

    operation do
      input(:query, :text)
      input(:limit, :integer)
      resolve(fn inputs -> {:ok, inputs} end)
      output(:result, :text)
      output(:count, :integer)
    end
  end

  test "builds an operation tuple from an operation module" do
    assert {
             "SearchOperation",
             {
               :operation,
               %{
                 "query" => {:input, "query", "Text"},
                 "limit" => {:input, "limit", "Integer"}
               },
               {:resolver, resolver},
               %{
                 "result" => {:output, "result", "Text"},
                 "count" => {:output, "count", "Integer"}
               }
             }
           } = Webql.Schema.Operation.Builder.build(SearchOperation)

    assert resolver.(%{"query" => "webql"}) == {:ok, %{"query" => "webql"}}
  end

  defmodule Nested.SpecialName do
    use Webql.Schema.Operation

    operation do
      resolve(fn inputs -> inputs end)
    end
  end

  test "derives the operation name from the final module segment" do
    assert {
             "SpecialName",
             {:operation, %{}, {:resolver, resolver}, %{}}
           } = Webql.Schema.Operation.Builder.build(Nested.SpecialName)

    assert resolver.(%{}) == %{}
  end
end
