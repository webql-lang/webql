import gleam/dict
import gleam/dynamic
import webql/document

pub type Program(task) {
  Program(nodes: dict.Dict(String, Resolver(task)), routes: List(Route))
}

pub type Resolver(task) {
  FunctionResolver(function: document.Resolver(task))
  InlineResolver(program: Program(task))
}

pub type Route {
  Route(from: List(String), to: List(String))
  Constant(value: dynamic.Dynamic, to: List(String))
}
