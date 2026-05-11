import gleam/dict
import gleam/dynamic
import gleam/list
import webql/assembler
import webql/assembler/diagnostic as assembler_diagnostic
import webql/assembler/linker/diagnostic as linker_diagnostic
import webql/assembler/plan
import webql/document
import webql/graph

pub fn assembler_assembles_empty_graph_test() {
  let doc = document.Document(operators: dict.new(), typenames: [])
  let a = assembler.new(doc)

  let empty_graph =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [],
      ),
    )

  let assert Ok(result) = assembler.assemble(a, empty_graph)
  let plan.Plan(routes:, batches:) = result

  assert routes == []
  assert batches == []
}

pub fn assembler_assembles_graph_with_external_node_test() {
  let doc =
    document.Document(
      operators: dict.from_list([
        #(
          "GetUser",
          document.Operator(
            parameters: dict.from_list([
              #("id", document.Parameter(name: "id", typename: "Int")),
            ]),
            returns: dict.from_list([
              #("name", document.Return(name: "name", typename: "String")),
            ]),
            resolver: document.Resolver(fn(_) { dynamic.properties([]) }),
          ),
        ),
      ]),
      typenames: [document.Typename("Int"), document.Typename("String")],
    )

  let a = assembler.new(doc)

  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [graph.Return(name: "out", typename: "String")],
        nodes: [graph.ExternalNode(name: "user", node: "GetUser")],
        edges: [
          graph.Edge(
            from: graph.PrimitiveOutput(value: graph.IntPrimitive(1)),
            to: graph.Input(path: ["user", "id"]),
          ),
          graph.Edge(
            from: graph.Output(path: ["user", "name"]),
            to: graph.Input(path: ["out"]),
          ),
        ],
      ),
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
  let doc = document.Document(operators: dict.new(), typenames: [])
  let a = assembler.new(doc)

  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [graph.ExternalNode(name: "node1", node: "UnknownOp")],
        edges: [],
      ),
    )

  let assert Error(d) = assembler.assemble(a, module)

  assert d.kind
    == assembler_diagnostic.LinkerDiagnostic(
      linker_diagnostic.UnknownOperator("UnknownOp"),
    )
}
