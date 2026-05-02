import gleam/dict
import gleam/dynamic
import gleam/list

pub type Progress {
  Progress(values: dict.Dict(List(String), dynamic.Dynamic))
}

/// Creates new progress for a plan execution.
pub fn new() -> Progress {
  Progress(values: dict.new())
}

/// Adds values to the current progress instance under a path.
pub fn add_values(
  progress: Progress,
  path: List(String),
  values: dict.Dict(String, dynamic.Dynamic),
) -> Progress {
  values
  |> dict.to_list()
  |> list.fold(progress, fn(progress, entry) {
    let #(name, value) = entry
    add_value(progress, list.append(path, [name]), value)
  })
}

/// Adds a value to the current progress instance.
pub fn add_value(
  progress: Progress,
  path: List(String),
  value: dynamic.Dynamic,
) -> Progress {
  let Progress(values:) = progress
  Progress(values: dict.insert(values, path, value))
}

/// Looks up a value by path.
pub fn get_value(
  progress: Progress,
  path: List(String),
) -> Result(dynamic.Dynamic, Nil) {
  let Progress(values:) = progress
  dict.get(values, path)
}
