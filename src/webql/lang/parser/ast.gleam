pub type Module {
  Module(definitions: List(Definition))
}

pub type Definition {
  TypeDefinition(name: String, fields: List(Port))
  NodeDefinition(name: String, inputs: List(Port), outputs: List(Port))
  FunctionDefinition(
    name: String,
    inputs: List(Port),
    outputs: List(Port),
    body: List(Statement),
  )
}

pub type Port {
  Port(name: String, annotation: Annotation)
}

pub type Annotation {
  NamedTypeAnnotation(name: String)
  ListTypeAnnotation(annotation: Annotation)
}

pub type Statement {
  BindingStatement(alias: String, node: String)
  EdgeStatement(from: Endpoint, to: Endpoint)
  LiteralStatement(literal: Literal)
}

pub type Endpoint {
  NodeEndpoint(alias: String, port: String)
  InterfaceEndpoint(name: String)
  LiteralEndpoint(Literal)
}

pub type Literal {
  IntLiteral(value: Int)
  FloatLiteral(value: Float)
  StringLiteral(value: String)
  BoolLiteral(value: Bool)
}
