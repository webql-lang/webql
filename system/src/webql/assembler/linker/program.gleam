import gleam/dict
import gleam/dynamic
import webql/schema

pub type Program(task) {
  Program(nodes: dict.Dict(String, Node(task)), edges: List(Edge))
}

pub type Node(task) {
  Node(resolver: schema.Resolver(task))
  Supernode(program: Program(task))
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
