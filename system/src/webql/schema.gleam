import gleam/dict
import gleam/dynamic

pub type Schema(task) {
  Schema(operations: dict.Dict(String, Operation(task)), ports: List(Port))
}

pub type Operation(task) {
  Operation(
    inputs: dict.Dict(String, Input),
    resolver: Resolver(task),
    outputs: dict.Dict(String, Output),
  )
}

pub type Port {
  Port(name: String)
}

pub type Resolver(task) {
  Resolver(resolver: fn(dynamic.Dynamic) -> task)
}

pub type Input {
  Input(name: String, port: String)
}

pub type Output {
  Output(name: String, port: String)
}
