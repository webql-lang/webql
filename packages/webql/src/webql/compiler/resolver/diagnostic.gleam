import webql/compiler/source

pub type DiagnosticKind {
  UnknownPort(name: String)
  UnknownNode(name: String)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  DuplicateReturn(name: String)
  DuplicateParameter(name: String)
  DuplicateSupernode(name: String)
  DuplicateNode(name: String)
  DuplicateEdgeInput(path: List(String))
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
