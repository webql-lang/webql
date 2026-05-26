import gleam/dynamic
import webql/schema

pub type Plan(task) {
  Plan(routes: List(Route), batches: List(Batch(task)))
}

pub type Batch(task) {
  Batch(batch: List(Step(task)))
}

pub type Step(task) {
  Step(name: String, resolver: Resolver(task))
}

pub type Resolver(task) {
  FunctionResolver(function: schema.Resolver(task))
  InlineResolver(plan: Plan(task))
}

pub type Route {
  Route(from: List(String), to: List(String))
  Constant(value: dynamic.Dynamic, to: List(String))
}
