import webql/compiler/source

pub type DiagnosticKind {
  UnknownTypename(name: String)
  UnknownNode(name: String)
  UnknownOperation(name: String)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  DuplicateReturn(name: String)
  DuplicateParameter(name: String)
  DuplicateDefinition(name: String)
  DuplicateBinding(name: String)
  DuplicateEdgeInput(path: List(String))
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
