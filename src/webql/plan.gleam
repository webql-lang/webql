import gleam/dynamic
import webql/schema

pub type Plan {
  Plan(edges: List(Edge), batches: List(Batch))
}

pub type Batch {
  Batch(steps: List(Step))
}

pub type Step {
  Step(name: String, node: Node)
}

pub type Node {
  Node(resolver: schema.Resolver)
  Supernode(plan: Plan)
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
