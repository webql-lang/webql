import gleam/bool
import gleam/dict
import gleam/option
import gleam/set
import webql/graph

/// Adds a dependency for an edge.
pub fn link(
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

// PRIVATE FUNCTIONS
// =================
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
