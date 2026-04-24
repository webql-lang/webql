import webql/compiler/reference
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
  DuplicateEdge(input: reference.Input)
  TypeMismatch(expected: String, found: String)
  InvalidEdge(from: String, to: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
