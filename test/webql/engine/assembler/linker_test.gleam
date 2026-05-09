import gleam/dict
import gleam/dynamic
import webql/document
import webql/engine/assembler/linker
import webql/engine/assembler/linker/diagnostic
import webql/engine/assembler/linker/program
import webql/graph
import webql/resolution

pub fn linker_links_graph_module_test() {
  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [graph.ExternalNode(name: "user", node: "GetUser")],
        edges: [
          graph.Edge(
            from: graph.Output(path: ["user_id"]),
            to: graph.Input(path: ["user", "id"]),
          ),
        ],
      ),
    )

  let assert Ok(program.Program(nodes:, routes:)) =
    module
    |> linker.new()
    |> linker.link(document())

  let assert Ok(program.FunctionResolver(_)) = dict.get(nodes, "user")
  assert routes == [program.Route(from: ["user_id"], to: ["user", "id"])]
}

pub fn linker_reports_unknown_operators_test() {
  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [graph.ExternalNode(name: "missing", node: "Missing")],
        edges: [],
      ),
    )

  assert module
    |> linker.new()
    |> linker.link(document())
    == Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperator("Missing")))
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) {
    resolution.Done(Ok(dynamic.properties([])))
  })
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
    operators: dict.from_list([#("GetUser", operator())]),
    typenames: [],
  )
}
