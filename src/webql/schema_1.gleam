import gleam/dict

/// The ports, boundaries, and nodes available to a WebQL document.
pub type Schema {
  Schema(
    ports: dict.Dict(String, Port),
    boundaries: dict.Dict(String, Boundary),
    nodes: dict.Dict(String, Node),
  )
}

/// A value-consuming definition that exposes inputs, outputs, boundaries, and
/// nodes.
pub type Boundary {
  Boundary(
    port: Port,
    inputs: dict.Dict(String, Input),
    outputs: dict.Dict(String, Output),
    boundaries: dict.Dict(String, Boundary),
    nodes: dict.Dict(String, Node),
  )
}

/// An executable definition with named inputs and outputs.
pub type Node {
  Node(inputs: dict.Dict(String, Input), outputs: dict.Dict(String, Output))
}

/// A value type available to document and definition interfaces.
pub type Port {
  Port(name: String)
}

/// An input exposed under its dictionary key and its value type.
pub type Input {
  Input(port: Port)
}

/// An output exposed under its dictionary key and its value type.
pub type Output {
  Output(port: Port)
}
