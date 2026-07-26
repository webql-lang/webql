import gleam/dict
import webql/graph
import webql/linker/diagnostic
import webql/linker/link_batch
import webql/program
import webql/schema

pub fn link_batch_links_topological_batches_test() {
  let nodes =
    dict.from_list([
      #("left", graph.Node(name: "left", node: "Add")),
      #("right", graph.Node(name: "right", node: "Add")),
    ])

  let assert Ok([
    program.Batch(steps: [program.Step(name: "left", ..)]),
    program.Batch(steps: [program.Step(name: "right", ..)]),
  ]) = link_batch.link([["left"], ["right"]], nodes, operations(), link_graph)
}

pub fn link_batch_links_supernodes_test() {
  let nested = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])
  let nodes =
    dict.from_list([
      #("nested", graph.Supernode(name: "nested", graph: nested)),
    ])

  let assert Ok([
    program.Batch(steps: [
      program.Step(
        name: "nested",
        node: program.Supernode(program: nested_program),
      ),
    ]),
  ]) = link_batch.link([["nested"]], nodes, operations(), link_graph)

  assert nested_program == program.Program(edges: [], batches: [])
}

pub fn link_batch_reports_missing_nodes_test() {
  assert link_batch.link([["missing"]], dict.new(), operations(), link_graph)
    == Error(diagnostic.Diagnostic(kind: diagnostic.InvalidProgram))
}

fn link_graph(_graph: graph.Graph, _schema: schema.Schema) {
  Ok(program.Program(edges: [], batches: []))
}

fn operations() {
  let operation = schema.Operation(inputs: dict.new(), outputs: dict.new())

  schema.Schema(operations: dict.from_list([#("Add", operation)]), ports: [])
}
