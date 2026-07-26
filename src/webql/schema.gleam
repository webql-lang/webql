import gleam/dict

pub type Schema {
  Schema(nodes: dict.Dict(String, Node), ports: List(Port))
}

pub type Node {
  Node(inputs: dict.Dict(String, Input), outputs: dict.Dict(String, Output))
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
