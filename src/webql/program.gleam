import gleam/dynamic

pub type Program {
  Program(edges: List(Edge), batches: List(Batch))
}

pub type Batch {
  Batch(steps: List(Step))
}

pub type Step {
  Step(name: String, node: Node)
}

pub type Node {
  Node(operation: String)
  Supernode(program: Program)
}

pub type Edge {
  Edge(source: Source, target: Target)
}

pub type Source {
  Output(path: List(String))
  Literal(value: dynamic.Dynamic)
}

pub type Target {
  Input(path: List(String))
}
