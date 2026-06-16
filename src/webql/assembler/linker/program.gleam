import gleam/dict
import gleam/dynamic
import webql/schema

pub type Program {
  Program(nodes: dict.Dict(String, Node), edges: List(Edge))
}

pub type Node {
  Node(resolver: schema.Resolver)
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
