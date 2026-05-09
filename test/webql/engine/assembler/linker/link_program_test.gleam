import gleam/dict
import gleam/dynamic
import webql/document
import webql/engine/assembler/linker/link_program
import webql/engine/assembler/linker/program
import webql/graph
import webql/resolution

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

  let assert Ok(program.Program(nodes:, routes:)) =
    link_program.link(module, document())

  let assert Ok(program.FunctionResolver(_)) = dict.get(nodes, "user")
  assert routes == []
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
