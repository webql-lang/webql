import gleam/dynamic
import webql/engine/transient
import webql/interpreter/diagnostic
import webql/memory/kv

pub fn transient_new_runs_empty_plan_test() {
  let engine = transient.new()
  let initial = kv.new()
  let task = engine.start_plan(fn() { Ok(#(initial, [])) })

  engine.finish_plan(task, fn(memory) {
    assert memory == initial
    Ok(dynamic.nil())
  })
}

pub fn transient_new_runs_plan_batches_in_sequence_test() {
  let engine = transient.new()
  let initial = kv.new()
  let first = kv.set(kv.new(), ["first"], dynamic.int(1))
  let second = kv.set(kv.new(), ["second"], dynamic.int(2))
  let task =
    engine.start_plan(fn() {
      Ok(
        #(initial, [
          fn(memory) {
            let batch =
              engine.start_batch(fn() {
                Ok([
                  engine.finish_batch(
                    memory,
                    engine.start_batch(fn() { Ok([]) }),
                    kv.merge,
                  ),
                  engine.finish_batch(
                    first,
                    engine.start_batch(fn() { Ok([]) }),
                    kv.merge,
                  ),
                ])
              })

            engine.finish_batch(memory, batch, kv.merge)
          },
          fn(memory) {
            let batch =
              engine.start_batch(fn() {
                Ok([
                  engine.finish_batch(
                    second,
                    engine.start_batch(fn() { Ok([]) }),
                    kv.merge,
                  ),
                ])
              })

            engine.finish_batch(memory, batch, kv.merge)
          },
        ]),
      )
    })

  engine.finish_plan(task, fn(memory) {
    assert kv.get(memory, ["first"]) == Ok(dynamic.int(1))
    assert kv.get(memory, ["second"]) == Ok(dynamic.int(2))
    Ok(dynamic.nil())
  })
}

pub fn transient_finish_plan_skips_callback_on_error_test() {
  let engine = transient.new()
  let task =
    engine.start_plan(fn() {
      Error(
        diagnostic.Diagnostic(
          kind: diagnostic.MissingReturn(message: dynamic.nil()),
        ),
      )
    })

  engine.finish_plan(task, fn(_memory) {
    let called = True
    assert called == False
    Ok(dynamic.nil())
  })
}
