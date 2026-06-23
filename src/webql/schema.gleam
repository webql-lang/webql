import gleam/dict
import gleam/dynamic

pub type Schema {
  Schema(operations: dict.Dict(String, Operation), ports: List(Port))
}

pub type Operation {
  Operation(
    inputs: dict.Dict(String, Input),
    resolver: Resolver,
    outputs: dict.Dict(String, Output),
  )
}

pub type Port {
  Port(name: String)
}

pub type Resolver {
  Resolver(resolver: fn(dynamic.Dynamic) -> dynamic.Dynamic)
}

pub type Input {
  Input(name: String, port: String)
}

pub type Output {
  Output(name: String, port: String)
}
