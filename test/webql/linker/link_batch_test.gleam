import gleam/dict
import gleam/dynamic
import webql/graph
import webql/linker/diagnostic
import webql/linker/link_batch
import webql/plan
import webql/schema

pub fn link_batch_links_topological_batches_test() {
  let nodes =
    dict.from_list([
      #("left", graph.Node(name: "left", node: "Add")),
      #("right", graph.Node(name: "right", node: "Add")),
    ])

  let assert Ok([
    plan.Batch(steps: [plan.Step(name: "left", ..)]),
    plan.Batch(steps: [plan.Step(name: "right", ..)]),
  ]) = link_batch.link([["left"], ["right"]], nodes, operations(), link_graph)
}

pub fn link_batch_links_supernodes_test() {
  let nested = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])
  let nodes =
    dict.from_list([
      #("nested", graph.Supernode(name: "nested", graph: nested)),
    ])

  let assert Ok([
    plan.Batch(steps: [
      plan.Step(name: "nested", node: plan.Supernode(plan: nested_plan)),
    ]),
  ]) = link_batch.link([["nested"]], nodes, operations(), link_graph)

  assert nested_plan == plan.Plan(edges: [], batches: [])
}

pub fn link_batch_reports_missing_nodes_test() {
  assert link_batch.link([["missing"]], dict.new(), operations(), link_graph)
    == Error(diagnostic.Diagnostic(kind: diagnostic.InvalidPlan))
}

fn link_graph(_graph: graph.Graph, _schema: schema.Schema) {
  Ok(plan.Plan(edges: [], batches: []))
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
