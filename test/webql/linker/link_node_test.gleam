import gleam/dict
import gleam/dynamic
import webql/linker/diagnostic
import webql/linker/link_node
import webql/plan
import webql/schema

pub fn link_node_links_runtime_operations_test() {
  let assert Ok(node) = link_node.link("Add", operations())

  assert case node {
    plan.Node(_) -> True
    plan.Supernode(_) -> False
  }
}

pub fn link_node_reports_unknown_operations_test() {
  assert link_node.link("Missing", operations())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperation("Missing")),
    )
}

fn operations() {
  let resolver =
    schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
  let operation =
    schema.Operation(
      inputs: dict.new(),
      outputs: dict.new(),
      resolver: resolver,
    )

  schema.Schema(operations: dict.from_list([#("Add", operation)]), ports: [])
}
