import gleam/dynamic
@target(erlang)
import gleam/erlang/process
@target(javascript)
import gleam/javascript/promise
@target(javascript)
import gleam/list
import webql/engine/transient
import webql/interpreter/diagnostic
import webql/memory/kv

pub fn transient_new_runs_empty_plan_test() {
  let engine = transient.new()
  let initial = kv.new()
  let task = engine.start_plan(fn() { Ok(#(initial, [])) })

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(memory) {
        assert memory == initial
        Ok(dynamic.nil())
      }),
    )
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

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(memory) {
        assert kv.get(memory, ["first"]) == Ok(dynamic.int(1))
        assert kv.get(memory, ["second"]) == Ok(dynamic.int(2))
        Ok(dynamic.nil())
      }),
    )
  })
}

@target(erlang)
pub fn transient_batch_runs_steps_concurrently_test() {
  let engine = transient.new()
  let events = process.new_subject()

  let slow =
    engine.finish_step(
      engine.start_step(fn() {
        Ok(
          engine.finish_plan(
            engine.start_plan(fn() {
              process.sleep(100)
              process.send(events, 1)
              Ok(#(kv.new(), []))
            }),
            fn(_memory) { Ok(dynamic.nil()) },
          ),
        )
      }),
      fn(_result) { Ok(kv.set(kv.new(), ["winner"], dynamic.int(1))) },
    )

  let fast =
    engine.finish_step(
      engine.start_step(fn() {
        Ok(
          engine.finish_plan(
            engine.start_plan(fn() {
              process.send(events, 2)
              Ok(#(kv.new(), []))
            }),
            fn(_memory) { Ok(dynamic.nil()) },
          ),
        )
      }),
      fn(_result) { Ok(kv.set(kv.new(), ["winner"], dynamic.int(2))) },
    )

  let task =
    engine.finish_batch(
      kv.new(),
      engine.start_batch(fn() { Ok([slow, fast]) }),
      kv.merge,
    )

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(memory) {
        assert kv.get(memory, ["winner"]) == Ok(dynamic.int(2))
        Ok(dynamic.nil())
      }),
    )
  })

  let assert Ok(first) = process.receive(events, within: 1000)
  let assert Ok(second) = process.receive(events, within: 1000)
  assert [first, second] == [2, 1]
}

@target(javascript)
pub fn transient_batch_runs_steps_concurrently_test() {
  let slow =
    promise.map(promise.wait(100), fn(_) {
      #(1, kv.set(kv.new(), ["winner"], dynamic.int(1)))
    })

  let fast =
    promise.map(promise.wait(0), fn(_) {
      #(2, kv.set(kv.new(), ["winner"], dynamic.int(2)))
    })

  promise.await(promise.race_list([slow, fast]), fn(first) {
    promise.map(promise.await_list([slow, fast]), fn(steps) {
      let memory =
        list.fold(steps, kv.new(), fn(memory, step) { kv.merge(memory, step.1) })

      assert first.0 == 2
      assert kv.get(memory, ["winner"]) == Ok(dynamic.int(2))
      Nil
    })
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

  engine.run(fn() {
    Ok(
      engine.finish_plan(task, fn(_memory) {
        let called = True
        assert called == False
        Ok(dynamic.nil())
      }),
    )
  })
}
