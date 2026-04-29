import gleam/dict
import gleam/dynamic

pub type Document {
  Document(operators: dict.Dict(String, Operator))
}

pub type Operator {
  Operator(
    inputs: dict.Dict(String, Input),
    resolver: fn(dict.Dict(String, dynamic.Dynamic)) ->
      dict.Dict(String, dynamic.Dynamic),
    outputs: dict.Dict(String, Output),
  )
}

pub type Input {
  Input(name: String, typename: String)
}

pub type Output {
  Output(name: String, typename: String)
}
