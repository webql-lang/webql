import gleam/dict
import gleeunit
import webql
import webql/graph
import webql/linker
import webql/program
import webql/schema

pub fn main() {
  gleeunit.main()
}

pub fn link_returns_program_test() {
  let document = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])
  let schema = schema.Schema(nodes: dict.new(), ports: [])

  assert webql.link(document, schema)
    == Ok(program.Program(edges: [], batches: []))
}

pub fn link_reports_linker_diagnostics_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "missing", node: "Missing")],
      edges: [],
    )
  let schema = schema.Schema(nodes: dict.new(), ports: [])

  assert webql.link(document, schema)
    == Error(
      webql.Diagnostic(
        kind: webql.LinkerDiagnostic(linker.UnknownNode("Missing")),
      ),
    )
}
