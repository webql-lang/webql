import gleam/dict
import webql/graph
import webql/linker/diagnostic
import webql/linker/link_batch
import webql/program
import webql/schema

pub fn link_batch_links_topological_batches_test() {
  let nodes =
    dict.new()
    |> dict.insert("left", graph.Node(name: "left", node: "Add"))
    |> dict.insert("right", graph.Node(name: "right", node: "Add"))
  let catalog =
    schema.Schema(
      nodes: dict.new()
        |> dict.insert(
          "Add",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  let assert Ok([
    program.Batch(steps: [program.Step(name: "left", ..)]),
    program.Batch(steps: [program.Step(name: "right", ..)]),
  ]) =
    link_batch.link([["left"], ["right"]], nodes, catalog, fn(_graph, _schema) {
      Ok(program.Program(edges: [], batches: []))
    })
}

pub fn link_batch_links_supernodes_test() {
  let nested = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])
  let nodes =
    dict.new()
    |> dict.insert("nested", graph.Supernode(name: "nested", graph: nested))
  let catalog =
    schema.Schema(
      nodes: dict.new()
        |> dict.insert(
          "Add",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  let assert Ok([
    program.Batch(steps: [
      program.Step(
        name: "nested",
        node: program.Supernode(program: nested_program),
      ),
    ]),
  ]) =
    link_batch.link([["nested"]], nodes, catalog, fn(_graph, _schema) {
      Ok(program.Program(edges: [], batches: []))
    })

  assert nested_program == program.Program(edges: [], batches: [])
}

pub fn link_batch_reports_missing_nodes_test() {
  let catalog =
    schema.Schema(
      nodes: dict.new()
        |> dict.insert(
          "Add",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  assert link_batch.link(
      [["missing"]],
      dict.new(),
      catalog,
      fn(_graph, _schema) { Ok(program.Program(edges: [], batches: [])) },
    )
    == Error(diagnostic.Diagnostic(kind: diagnostic.InvalidProgram))
}
