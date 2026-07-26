import gleam/dict
import gleam/dynamic
import gleam/list
import webql/graph
import webql/linker/diagnostic
import webql/linker/link_plan
import webql/plan
import webql/schema

pub fn link_plan_builds_executable_plan_test() {
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

  let assert Ok(plan.Plan(edges:, batches:)) =
    link_plan.link(document, operations())

  assert edges
    == [
      plan.Edge(
        source: plan.Literal(value: dynamic.int(0)),
        target: plan.Input(path: ["normalize", "zero"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["user_id"]),
        target: plan.Input(path: ["normalize", "value"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["normalize", "value"]),
        target: plan.Input(path: ["user", "id"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["user", "id"]),
        target: plan.Input(path: ["posts", "user_id"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["posts", "items"]),
        target: plan.Input(path: ["summary"]),
      ),
    ]

  let batch_step_names =
    list.map(batches, fn(steps) {
      let plan.Batch(steps: steps) = steps
      list.map(steps, fn(step) {
        let plan.Step(name:, ..) = step
        name
      })
    })

  assert batch_step_names == [["normalize"], ["user"], ["posts"]]
}

pub fn link_plan_converts_all_literal_values_test() {
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

  let assert Ok(plan.Plan(edges:, ..)) = link_plan.link(document, operations())

  assert edges
    == [
      plan.Edge(
        source: plan.Literal(dynamic.int(1)),
        target: plan.Input(["format", "integer"]),
      ),
      plan.Edge(
        source: plan.Literal(dynamic.float(1.1)),
        target: plan.Input(["format", "float"]),
      ),
      plan.Edge(
        source: plan.Literal(dynamic.string("one")),
        target: plan.Input(["format", "string"]),
      ),
    ]
}

pub fn link_plan_batches_independent_nodes_test() {
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

  let assert Ok(plan.Plan(batches: [plan.Batch(steps:)], ..)) =
    link_plan.link(document, operations())

  let names =
    list.map(steps, fn(step) {
      let plan.Step(name:, ..) = step
      name
    })

  assert list.contains(names, "left")
  assert list.contains(names, "right")
}

pub fn link_plan_links_inline_resolvers_test() {
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

  let assert Ok(result) = link_plan.link(document, operations())
  let assert [plan.Batch(steps: [step])] = result.batches

  let plan.Step(name: step_name, node: step_resolver) = step
  assert step_name == "normalize"

  let inner_names = case step_resolver {
    plan.Supernode(plan: inner) ->
      list.map(inner.batches, fn(b) {
        let plan.Batch(steps: inner_steps) = b
        list.map(inner_steps, fn(s) {
          let plan.Step(name: s_name, ..) = s
          s_name
        })
      })
    plan.Node(_) -> []
  }

  assert inner_names == [["add"]]
}

pub fn link_plan_reports_unknown_operations_test() {
  let document =
    graph.Graph(
      parameters: [],
      returns: [],
      nodes: [graph.Node(name: "missing", node: "Missing")],
      edges: [],
    )

  assert link_plan.link(document, operations())
    == Error(
      diagnostic.Diagnostic(kind: diagnostic.UnknownOperation("Missing")),
    )
}

pub fn link_plan_reports_cycles_test() {
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

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.CycleDetected(
    remaining:,
  ))) = link_plan.link(document, operations())

  assert list.contains(remaining, "left")
  assert list.contains(remaining, "right")
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
    operations: dict.from_list([
      #("Normalize", operation()),
      #("GetUser", operation()),
      #("GetPosts", operation()),
      #("Format", operation()),
      #("Left", operation()),
      #("Right", operation()),
      #("Add", operation()),
    ]),
    ports: [],
  )
}
