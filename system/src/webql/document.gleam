import gleam/dict
import gleam/dynamic

pub type Document(task) {
  Document(
    operators: dict.Dict(String, Operator(task)),
    typenames: List(Typename),
  )
}

pub type Operator(task) {
  Operator(
    parameters: dict.Dict(String, Parameter),
    returns: dict.Dict(String, Return),
    resolver: Resolver(task),
  )
}

pub type Typename {
  Typename(name: String)
}

pub type Resolver(task) {
  Resolver(resolver: fn(dynamic.Dynamic) -> task)
}

pub type Parameter {
  Parameter(name: String, typename: String)
}

pub type Return {
  Return(name: String, typename: String)
}
