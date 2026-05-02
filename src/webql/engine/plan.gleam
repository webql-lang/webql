import gleam/dynamic
import webql/document

pub type Plan {
  Plan(routes: List(Route), batches: List(Batch))
}

pub type Batch {
  Batch(batch: List(Step))
}

pub type Step {
  Step(name: String, resolver: Resolver)
}

pub type Resolver {
  FunctionResolver(function: document.Resolver)
  InlineResolver(plan: Plan)
}

pub type Route {
  Route(from: List(String), to: List(String))
  Constant(value: dynamic.Dynamic, to: List(String))
}
