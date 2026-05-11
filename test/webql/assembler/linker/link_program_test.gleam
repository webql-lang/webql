import gleam/dict
import gleam/dynamic
import webql/assembler/linker/link_program
import webql/assembler/linker/program
import webql/document
import webql/graph

pub fn link_program_links_operation_test() {
  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [graph.ExternalNode(name: "user", node: "GetUser")],
        edges: [],
      ),
    )

  let assert Ok(linked) = link_program.link(module, document())

  assert linked.routes == []
  assert case dict.get(linked.nodes, "user") {
    Ok(program.FunctionResolver(_)) -> True
    _ -> False
  }
}

pub fn link_program_links_edges_to_routes_test() {
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

  let assert Ok(linked) = link_program.link(module, document())

  assert linked.routes == [program.Route(from: ["user_id"], to: ["user", "id"])]
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
