import gleam/dict
import webql/document
import webql/engine/linker/diagnostic
import webql/engine/linker/link_operation
import webql/engine/linker/plan
import webql/graph

pub fn link_operation_links_nodes_and_routes_test() {
  let operation =
    graph.Operation(
      parameters: [graph.Parameter(name: "user_id", typename: "Int")],
      returns: [graph.Return(name: "summary", typename: "Text")],
      nodes: [
        graph.ExternalNode(name: "user", node: "GetUser"),
        graph.ExternalNode(name: "posts", node: "Post.List"),
      ],
      edges: [
        graph.Edge(
          from: graph.Output(path: ["user_id"]),
          to: graph.Input(path: ["user", "id"]),
        ),
        graph.Edge(
          from: graph.Output(path: ["user", "id"]),
          to: graph.Input(path: ["posts", "user_id"]),
        ),
        graph.Edge(
          from: graph.Output(path: ["posts", "items"]),
          to: graph.Input(path: ["summary"]),
        ),
      ],
    )

  let assert Ok(plan.Plan(nodes:, routes:)) =
    link_operation.link(operation, document())

  let assert Ok(plan.FunctionResolver(_)) = dict.get(nodes, "user")
  let assert Ok(plan.FunctionResolver(_)) = dict.get(nodes, "posts")
  assert routes
    == [
      plan.Route(from: ["user_id"], to: ["user", "id"]),
      plan.Route(from: ["user", "id"], to: ["posts", "user_id"]),
      plan.Route(from: ["posts", "items"], to: ["summary"]),
    ]
}

pub fn link_operation_links_inline_nodes_test() {
  let operation =
    graph.Operation(
      parameters: [],
      returns: [],
      nodes: [
        graph.InlineNode(
          name: "normalize",
          operation: graph.Operation(
            parameters: [],
            returns: [],
            nodes: [graph.ExternalNode(name: "add", node: "GetUser")],
            edges: [],
          ),
        ),
      ],
      edges: [],
    )

  let assert Ok(plan.Plan(nodes:, routes:)) =
    link_operation.link(operation, document())

  let assert Ok(plan.InlineResolver(linked_plan)) = dict.get(nodes, "normalize")

  let plan.Plan(nodes: inline_nodes, routes: inline_routes) = linked_plan
  let assert Ok(plan.FunctionResolver(_)) = dict.get(inline_nodes, "add")
  assert routes == []
  assert inline_routes == []
}

pub fn link_operation_reports_node_errors_test() {
  let operation =
    graph.Operation(
      parameters: [],
      returns: [],
      nodes: [graph.ExternalNode(name: "missing", node: "Missing.Operator")],
      edges: [],
    )

  assert link_operation.link(operation, document())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperator("Missing.Operator")),
    )
}

fn resolver() {
  document.Resolver(resolver: fn(_inputs) { dict.new() })
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
    operators: dict.from_list([
      #("GetUser", operator()),
      #("Post.List", operator()),
    ]),
    typenames: [],
  )
}
