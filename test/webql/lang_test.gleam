import webql/graph
import webql/introspection as schema
import webql/lang

pub fn compile_loads_spec_and_compiles_source_test() {
  let source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let assert Ok(module) =
    lang.compile(
      source,
      schema.Schema(
        operators: [
          schema.Operator(
            name: "Math",
            parameters: [
              schema.Parameter(name: "l", typename: "Int"),
              schema.Parameter(name: "r", typename: "Int"),
            ],
            returns: [schema.Return(name: "value", typename: "Int")],
          ),
        ],
        typenames: [],
      ),
    )

  assert module
    == graph.Module(
      operation: graph.Operation(
        parameters: [graph.Parameter(name: "in", typename: "Int")],
        returns: [graph.Return(name: "out", typename: "Int")],
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
