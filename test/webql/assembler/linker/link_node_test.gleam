import gleam/dict
import gleam/dynamic
import webql/assembler/linker/diagnostic
import webql/assembler/linker/link_node
import webql/assembler/linker/program
import webql/document
import webql/resolution

pub fn link_node_links_external_nodes_test() {
  let assert Ok(#("add", program.FunctionResolver(_))) =
    link_node.link("add", "Add", document())
}

pub fn link_node_reports_unknown_operators_test() {
  assert link_node.link("missing", "MissingOperator", document())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperator("MissingOperator")),
    )
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) {
    resolution.Done(Ok(dynamic.properties([])))
  })
}

fn operator() {
  document.Operator(
    parameters: dict.new(),
    returns: dict.new(),
    resolver: resolver(),
  )
}

fn document() {
  document.Document(
    operators: dict.from_list([#("Add", operator())]),
    typenames: [],
  )
}
