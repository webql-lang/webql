import gleam/dict
import webql/linker/diagnostic
import webql/linker/link_node
import webql/program
import webql/schema

pub fn link_node_links_schema_nodes_test() {
  let assert Ok(node) = link_node.link("Add", catalog())

  assert node == program.Node(kind: "Add")
}

pub fn link_node_reports_unknown_nodes_test() {
  assert link_node.link("Missing", catalog())
    == Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode("Missing")))
}

fn catalog() {
  let node = schema.Node(inputs: dict.new(), outputs: dict.new())

  schema.Schema(nodes: dict.from_list([#("Add", node)]), ports: [])
}
