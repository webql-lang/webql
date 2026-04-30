import gleam/dict
import gleam/dynamic
import webql/document
import webql/graph
import webql/lang/diagnostic

pub type Runtime =
  fn(graph.Module, document.Document, dict.Dict(String, dynamic.Dynamic)) ->
    Result(dict.Dict(String, dynamic.Dynamic), diagnostic.Diagnostic)
