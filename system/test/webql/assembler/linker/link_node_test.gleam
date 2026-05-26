import gleam/dict
import gleam/dynamic
import webql/assembler/linker/diagnostic
import webql/assembler/linker/link_node
import webql/assembler/linker/program
import webql/schema

pub fn link_node_links_external_nodes_test() {
  let assert Ok(#(name, resolver)) = link_node.link("add", "Add", operations())

  assert name == "add"
  assert case resolver {
    program.FunctionResolver(_) -> True
    program.InlineResolver(_) -> False
  }
}

pub fn link_node_reports_unknown_operators_test() {
  assert link_node.link("missing", "MissingOperator", operations())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperator("MissingOperator")),
    )
}

fn resolver() {
  schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}

fn operator() {
  schema.Operation(
    inputs: dict.new(),
    outputs: dict.new(),
    resolver: resolver(),
  )
}

fn operations() {
  schema.Schema(operations: dict.from_list([#("Add", operator())]), ports: [])
}
