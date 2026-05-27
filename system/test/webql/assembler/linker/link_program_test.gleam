import gleam/dict
import gleam/dynamic
import webql/assembler/linker/link_program
import webql/assembler/linker/program
import webql/graph
import webql/schema

pub fn link_program_links_operation_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "user", node: "GetUser")],
      edges: [],
    )

  let assert Ok(linked) = link_program.link(document, operations())

  assert linked.edges == []
  assert case dict.get(linked.nodes, "user") {
    Ok(program.Node(_)) -> True
    _ -> False
  }
}

pub fn link_program_links_edges_to_routes_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "user", node: "GetUser")],
      edges: [
        graph.Edge(
          source: graph.Output(path: ["user_id"]),
          target: graph.Input(path: ["user", "id"]),
        ),
      ],
    )

  let assert Ok(linked) = link_program.link(document, operations())

  assert linked.edges
    == [
      program.Edge(
        source: program.Output(path: ["user_id"]),
        target: program.Input(path: ["user", "id"]),
      ),
    ]
}

fn resolver() {
  schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}

fn operation() {
  schema.Operation(
    inputs: dict.new(),
    outputs: dict.new(),
    resolver: resolver(),
  )
}

fn operations() {
  schema.Schema(
    operations: dict.from_list([#("GetUser", operation())]),
    ports: [],
  )
}
