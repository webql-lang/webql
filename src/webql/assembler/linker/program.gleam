import gleam/dict
import gleam/dynamic
import webql/document

pub type Program {
  Program(nodes: dict.Dict(String, Resolver), routes: List(Route))
}

pub type Resolver {
  FunctionResolver(function: document.Resolver)
  InlineResolver(program: Program)
}

pub type Route {
  Route(from: List(String), to: List(String))
  Constant(value: dynamic.Dynamic, to: List(String))
}
