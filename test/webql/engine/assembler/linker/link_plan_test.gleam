import gleam/dict
import webql/document
import webql/engine/assembler/linker/link_plan
import webql/engine/assembler/linker/plan
import webql/graph

pub fn link_plan_links_operation_test() {
  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [],
        nodes: [graph.ExternalNode(name: "user", node: "GetUser")],
        edges: [],
      ),
    )

  let assert Ok(plan.Plan(nodes:, routes:)) = link_plan.link(module, document())

  let assert Ok(plan.FunctionResolver(_)) = dict.get(nodes, "user")
  assert routes == []
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) { Ok(dict.new()) })
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
