defmodule Webql.Schema.Operation.Dsl do
  @moduledoc """
  DSL for defining WebQL operations.

  ## Examples

      operation do
        input :field, :type
        resolve &resolver/1
        output :field, :type
      end
  """
  @moduledoc version: "0.1.0-alpha.1"

  defmodule Input do
    @moduledoc false
    defstruct [:name, :type, :__spark_metadata__]
  end

  defmodule Resolve do
    @moduledoc false
    defstruct [:resolver, :__spark_metadata__]
  end

  defmodule Output do
    @moduledoc false
    defstruct [:name, :type, :__spark_metadata__]
  end

  @input %Spark.Dsl.Entity{
    name: :input,
    target: Input,
    describe: "An input for this operation",
    args: [:name, :type],
    schema: [
      name: [type: :atom, required: true, doc: "The name of the input"],
      type: [type: :atom, required: true, doc: "The type of the input"]
    ]
  }

  @resolve %Spark.Dsl.Entity{
    name: :resolve,
    target: Resolve,
    describe: "The resolver for this operation",
    args: [:resolver],
    schema: [
      resolver: [type: {:fun, 1}, required: true, doc: "The operation resolver"]
    ]
  }

  @output %Spark.Dsl.Entity{
    name: :output,
    target: Output,
    describe: "An output for this operation",
    args: [:name, :type],
    schema: [
      name: [type: :atom, required: true, doc: "The name of the output"],
      type: [type: :atom, required: true, doc: "The type of the output"]
    ]
  }

  @operation %Spark.Dsl.Section{
    name: :operation,
    describe: "Define a WebQL operation",
    singleton_entity_keys: [:resolve],
    entities: [
      @input,
      @resolve,
      @output
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@operation]
end
