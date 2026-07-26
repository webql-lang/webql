import gleam/dict
import gleam/dynamic
import gleam/list
import webql/graph
import webql/linker/diagnostic
import webql/linker/link_program
import webql/program
import webql/schema

pub fn link_program_builds_program_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [
        graph.Node(name: "normalize", node: "Normalize"),
        graph.Node(name: "user", node: "GetUser"),
        graph.Node(name: "posts", node: "GetPosts"),
      ],
      edges: [
        graph.Edge(
          source: graph.Literal(value: graph.Int(0)),
          target: graph.Input(path: ["normalize", "zero"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["user_id"]),
          target: graph.Input(path: ["normalize", "value"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["normalize", "value"]),
          target: graph.Input(path: ["user", "id"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["user", "id"]),
          target: graph.Input(path: ["posts", "user_id"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["posts", "items"]),
          target: graph.Input(path: ["summary"]),
        ),
      ],
    )
  let schema =
    schema.Schema(
      nodes: dict.new()
        |> dict.insert(
          "Normalize",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        )
        |> dict.insert(
          "GetUser",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        )
        |> dict.insert(
          "GetPosts",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  let assert Ok(program.Program(edges:, batches:)) =
    link_program.link(document, schema)

  assert edges
    == [
      program.Edge(
        source: program.Literal(value: dynamic.int(0)),
        target: program.Input(path: ["normalize", "zero"]),
      ),
      program.Edge(
        source: program.Output(path: ["user_id"]),
        target: program.Input(path: ["normalize", "value"]),
      ),
      program.Edge(
        source: program.Output(path: ["normalize", "value"]),
        target: program.Input(path: ["user", "id"]),
      ),
      program.Edge(
        source: program.Output(path: ["user", "id"]),
        target: program.Input(path: ["posts", "user_id"]),
      ),
      program.Edge(
        source: program.Output(path: ["posts", "items"]),
        target: program.Input(path: ["summary"]),
      ),
    ]

  let batch_step_names =
    list.map(batches, fn(steps) {
      let program.Batch(steps: steps) = steps
      list.map(steps, fn(step) {
        let program.Step(name:, ..) = step
        name
      })
    })

  assert batch_step_names == [["normalize"], ["user"], ["posts"]]
}

pub fn link_program_converts_all_literal_values_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "format", node: "Format")],
      edges: [
        graph.Edge(
          source: graph.Literal(value: graph.Int(1)),
          target: graph.Input(path: ["format", "integer"]),
        ),
        graph.Edge(
          source: graph.Literal(value: graph.Float(1.1)),
          target: graph.Input(path: ["format", "float"]),
        ),
        graph.Edge(
          source: graph.Literal(value: graph.String("one")),
          target: graph.Input(path: ["format", "string"]),
        ),
      ],
    )

  let schema =
    schema.Schema(
      nodes: dict.insert(
        dict.new(),
        "Format",
        schema.Node(inputs: dict.new(), outputs: dict.new()),
      ),
      ports: [],
    )

  let assert Ok(program.Program(edges:, ..)) =
    link_program.link(document, schema)

  assert edges
    == [
      program.Edge(
        source: program.Literal(dynamic.int(1)),
        target: program.Input(["format", "integer"]),
      ),
      program.Edge(
        source: program.Literal(dynamic.float(1.1)),
        target: program.Input(["format", "float"]),
      ),
      program.Edge(
        source: program.Literal(dynamic.string("one")),
        target: program.Input(["format", "string"]),
      ),
    ]
}

pub fn link_program_batches_independent_nodes_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [
        graph.Node(name: "left", node: "Left"),
        graph.Node(name: "right", node: "Right"),
      ],
      edges: [],
    )

  let schema =
    schema.Schema(
      nodes: dict.new()
        |> dict.insert(
          "Left",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        )
        |> dict.insert(
          "Right",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  let assert Ok(program.Program(batches: [program.Batch(steps:)], ..)) =
    link_program.link(document, schema)

  let names = list.map(steps, fn(step) { step.name })

  assert list.contains(names, "left")
  assert list.contains(names, "right")
}

pub fn link_program_links_supernodes_test() {
  let graph =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "add", node: "Add")],
      edges: [],
    )

  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Supernode(name: "normalize", graph:)],
      edges: [],
    )

  let schema =
    schema.Schema(
      nodes: dict.insert(
        dict.new(),
        "Add",
        schema.Node(inputs: dict.new(), outputs: dict.new()),
      ),
      ports: [],
    )

  let assert Ok(result) = link_program.link(document, schema)
  let assert [program.Batch(steps: [step])] = result.batches

  let program.Step(name: step_name, node: step_node) = step
  assert step_name == "normalize"

  let inner_names = case step_node {
    program.Supernode(program: inner) ->
      list.map(inner.batches, fn(b) {
        let program.Batch(steps: inner_steps) = b
        list.map(inner_steps, fn(s) {
          let program.Step(name: s_name, ..) = s
          s_name
        })
      })
    program.Node(_) -> []
  }

  assert inner_names == [["add"]]
}

pub fn link_program_reports_unknown_nodes_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "missing", node: "Missing")],
      edges: [],
    )
  let schema = schema.Schema(nodes: dict.new(), ports: [])

  assert link_program.link(document, schema)
    == Error(diagnostic.Diagnostic(kind: diagnostic.UnknownNode("Missing")))
}

pub fn link_program_reports_cycles_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [
        graph.Node(name: "left", node: "Left"),
        graph.Node(name: "right", node: "Right"),
      ],
      edges: [
        graph.Edge(
          source: graph.Output(path: ["left", "value"]),
          target: graph.Input(path: ["right", "value"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["right", "value"]),
          target: graph.Input(path: ["left", "value"]),
        ),
      ],
    )
  let schema =
    schema.Schema(
      nodes: dict.new()
        |> dict.insert(
          "Left",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        )
        |> dict.insert(
          "Right",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.CycleDetected(
    remaining:,
  ))) = link_program.link(document, schema)

  assert list.contains(remaining, "left")
  assert list.contains(remaining, "right")
}
