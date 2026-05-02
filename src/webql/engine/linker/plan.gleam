import gleam/dict
import gleam/dynamic
import webql/document

pub type Plan {
  Plan(nodes: dict.Dict(String, Resolver), routes: List(Route))
}

pub type Resolver {
  FunctionResolver(document.Resolver)
  InlineResolver(plan: Plan)
}

pub type Route {
  Route(from: List(String), to: List(String))
  Constant(value: dynamic.Dynamic, to: List(String))
}
