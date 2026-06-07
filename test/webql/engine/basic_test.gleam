import gleam/dynamic
@target(erlang)
import gleam/erlang/process
@target(javascript)
import gleam/javascript/promise
@target(javascript)
import gleam/list
import webql/engine/basic
import webql/memory
import webql/runner/diagnostic

pub fn basic_new_runs_empty_plan_test() {
  let engine = basic.new()
  let initial = memory.new()
  let task = engine.handle_start_plan(fn() { Ok(#(initial, [])) })

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(memory) {
        assert memory == initial
        Ok(dynamic.nil())
      }),
    )
  })
}

pub fn basic_new_runs_plan_batches_in_sequence_test() {
  let engine = basic.new()
  let initial = memory.new()
  let first = memory.set(memory.new(), ["first"], dynamic.int(1))
  let second = memory.set(memory.new(), ["second"], dynamic.int(2))
  let task =
    engine.handle_start_plan(fn() {
      Ok(
        #(initial, [
          fn(memory) {
            let batch =
              engine.handle_start_batch(fn() {
                Ok([
                  engine.handle_finish_batch(
                    memory,
                    engine.handle_start_batch(fn() { Ok([]) }),
                    memory.merge,
                  ),
                  engine.handle_finish_batch(
                    first,
                    engine.handle_start_batch(fn() { Ok([]) }),
                    memory.merge,
                  ),
                ])
              })

            engine.handle_finish_batch(memory, batch, memory.merge)
          },
          fn(memory) {
            let batch =
              engine.handle_start_batch(fn() {
                Ok([
                  engine.handle_finish_batch(
                    second,
                    engine.handle_start_batch(fn() { Ok([]) }),
                    memory.merge,
                  ),
                ])
              })

            engine.handle_finish_batch(memory, batch, memory.merge)
          },
        ]),
      )
    })

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(memory) {
        assert memory.get(memory, ["first"]) == Ok(dynamic.int(1))
        assert memory.get(memory, ["second"]) == Ok(dynamic.int(2))
        Ok(dynamic.nil())
      }),
    )
  })
}

@target(erlang)
pub fn basic_start_plan_starts_immediately_test() {
  let engine = basic.new()
  let events = process.new_subject()

  let task =
    engine.handle_start_plan(fn() {
      process.send(events, 1)
      Ok(#(memory.new(), []))
    })

  let assert Ok(event) = process.receive(events, within: 1000)
  assert event == 1

  engine.handle_run(fn() {
    Ok(engine.handle_finish_plan(task, fn(_memory) { Ok(dynamic.nil()) }))
  })
}

@target(javascript)
pub fn basic_start_plan_starts_immediately_test() {
  let engine = basic.new()
  let #(event, send_event) = promise.start()

  let _task =
    engine.handle_start_plan(fn() {
      send_event(1)
      Ok(#(memory.new(), []))
    })

  promise.map(event, fn(event) {
    assert event == 1
    Nil
  })
}

pub fn basic_batch_can_join_same_task_more_than_once_test() {
  let engine = basic.new()
  let shared =
    engine.handle_finish_batch(
      memory.set(memory.new(), ["value"], dynamic.int(1)),
      engine.handle_start_batch(fn() { Ok([]) }),
      memory.merge,
    )

  let task =
    engine.handle_finish_batch(
      memory.new(),
      engine.handle_start_batch(fn() { Ok([shared, shared]) }),
      memory.merge,
    )

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(memory) {
        assert memory.get(memory, ["value"]) == Ok(dynamic.int(1))
        Ok(dynamic.nil())
      }),
    )
  })
}

@target(erlang)
pub fn basic_batch_runs_steps_concurrently_test() {
  let engine = basic.new()
  let events = process.new_subject()

  let slow =
    engine.handle_finish_step(
      engine.handle_start_step(fn() {
        Ok(
          engine.handle_finish_plan(
            engine.handle_start_plan(fn() {
              process.sleep(100)
              process.send(events, 1)
              Ok(#(memory.new(), []))
            }),
            fn(_memory) { Ok(dynamic.nil()) },
          ),
        )
      }),
      fn(_result) { Ok(memory.set(memory.new(), ["winner"], dynamic.int(1))) },
    )

  let fast =
    engine.handle_finish_step(
      engine.handle_start_step(fn() {
        Ok(
          engine.handle_finish_plan(
            engine.handle_start_plan(fn() {
              process.send(events, 2)
              Ok(#(memory.new(), []))
            }),
            fn(_memory) { Ok(dynamic.nil()) },
          ),
        )
      }),
      fn(_result) { Ok(memory.set(memory.new(), ["winner"], dynamic.int(2))) },
    )

  let task =
    engine.handle_finish_batch(
      memory.new(),
      engine.handle_start_batch(fn() { Ok([slow, fast]) }),
      memory.merge,
    )

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(memory) {
        assert memory.get(memory, ["winner"]) == Ok(dynamic.int(2))
        Ok(dynamic.nil())
      }),
    )
  })

  let assert Ok(first) = process.receive(events, within: 1000)
  let assert Ok(second) = process.receive(events, within: 1000)
  assert [first, second] == [2, 1]
}

@target(javascript)
pub fn basic_batch_runs_steps_concurrently_test() {
  let slow =
    promise.map(promise.wait(100), fn(_) {
      #(1, memory.set(memory.new(), ["winner"], dynamic.int(1)))
    })

  let fast =
    promise.map(promise.wait(0), fn(_) {
      #(2, memory.set(memory.new(), ["winner"], dynamic.int(2)))
    })

  promise.await(promise.race_list([slow, fast]), fn(first) {
    promise.map(promise.await_list([slow, fast]), fn(steps) {
      let memory =
        list.fold(steps, memory.new(), fn(memory, step) {
          memory.merge(memory, step.1)
        })

      assert first.0 == 2
      assert memory.get(memory, ["winner"]) == Ok(dynamic.int(2))
      Nil
    })
  })
}

pub fn basic_finish_plan_skips_callback_on_error_test() {
  let engine = basic.new()
  let task =
    engine.handle_start_plan(fn() {
      Error(
        diagnostic.Diagnostic(
          kind: diagnostic.MissingReturn(message: dynamic.nil()),
        ),
      )
    })

  engine.handle_run(fn() {
    Ok(
      engine.handle_finish_plan(task, fn(_memory) {
        let called = True
        assert called == False
        Ok(dynamic.nil())
      }),
    )
  })
}
