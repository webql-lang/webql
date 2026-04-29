import gleam/dict

pub type Schema {
  Schema(operators: dict.Dict(String, Operator))
}

pub type Operator {
  Operator(name: String, inputs: List(Input), outputs: List(Output))
}

pub type Input {
  Input(name: String, typename: String)
}

pub type Output {
  Output(name: String, typename: String)
}
