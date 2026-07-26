import gleam/dict
import gleeunit
import webql
import webql/diagnostic
import webql/graph
import webql/linker/diagnostic as linker_diagnostic
import webql/plan
import webql/schema

pub fn main() {
  gleeunit.main()
}

pub fn link_returns_executable_plan_test() {
  let document = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])
  let schema = schema.Schema(operations: dict.new(), ports: [])

  assert webql.link(document, schema) == Ok(plan.Plan(edges: [], batches: []))
}

pub fn link_reports_linker_diagnostics_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "missing", node: "Missing")],
      edges: [],
    )
  let schema = schema.Schema(operations: dict.new(), ports: [])

  assert webql.link(document, schema)
    == Error(
      diagnostic.Diagnostic(
        kind: diagnostic.LinkerDiagnostic(linker_diagnostic.UnknownOperation(
          "Missing",
        )),
      ),
    )
}
