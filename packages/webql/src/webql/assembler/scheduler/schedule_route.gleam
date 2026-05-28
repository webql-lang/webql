import gleam/bool
import gleam/dict
import gleam/option
import gleam/set
import webql/assembler/linker/program

/// Adds a scheduled dependency for an edge.
pub fn schedule(
  dependencies: dict.Dict(String, set.Set(String)),
  edge: program.Edge,
) -> dict.Dict(String, set.Set(String)) {
  let scheduled = case edge {
    program.Edge(
      source: program.Output(path: [producer, ..]),
      target: program.Input(path: [consumer, ..]),
    ) -> {
      schedule_dependencies(dependencies, consumer, producer)
    }

    _edge -> option.None
  }

  scheduled_dependencies(scheduled, dependencies)
}

// PRIVATE FUNCTIONS
// =================
fn scheduled_dependencies(
  scheduled: option.Option(dict.Dict(String, set.Set(String))),
  dependencies: dict.Dict(String, set.Set(String)),
) {
  case scheduled {
    option.Some(dependencies) -> dependencies
    option.None -> dependencies
  }
}

fn schedule_dependencies(
  dependencies: dict.Dict(String, set.Set(String)),
  consumer: String,
  producer: String,
) {
  case dict.get(dependencies, consumer), dict.get(dependencies, producer) {
    Ok(_consumer), Ok(_producer) -> {
      use <- bool.guard(when: producer == consumer, return: option.None)
      option.Some(schedule_dependency(dependencies, consumer, producer))
    }

    _consumer, _producer -> option.None
  }
}

fn schedule_dependency(
  dependencies: dict.Dict(String, set.Set(String)),
  consumer: String,
  producer: String,
) {
  dict.upsert(dependencies, consumer, fn(upstream) {
    case upstream {
      option.Some(upstream) -> set.insert(upstream, producer)
      option.None -> set.from_list([producer])
    }
  })
}
