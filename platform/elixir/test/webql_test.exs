defmodule WebqlTest do
  use ExUnit.Case

  defmodule SearchOperation do
    use Webql.Schema.Operation

    operation do
      input(:query, :text)
      resolve(fn inputs -> {:ok, inputs} end)
      output(:result, :text)
    end
  end

  defmodule SearchSchema do
    use Webql.Schema

    ports([:text])
    operations([SearchOperation])
  end

  defmodule Instance do
    use Webql
  end

  test "runs an operation through the WebQL API" do
    source = "query: Text -> result: Text { .query -> .result }"

    assert Webql.run(Instance, source, SearchSchema, %{"query" => "webql"}) ==
             {:ok, %{"result" => "webql"}}
  end

  test "injects run/3 into WebQL instances" do
    source = "query: Text -> result: Text { .query -> .result }"

    assert Instance.run(source, SearchSchema, %{"query" => "webql"}) ==
             {:ok, %{"result" => "webql"}}
  end
end
