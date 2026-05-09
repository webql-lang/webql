import gleam/dynamic
import webql/resolution

pub type Batches(state, operation, error) =
  fn(
    state,
    List(operation),
    fn(state, operation) -> resolution.Resolution(state, error),
  ) ->
    resolution.Resolution(state, error)

pub type Steps(state, error) =
  fn(
    state,
    List(resolution.Resolution(state, error)),
    fn(state, state) -> state,
  ) ->
    resolution.Resolution(state, error)

pub type Resolve(state, error) =
  fn(
    resolution.Resolution(dynamic.Dynamic, dynamic.Dynamic),
    fn(Result(dynamic.Dynamic, dynamic.Dynamic)) -> Result(state, error),
  ) ->
    resolution.Resolution(state, error)

pub type Inline(state, error) =
  fn(resolution.Resolution(state, error), fn(state) -> Result(state, error)) ->
    resolution.Resolution(state, error)

pub type Complete(state, error) =
  fn(
    resolution.Resolution(state, error),
    fn(state) -> Result(dynamic.Dynamic, error),
  ) ->
    resolution.Resolution(dynamic.Dynamic, error)

pub type Runtime(state, operation, error) {
  Runtime(
    batches: Batches(state, operation, error),
    steps: Steps(state, error),
    resolve: Resolve(state, error),
    inline: Inline(state, error),
    complete: Complete(state, error),
  )
}
