import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import webql/assembler/plan
import webql/engine/basic
import webql/interpreter/interpret_plan
import webql/interpreter/interpret_step
import webql/interpreter/progress
import webql/memory/kv
import webql/schema

pub fn interpret_step_runs_function_resolver_test() {
  let engine = basic.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(4))
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "inc",
        node: plan.Node(
          schema.Resolver(resolver: fn(inputs) {
            let assert Ok(inputs) =
              decode.run(inputs, decode.dict(decode.string, decode.dynamic))
            let assert Ok(raw_number) = dict.get(inputs, "n")
            let assert Ok(number) = decode.run(raw_number, decode.int)

            engine.finish_plan(
              engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
              fn(_memory) {
                Ok(
                  dynamic.properties([
                    #(dynamic.string("value"), dynamic.int(number + 1)),
                  ]),
                )
              },
            )
          }),
        ),
      ),
      [
        plan.Edge(
          source: plan.Output(path: ["input"]),
          target: plan.Input(path: ["inc", "n"]),
        ),
      ],
      engine,
      memory,
      interpret_plan.interpret,
    )

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(memory) {
        let assert Ok(output) = kv.get(memory, ["inc", "value"])
        assert decode.run(output, decode.int) == Ok(5)
        Ok(dynamic.nil())
      }),
    )
  })
}

pub fn interpret_step_reports_missing_input_test() {
  let engine = basic.new()
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "op",
        node: plan.Node(
          schema.Resolver(resolver: fn(_inputs) {
            engine.finish_plan(
              engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
              fn(_memory) { Ok(dynamic.nil()) },
            )
          }),
        ),
      ),
      [
        plan.Edge(
          source: plan.Output(path: ["missing"]),
          target: plan.Input(path: ["op", "value"]),
        ),
      ],
      engine,
      kv.new(),
      interpret_plan.interpret,
    )

  engine.run(fn() {
    Ok(
      engine.finish_step(task, fn(result) {
        let assert Error(_) = result
        Ok(kv.new())
      }),
    )
  })
}

pub fn interpret_step_reports_invalid_output_test() {
  let engine = basic.new()
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "invalid",
        node: plan.Node(
          schema.Resolver(resolver: fn(_inputs) {
            engine.finish_plan(
              engine.start_plan(fn() { Ok(#(kv.new(), [])) }),
              fn(_memory) { Ok(dynamic.nil()) },
            )
          }),
        ),
      ),
      [],
      engine,
      kv.new(),
      interpret_plan.interpret,
    )

  engine.run(fn() {
    Ok(
      engine.finish_step(task, fn(result) {
        let assert Error(_) = result
        Ok(kv.new())
      }),
    )
  })
}

pub fn interpret_step_runs_inline_resolver_test() {
  let engine = basic.new()
  let memory = kv.set(kv.new(), ["input"], dynamic.int(9))
  let task =
    interpret_step.interpret(
      plan.Step(
        name: "inline",
        node: plan.Supernode(
          plan: plan.Plan(
            edges: [
              plan.Edge(
                source: plan.Output(path: ["value"]),
                target: plan.Input(path: ["output"]),
              ),
            ],
            batches: [],
          ),
        ),
      ),
      [
        plan.Edge(
          source: plan.Output(path: ["input"]),
          target: plan.Input(path: ["inline", "value"]),
        ),
      ],
      engine,
      memory,
      fn(_plan, memory, engine, inputs) {
        engine.start_plan(fn() {
          let assert Ok(memory) = progress.add_parameters(memory, inputs)
          Ok(#(memory, []))
        })
      },
    )

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(memory) {
        let assert Ok(output) = kv.get(memory, ["inline", "output"])
        assert decode.run(output, decode.int) == Ok(9)
        Ok(dynamic.nil())
      }),
    )
  })
}
