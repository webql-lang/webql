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
    program.Node(_) -> True
    program.Supernode(_) -> False
  }
}

pub fn link_node_reports_unknown_operations_test() {
  assert link_node.link("missing", "MissingOperation", operations())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperation(
        "MissingOperation",
      )),
    )
}

fn resolver() {
  schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}

fn operation() {
  schema.Operation(
    inputs: dict.new(),
    outputs: dict.new(),
    resolver: resolver(),
  )
}

fn operations() {
  schema.Schema(operations: dict.from_list([#("Add", operation())]), ports: [])
}
