import gleam/bool
import gleam/dict
import gleam/list
import gleam/set
import webql/engine/scheduler/diagnostic

pub type Graph {
  Graph(dependencies: dict.Dict(String, set.Set(String)))
}

/// Topologically sorts a graph into batches of node names.
pub fn topology(
  graph: Graph,
) -> Result(List(List(String)), diagnostic.Diagnostic) {
  let Graph(dependencies:) = graph
  toposort(dependencies, [])
}

// PRIVATE FUNCTIONS
// =================
fn toposort(
  dependencies: dict.Dict(String, set.Set(String)),
  batches: List(List(String)),
) {
  use <- bool.guard(
    when: dict.is_empty(dependencies),
    return: Ok(list.reverse(batches)),
  )

  case toposort_batch(dependencies) {
    [] ->
      Error(
        diagnostic.Diagnostic(
          kind: diagnostic.CycleDetected(remaining: dict.keys(dependencies)),
        ),
      )

    batch ->
      dependencies
      |> drop_dependencies(batch)
      |> toposort([batch, ..batches])
  }
}

fn toposort_batch(dependencies: dict.Dict(String, set.Set(String))) {
  dependencies
  |> dict.to_list()
  |> list.filter_map(fn(pair) {
    let #(node, upstream) = pair

    case set.is_empty(upstream) {
      True -> Ok(node)
      False -> Error(Nil)
    }
  })
}

fn drop_dependencies(
  dependencies: dict.Dict(String, set.Set(String)),
  batch: List(String),
) {
  let dependencies =
    list.fold(batch, dependencies, fn(dependencies, node) {
      dict.delete(dependencies, node)
    })

  dependencies
  |> dict.to_list()
  |> list.fold(dict.new(), fn(dependencies, pair) {
    let #(node, upstream) = pair

    let upstream =
      list.fold(batch, upstream, fn(upstream, node) {
        set.delete(upstream, node)
      })

    dict.insert(dependencies, node, upstream)
  })
}
