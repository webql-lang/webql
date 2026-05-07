import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/document
import webql/engine/system/linker
import webql/engine/system/scheduler
import webql/engine/system/traverser
import webql/graph

fn add_resolver() {
  document.Resolver(resolver: fn(inputs) {
    let assert Ok(l) = dict.get(inputs, "l")
    let assert Ok(r) = dict.get(inputs, "r")
    let assert Ok(l) = decode.run(l, decode.int)
    let assert Ok(r) = decode.run(r, decode.int)

    Ok(dict.from_list([#("value", dynamic.int(l + r))]))
  })
}

fn document() {
  document.Document(
    operators: dict.from_list([
      #(
        "Math.Add",
        document.Operator(
          parameters: dict.new(),
          returns: dict.new(),
          resolver: add_resolver(),
        ),
      ),
    ]),
    typenames: [],
  )
}

pub fn engine_executes_graph_module_test() {
  let module =
    graph.Module(
      operation: graph.Operation(
        parameters: [graph.Parameter(name: "input", typename: "Int")],
        returns: [graph.Return(name: "output", typename: "Int")],
        nodes: [graph.ExternalNode(name: "add", node: "Math.Add")],
        edges: [
          graph.Edge(
            from: graph.Output(path: ["input"]),
            to: graph.Input(path: ["add", "l"]),
          ),
          graph.Edge(
            from: graph.PrimitiveOutput(value: graph.IntPrimitive(1)),
            to: graph.Input(path: ["add", "r"]),
          ),
          graph.Edge(
            from: graph.Output(path: ["add", "value"]),
            to: graph.Input(path: ["output"]),
          ),
        ],
      ),
    )

  let assert Ok(linked_plan) =
    module
    |> linker.new()
    |> linker.link(document())

  let assert Ok(executable_plan) =
    linked_plan
    |> scheduler.new()
    |> scheduler.schedule()

  let assert Ok(outputs) =
    executable_plan
    |> traverser.new()
    |> traverser.traverse(dict.from_list([#("input", dynamic.int(2))]))

  let assert Ok(output) = dict.get(outputs, "output")
  assert decode.run(output, decode.int) == Ok(3)
}
