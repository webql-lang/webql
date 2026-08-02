import gleam/bool
import gleam/dict
import gleam/dynamic
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import webql/graph
import webql/program
import webql/schema
import webql/topology

pub type DiagnosticKind {
  UnknownNode(name: String)
  CycleDetected(remaining: List(String))
  InvalidProgram
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}

pub opaque type Linker {
  Linker(graph: graph.Graph, schema: schema.Schema)
}

/// Creates a new linker instance from a graph and schema.
pub fn new(graph: graph.Graph, schema: schema.Schema) -> Linker {
  Linker(graph:, schema:)
}

/// Links a graph into a program.
pub fn link(linker: Linker) -> Result(program.Program, Diagnostic) {
  link_program(linker.graph, linker.schema)
}

// PRIVATE FUNCTIONS
// =================
fn link_program(
  graph: graph.Graph,
  schema: schema.Schema,
) -> Result(program.Program, Diagnostic) {
  let graph.Graph(nodes:, edges:, ..) = graph

  let nodes =
    list.fold(nodes, dict.new(), fn(nodes, node) {
      let name = case node {
        graph.Node(name:, ..) -> name
        graph.Supernode(name:, ..) -> name
      }

      dict.insert(nodes, name, node)
    })

  let dependencies =
    nodes
    |> dict.keys()
    |> list.fold(dict.new(), fn(dependencies, node) {
      dict.insert(dependencies, node, set.new())
    })

  let dependencies =
    list.fold(edges, dependencies, fn(dependencies, edge) {
      link_route(dependencies, edge)
    })

  case topology.topology(topology.Topology(dependencies:)) {
    Ok(topology) -> {
      use batches <- result.try(link_batch(topology, nodes, schema))
      let edges = link_edge(edges)
      Ok(program.Program(edges:, batches:))
    }

    Error(remaining) -> {
      Error(Diagnostic(CycleDetected(remaining:)))
    }
  }
}

fn link_route(
  dependencies: dict.Dict(String, set.Set(String)),
  edge: graph.Edge,
) -> dict.Dict(String, set.Set(String)) {
  case edge {
    graph.Edge(
      source: graph.Output(path: [producer, ..]),
      target: graph.Input(path: [consumer, ..]),
    ) -> link_dependencies(dependencies, consumer, producer)

    _edge -> dependencies
  }
}

fn link_dependencies(
  dependencies: dict.Dict(String, set.Set(String)),
  consumer: String,
  producer: String,
) {
  use <- bool.guard(
    when: !dict.has_key(dependencies, consumer)
      || !dict.has_key(dependencies, producer),
    return: dependencies,
  )

  use <- bool.guard(when: producer == consumer, return: dependencies)

  link_dependency(dependencies, consumer, producer)
}

fn link_dependency(
  dependencies: dict.Dict(String, set.Set(String)),
  consumer: String,
  producer: String,
) {
  dict.upsert(dependencies, consumer, fn(upstream) {
    case upstream {
      option.Some(upstream) -> set.insert(upstream, producer)
      option.None -> set.from_list([producer])
    }
  })
}

fn link_batch(
  batches: List(List(String)),
  nodes: dict.Dict(String, graph.Node),
  schema: schema.Schema,
) -> Result(List(program.Batch), Diagnostic) {
  case batches {
    [batch, ..batches] -> {
      use steps <- result.try(link_steps(batch, nodes, schema, []))
      use batches <- result.try(link_batch(batches, nodes, schema))

      Ok([program.Batch(steps:), ..batches])
    }

    [] -> Ok([])
  }
}

fn link_steps(
  batch: List(String),
  nodes: dict.Dict(String, graph.Node),
  schema: schema.Schema,
  steps: List(program.Step),
) {
  case batch {
    [name, ..batch] -> {
      use node <- result.try(link_step(nodes, name, schema))
      link_steps(batch, nodes, schema, [program.Step(name:, node:), ..steps])
    }

    [] -> Ok(list.reverse(steps))
  }
}

fn link_step(
  nodes: dict.Dict(String, graph.Node),
  node: String,
  schema: schema.Schema,
) {
  case dict.get(nodes, node) {
    Ok(graph.Node(node:, ..)) -> link_node(node, schema)

    Ok(graph.Supernode(graph:, ..)) -> {
      use program <- result.try(link_program(graph, schema))
      Ok(program.Supernode(program:))
    }

    Error(_nil) -> Error(Diagnostic(kind: InvalidProgram))
  }
}

fn link_node(
  kind: String,
  schema: schema.Schema,
) -> Result(program.Node, Diagnostic) {
  let schema.Schema(nodes:, ..) = schema

  case dict.get(nodes, kind) {
    Ok(_node) -> Ok(program.Node(kind:))
    Error(_nil) -> Error(Diagnostic(kind: UnknownNode(kind)))
  }
}

fn link_edge(edges: List(graph.Edge)) -> List(program.Edge) {
  list.map(edges, fn(edge) {
    case edge {
      graph.Edge(
        source: graph.Output(path: source),
        target: graph.Input(path: target),
      ) ->
        program.Edge(
          source: program.Output(path: source),
          target: program.Input(path: target),
        )

      graph.Edge(
        source: graph.Literal(value:),
        target: graph.Input(path: target),
      ) ->
        program.Edge(
          source: program.Literal(value: link_value(value)),
          target: program.Input(path: target),
        )
    }
  })
}

fn link_value(value: graph.Value) -> dynamic.Dynamic {
  case value {
    graph.Int(value:) -> dynamic.int(value)
    graph.Float(value:) -> dynamic.float(value)
    graph.String(value:) -> dynamic.string(value)
  }
}
