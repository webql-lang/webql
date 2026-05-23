import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/engine/basic
import webql/interpreter
import webql/memory/kv

pub fn interpreter_routes_parameter_to_output_test() {
  let engine = basic.new()
  let task =
    interpreter.interpret(
      interpreter.new(
        plan.Plan(
          routes: [plan.Route(from: ["input"], to: ["output"])],
          batches: [],
        ),
      ),
      kv.new(),
      engine,
      dynamic.properties([#(dynamic.string("input"), dynamic.int(7))]),
    )

  engine.run(fn() {
    Ok(
      engine.finish_step(task, fn(result) {
        let assert Ok(outputs) = result
        let assert Ok(outputs) =
          decode.run(outputs, decode.dict(decode.string, decode.dynamic))
        let assert Ok(output) = dict.get(outputs, "output")
        assert decode.run(output, decode.int) == Ok(7)
        Ok(kv.new())
      }),
    )
  })
}
