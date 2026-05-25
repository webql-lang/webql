import gleam/dict
import gleam/dynamic
import webql/assembler/linker
import webql/assembler/linker/diagnostic
import webql/assembler/linker/program
import webql/document
import webql/graph

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

  let l = linker.new(module)
  let assert Ok(linked) = linker.link(l, document())

  assert linked.routes == [program.Route(from: ["user_id"], to: ["user", "id"])]
  assert case dict.get(linked.nodes, "user") {
    Ok(program.FunctionResolver(_)) -> True
    _ -> False
  }
}

pub fn linker_links_constant_edges_test() {
  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [graph.ExternalNode(name: "user", node: "GetUser")],
        edges: [
          graph.Edge(
            from: graph.PrimitiveOutput(value: graph.IntPrimitive(42)),
            to: graph.Input(path: ["user", "id"]),
          ),
        ],
      ),
    )

  let l = linker.new(module)
  let assert Ok(linked) = linker.link(l, document())

  assert linked.routes
    == [program.Constant(value: dynamic.int(42), to: ["user", "id"])]
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

  let l = linker.new(module)
  let result = linker.link(l, document())

  assert result
    == Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperator("Missing")))
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
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
