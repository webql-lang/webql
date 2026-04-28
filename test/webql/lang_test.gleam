import webql/lang
import webql/lang/compiler/ir
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
    == ir.Module(
      operation: ir.Operation(
        inputs: [ir.Parameter(name: "in", typename: "Int")],
        outputs: [ir.Return(name: "out", typename: "Int")],
        nodes: [ir.ExternalNode(name: "m", node: "Math")],
        edges: [
          ir.Edge(from: ir.Output(path: ["in"]), to: ir.Input(path: ["m", "l"])),
          ir.Edge(
            from: ir.PrimitiveOutput(value: ir.IntPrimitive(1)),
            to: ir.Input(path: ["m", "r"]),
          ),
          ir.Edge(
            from: ir.Output(path: ["m", "value"]),
            to: ir.Input(path: ["out"]),
          ),
        ],
      ),
    )
}
