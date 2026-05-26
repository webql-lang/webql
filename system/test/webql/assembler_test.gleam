import gleam/dict
import gleam/dynamic
import gleam/list
import webql/assembler
import webql/assembler/diagnostic as assembler_diagnostic
import webql/assembler/linker/diagnostic as linker_diagnostic
import webql/assembler/plan
import webql/graph
import webql/schema

pub fn assembler_assembles_empty_graph_test() {
  let schema = schema.Schema(operations: dict.new(), ports: [])
  let a = assembler.new(schema)

  let empty_graph =
    graph.Graph(parameters: [], returns: [], nodes: [], edges: [])

  let assert Ok(result) = assembler.assemble(a, empty_graph)
  let plan.Plan(routes:, batches:) = result

  assert routes == []
  assert batches == []
}

pub fn assembler_assembles_graph_with_external_node_test() {
  let schema =
    schema.Schema(
      operations: dict.from_list([
        #(
          "GetUser",
          schema.Operation(
            inputs: dict.from_list([
              #("id", schema.Input(name: "id", port: "Int")),
            ]),
            outputs: dict.from_list([
              #("name", schema.Output(name: "name", port: "String")),
            ]),
            resolver: schema.Resolver(fn(_) { dynamic.properties([]) }),
          ),
        ),
      ]),
      ports: [schema.Port("Int"), schema.Port("String")],
    )

  let a = assembler.new(schema)

  let module =
    graph.Graph(
      parameters: [],
      returns: [graph.Return(name: "out", port: "String")],
      nodes: [graph.Node(name: "user", node: "GetUser")],
      edges: [
        graph.Edge(
          source: graph.Static(value: graph.Int(1)),
          target: graph.Input(path: ["user", "id"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["user", "name"]),
          target: graph.Input(path: ["out"]),
        ),
      ],
    )

  let assert Ok(result) = assembler.assemble(a, module)
  let plan.Plan(routes:, batches:) = result

  assert routes
    == [
      plan.Constant(value: dynamic.int(1), to: ["user", "id"]),
      plan.Route(from: ["user", "name"], to: ["out"]),
    ]

  let batch_step_names =
    list.map(batches, fn(batch) {
      let plan.Batch(batch: steps) = batch
      list.map(steps, fn(step) {
        let plan.Step(name:, ..) = step
        name
      })
    })

  assert batch_step_names == [["user"]]
}

pub fn assembler_reports_unknown_operator_test() {
  let schema = schema.Schema(operations: dict.new(), ports: [])
  let a = assembler.new(schema)

  let module =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "node1", node: "UnknownOp")],
      edges: [],
    )

  let assert Error(d) = assembler.assemble(a, module)

  assert d.kind
    == assembler_diagnostic.LinkerDiagnostic(linker_diagnostic.UnknownOperator(
      "UnknownOp",
    ))
}
