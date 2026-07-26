import gleam/dict

pub type Schema {
  Schema(operations: dict.Dict(String, Operation), ports: List(Port))
}

pub type Operation {
  Operation(
    inputs: dict.Dict(String, Input),
    outputs: dict.Dict(String, Output),
  )
}

pub type Port {
  Port(name: String)
}

pub type Input {
  Input(name: String, port: String)
}

pub type Output {
  Output(name: String, port: String)
}
