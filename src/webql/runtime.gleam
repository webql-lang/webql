import gleam/dict
import gleam/dynamic
import webql/document
import webql/graph

pub type Resolver =
  fn(graph.Module, document.Document, dict.Dict(String, dynamic.Dynamic)) ->
    Result(dict.Dict(String, dynamic.Dynamic), Nil)

pub type Runtime {
  Runtime(resolver: Resolver)
}
