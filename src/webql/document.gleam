import gleam/dict
import gleam/dynamic

pub type Document {
  Document(operators: dict.Dict(String, Operator), typenames: List(Typename))
}

pub type Operator {
  Operator(
    inputs: dict.Dict(String, Input),
    resolver: Resolver,
    outputs: dict.Dict(String, Output),
  )
}

pub type Typename {
  Typename(name: String)
}

pub type Resolver {
  Resolver(
    resolver: fn(dict.Dict(String, dynamic.Dynamic)) ->
      dict.Dict(String, dynamic.Dynamic),
  )
}

pub type Input {
  Input(name: String, typename: String)
}

pub type Output {
  Output(name: String, typename: String)
}
