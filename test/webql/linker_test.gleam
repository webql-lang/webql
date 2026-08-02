import gleam/dict
import gleam/dynamic
import gleam/list
import webql/graph
import webql/linker
import webql/program
import webql/schema

pub fn linker_links_empty_graph_test() {
  let document = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])
  let catalog = schema.Schema(nodes: dict.new(), ports: [])

  let linker = linker.new(document, catalog)
  let assert Ok(program.Program(edges:, batches:)) = linker.link(linker)

  assert edges == []
  assert batches == []
}

pub fn linker_returns_program_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [
        graph.Node(name: "normalize", node: "Normalize"),
        graph.Node(name: "user", node: "GetUser"),
        graph.Node(name: "posts", node: "GetPosts"),
        graph.Node(name: "stats", node: "GetStats"),
        graph.Node(name: "format", node: "Format"),
      ],
      edges: [
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
          target: graph.Input(path: ["stats", "posts"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["user", "name"]),
          target: graph.Input(path: ["format", "name"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["stats", "count"]),
          target: graph.Input(path: ["format", "post_count"]),
        ),
        graph.Edge(
          source: graph.Output(path: ["format", "text"]),
          target: graph.Input(path: ["summary"]),
        ),
      ],
    )
  let catalog =
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
        )
        |> dict.insert(
          "GetStats",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        )
        |> dict.insert(
          "Format",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  let linker = linker.new(document, catalog)
  let assert Ok(result) = linker.link(linker)
  let program.Program(edges:, batches:) = result

  assert edges
    == [
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
        target: program.Input(path: ["stats", "posts"]),
      ),
      program.Edge(
        source: program.Output(path: ["user", "name"]),
        target: program.Input(path: ["format", "name"]),
      ),
      program.Edge(
        source: program.Output(path: ["stats", "count"]),
        target: program.Input(path: ["format", "post_count"]),
      ),
      program.Edge(
        source: program.Output(path: ["format", "text"]),
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

  assert batch_step_names
    == [["normalize"], ["user"], ["posts"], ["stats"], ["format"]]
}

pub fn linker_links_supernodes_test() {
  let inline_graph =
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
      nodes: [graph.Supernode(name: "normalize", graph: inline_graph)],
      edges: [],
    )
  let catalog =
    schema.Schema(
      nodes: dict.new()
        |> dict.insert(
          "Add",
          schema.Node(inputs: dict.new(), outputs: dict.new()),
        ),
      ports: [],
    )

  let linker = linker.new(document, catalog)
  let assert Ok(result) = linker.link(linker)
  let assert [program.Batch(steps: [step])] = result.batches

  let program.Step(name: step_name, node: step_node) = step
  assert step_name == "normalize"

  let inner_names = case step_node {
    program.Supernode(program: inner) ->
      list.map(inner.batches, fn(b) {
        let program.Batch(steps: batch_steps) = b
        list.map(batch_steps, fn(batch_step) {
          let program.Step(name: n, ..) = batch_step
          n
        })
      })
    program.Node(_) -> []
  }

  assert inner_names == [["add"]]
}

pub fn linker_converts_all_literal_values_test() {
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

  let catalog =
    schema.Schema(
      nodes: dict.insert(
        dict.new(),
        "Format",
        schema.Node(inputs: dict.new(), outputs: dict.new()),
      ),
      ports: [],
    )

  let linker = linker.new(document, catalog)
  let assert Ok(program.Program(edges:, ..)) = linker.link(linker)

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

pub fn linker_batches_independent_nodes_test() {
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

  let catalog =
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

  let linker = linker.new(document, catalog)
  let assert Ok(program.Program(batches: [program.Batch(steps:)], ..)) =
    linker.link(linker)

  let names = list.map(steps, fn(step) { step.name })

  assert list.contains(names, "left")
  assert list.contains(names, "right")
}

pub fn linker_ignores_self_dependencies_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "math", node: "Math")],
      edges: [
        graph.Edge(
          source: graph.Output(path: ["math", "value"]),
          target: graph.Input(path: ["math", "left"]),
        ),
      ],
    )

  let catalog =
    schema.Schema(
      nodes: dict.insert(
        dict.new(),
        "Math",
        schema.Node(inputs: dict.new(), outputs: dict.new()),
      ),
      ports: [],
    )

  let linker = linker.new(document, catalog)
  let assert Ok(program.Program(batches: [program.Batch(steps: [step])], ..)) =
    linker.link(linker)

  assert step.name == "math"
}

pub fn linker_reports_unknown_nodes_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "missing", node: "Missing")],
      edges: [],
    )
  let catalog = schema.Schema(nodes: dict.new(), ports: [])
  let linker = linker.new(document, catalog)

  assert linker.link(linker)
    == Error(linker.Diagnostic(kind: linker.UnknownNode("Missing")))
}

pub fn linker_reports_cycles_test() {
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
  let catalog =
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
  let linker = linker.new(document, catalog)

  let assert Error(linker.Diagnostic(kind: linker.CycleDetected(remaining:))) =
    linker.link(linker)

  assert list.contains(remaining, "left")
  assert list.contains(remaining, "right")
}
