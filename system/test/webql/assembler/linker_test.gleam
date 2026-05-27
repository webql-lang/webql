import gleam/dict
import gleam/dynamic
import webql/assembler/linker
import webql/assembler/linker/diagnostic
import webql/assembler/linker/program
import webql/graph
import webql/schema

pub fn linker_links_graph_module_test() {
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

  let l = linker.new(document)
  let assert Ok(linked) = linker.link(l, operations())

  assert linked.edges
    == [
      program.Edge(
        source: program.Output(path: ["user_id"]),
        target: program.Input(path: ["user", "id"]),
      ),
    ]
  assert case dict.get(linked.nodes, "user") {
    Ok(program.Node(_)) -> True
    _ -> False
  }
}

pub fn linker_links_constant_edges_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "user", node: "GetUser")],
      edges: [
        graph.Edge(
          source: graph.Static(value: graph.Int(42)),
          target: graph.Input(path: ["user", "id"]),
        ),
      ],
    )

  let l = linker.new(document)
  let assert Ok(linked) = linker.link(l, operations())

  assert linked.edges
    == [
      program.Edge(
        source: program.Static(value: dynamic.int(42)),
        target: program.Input(path: ["user", "id"]),
      ),
    ]
}

pub fn linker_reports_unknown_operators_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "missing", node: "Missing")],
      edges: [],
    )

  let l = linker.new(document)
  let result = linker.link(l, operations())

  assert result
    == Error(diagnostic.Diagnostic(kind: diagnostic.UnknownOperator("Missing")))
}

fn resolver() {
  schema.Resolver(resolver: fn(_inputs) { dynamic.properties([]) })
}

fn operator() {
  schema.Operation(
    inputs: dict.new(),
    outputs: dict.new(),
    resolver: resolver(),
  )
}

fn operations() {
  schema.Schema(
    operations: dict.from_list([#("GetUser", operator())]),
    ports: [],
  )
}
