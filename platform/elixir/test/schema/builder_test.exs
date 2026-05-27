defmodule Webql.Schema.BuilderTest do
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

  defmodule SearchSchema do
    use Webql.Schema

    ports([:text, :integer])
    operations([SearchOperation])
  end

  test "builds a schema tuple from a schema module" do
    assert {
             :schema,
             %{
               "SearchOperation" => {
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
             },
             [{:port, "Text"}, {:port, "Integer"}]
           } = Webql.Schema.Builder.build(SearchSchema)

    assert resolver.(%{"query" => "webql"}) == {:ok, %{"query" => "webql"}}
  end

  defmodule EmptySchema do
    use Webql.Schema

    ports([])
    operations([])
  end

  test "supports schemas without global ports or operations" do
    assert Webql.Schema.Builder.build(EmptySchema) == {:schema, %{}, []}
  end
end
