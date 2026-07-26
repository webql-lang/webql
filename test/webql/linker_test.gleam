import gleam/dict
import gleam/dynamic
import gleam/list
import webql/graph
import webql/linker
import webql/plan
import webql/schema

pub fn linker_links_empty_graph_test() {
  let document = graph.Graph(parameters: [], returns: [], nodes: [], edges: [])

  let linker = linker.new(document, operations())
  let assert Ok(plan.Plan(edges:, batches:)) = linker.link(linker)

  assert edges == []
  assert batches == []
}

pub fn linker_returns_executable_plan_test() {
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

  let linker = linker.new(document, operations())
  let assert Ok(result) = linker.link(linker)
  let plan.Plan(edges:, batches:) = result

  assert edges
    == [
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
        target: plan.Input(path: ["stats", "posts"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["user", "name"]),
        target: plan.Input(path: ["format", "name"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["stats", "count"]),
        target: plan.Input(path: ["format", "post_count"]),
      ),
      plan.Edge(
        source: plan.Output(path: ["format", "text"]),
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

  assert batch_step_names
    == [["normalize"], ["user"], ["posts"], ["stats"], ["format"]]
}

pub fn linker_links_inline_resolvers_test() {
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

  let linker = linker.new(document, operations())
  let assert Ok(result) = linker.link(linker)
  let assert [plan.Batch(steps: [step])] = result.batches

  let plan.Step(name: step_name, node: step_resolver) = step
  assert step_name == "normalize"

  let inner_names = case step_resolver {
    plan.Supernode(plan: inner) ->
      list.map(inner.batches, fn(b) {
        let plan.Batch(steps: batch_steps) = b
        list.map(batch_steps, fn(batch_step) {
          let plan.Step(name: n, ..) = batch_step
          n
        })
      })
    plan.Node(_) -> []
  }

  assert inner_names == [["add"]]
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
      #("GetStats", operation()),
      #("Format", operation()),
      #("Add", operation()),
    ]),
    ports: [],
  )
}
