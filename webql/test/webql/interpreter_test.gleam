import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/engine/basic
import webql/memory
import webql/runner

pub fn runner_routes_parameter_to_output_test() {
  let engine = basic.new()
  let task =
    runner.run(
      runner.new(
        plan.Plan(
          edges: [
            plan.Edge(
              source: plan.Output(path: ["input"]),
              target: plan.Input(path: ["output"]),
            ),
          ],
          batches: [],
        ),
      ),
      memory.new(),
      engine,
      dynamic.properties([#(dynamic.string("input"), dynamic.int(7))]),
    )

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_step(task, fn(result) {
        let assert Ok(outputs) = result
        let assert Ok(outputs) =
          decode.run(outputs, decode.dict(decode.string, decode.dynamic))
        let assert Ok(output) = dict.get(outputs, "output")
        assert decode.run(output, decode.int) == Ok(7)
        Ok(memory.new())
      }),
    )
  })
}
