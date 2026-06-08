import gleam/dynamic
import webql/schema

pub type Plan(task) {
  Plan(edges: List(Edge), batches: List(Batch(task)))
}

pub type Batch(task) {
  Batch(steps: List(Step(task)))
}

pub type Step(task) {
  Step(name: String, node: Node(task))
}

pub type Node(task) {
  Node(resolver: schema.Resolver(task))
  Supernode(plan: Plan(task))
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
