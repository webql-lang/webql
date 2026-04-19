import webql/lang/source
import webql/lang/resolver/reference

pub type DiagnosticKind {
  UnknownTypename(name: String)
  UnknownNode(name: String)
  UnknownOperation(name: String)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  DuplicateReturn(name: String)
  DuplicateParameter(name: String)
  DuplicateBinding(name: String)
  DuplicateEdge(edge: #(reference.Output, reference.Input))
  TypeMismatch(expected: String, found: String)
  InvalidEdge(from: String, to: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
