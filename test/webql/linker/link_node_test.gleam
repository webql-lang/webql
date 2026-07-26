import gleam/dict
import webql/linker/diagnostic
import webql/linker/link_node
import webql/program
import webql/schema

pub fn link_node_links_schema_operations_test() {
  let assert Ok(node) = link_node.link("Add", operations())

  assert node == program.Node(operation: "Add")
}

pub fn link_node_reports_unknown_operations_test() {
  assert link_node.link("Missing", operations())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperation("Missing")),
    )
}

fn operations() {
  let operation = schema.Operation(inputs: dict.new(), outputs: dict.new())

  schema.Schema(operations: dict.from_list([#("Add", operation)]), ports: [])
}
