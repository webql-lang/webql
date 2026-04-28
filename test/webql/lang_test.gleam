import webql/graph
import webql/lang
import webql/lang/loader/preschema

pub fn compile_loads_preschema_and_compiles_source_test() {
  let source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let assert Ok(module) =
    lang.compile(
      source,
      preschema.Preschema(typenames: ["Int"], nodes: [
        #("Math", [#("l", "Int"), #("r", "Int")], [#("value", "Int")]),
      ]),
    )

  assert module
    == graph.Module(
      operation: graph.Operation(
        inputs: [graph.Parameter(name: "in", typename: "Int")],
        outputs: [graph.Return(name: "out", typename: "Int")],
        nodes: [graph.ExternalNode(name: "m", node: "Math")],
        edges: [
          graph.Edge(
            from: graph.Output(path: ["in"]),
            to: graph.Input(path: ["m", "l"]),
          ),
          graph.Edge(
            from: graph.PrimitiveOutput(value: graph.IntPrimitive(1)),
            to: graph.Input(path: ["m", "r"]),
          ),
          graph.Edge(
            from: graph.Output(path: ["m", "value"]),
            to: graph.Input(path: ["out"]),
          ),
        ],
      ),
    )
}
