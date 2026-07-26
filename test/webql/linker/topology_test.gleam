import gleam/dict
import gleam/list
import gleam/set
import webql/linker/diagnostic
import webql/linker/topology

pub fn topology_orders_dependency_batches_test() {
  let graph =
    topology.Graph(
      dependencies: dict.new()
      |> dict.insert("zero", set.new())
      |> dict.insert("one", set.from_list(["zero"]))
      |> dict.insert("two", set.from_list(["one"]))
      |> dict.insert("three", set.from_list(["zero", "two"])),
    )

  assert topology.topology(graph)
    == Ok([
      ["zero"],
      ["one"],
      ["two"],
      ["three"],
    ])
}

pub fn topology_keeps_independent_nodes_in_same_batch_test() {
  let graph =
    topology.Graph(
      dependencies: dict.new()
      |> dict.insert("left", set.new())
      |> dict.insert("right", set.new()),
    )

  let assert Ok([batch]) = topology.topology(graph)

  assert list.contains(batch, "left")
  assert list.contains(batch, "right")
}

pub fn topology_reports_cycle_test() {
  let graph =
    topology.Graph(
      dependencies: dict.new()
      |> dict.insert("left", set.from_list(["right"]))
      |> dict.insert("right", set.from_list(["left"])),
    )

  let assert Error(diagnostic.Diagnostic(kind: diagnostic.CycleDetected(
    remaining:,
  ))) = topology.topology(graph)

  assert list.contains(remaining, "left")
  assert list.contains(remaining, "right")
}
