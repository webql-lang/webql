import gleam/dict
import webql/document
import webql/engine/linker/diagnostic
import webql/engine/linker/link_node
import webql/engine/linker/plan

pub fn link_node_links_external_nodes_test() {
  let assert Ok(#("add", plan.FunctionResolver(_))) =
    link_node.link("add", "Add", document())
}

pub fn link_node_reports_unknown_operators_test() {
  assert link_node.link("missing", "MissingOperator", document())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperator("MissingOperator")),
    )
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) { dict.new() })
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
