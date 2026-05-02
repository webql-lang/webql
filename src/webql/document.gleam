import gleam/dict
import gleam/dynamic

pub type Document {
  Document(operators: dict.Dict(String, Operator), typenames: List(Typename))
}

pub type Operator {
  Operator(
    parameters: dict.Dict(String, Parameter),
    returns: dict.Dict(String, Return),
    resolver: Resolver,
  )
}

pub type Typename {
  Typename(name: String)
}

pub type Resolver {
  Resolver(
    resolver: fn(dict.Dict(String, dynamic.Dynamic)) ->
      Result(dict.Dict(String, dynamic.Dynamic), String),
  )
}

pub type Parameter {
  Parameter(name: String, typename: String)
}

pub type Return {
  Return(name: String, typename: String)
}
