import gleam/dict

/// The typenames, boundaries, and nodes available to a WebQL document.
pub type Schema {
  Schema(
    typenames: dict.Dict(String, Typename),
    boundaries: dict.Dict(String, Boundary),
    nodes: dict.Dict(String, Node),
  )
}

/// A value-consuming definition that exposes outputs, boundaries, and nodes.
pub type Boundary {
  Boundary(
    typename: Typename,
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
pub type Typename {
  Typename(name: String)
}

/// An input exposed under its dictionary key and its value type.
pub type Input {
  Input(typename: Typename)
}

/// An output exposed under its dictionary key and its value type.
pub type Output {
  Output(typename: Typename)
}
