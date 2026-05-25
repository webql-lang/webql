defmodule WebqlTest do
  use ExUnit.Case

  defmodule SearchOperation do
    use Webql.Schema

    operation do
      input(:query, :text)
      resolve(fn inputs -> {:ok, inputs} end)
      output(:result, :text)
    end
  end

  defmodule Instance do
    use Webql

    typenames([:text])
    operations([SearchOperation])
  end

  test "runs an operation through the WebQL API" do
    source = "query: Text -> result: Text { .query -> .result }"

    assert Webql.run(Instance, source, %{"query" => "webql"}) ==
             {:ok, %{"result" => "webql"}}
  end

  test "injects run/2 into WebQL instances" do
    source = "query: Text -> result: Text { .query -> .result }"

    assert Instance.run(source, %{"query" => "webql"}) ==
             {:ok, %{"result" => "webql"}}
  end
end
