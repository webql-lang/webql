import gleam/option
import webql/lang/source

pub type DiagnosticKind {
  UnknownType(name: String)
  UnknownNode(alias: String)
  UnknownOperation(name: String)
  UnknownPort(owner: option.Option(String), name: String)
  DuplicateInput(name: String)
  DuplicateOutput(name: String)
  DuplicateAlias(alias: String)
  DuplicateNestedOperation(name: String)
  TypeMismatch(expected: String, found: String)
  InvalidEdge(from: String, to: String)
  InvalidLiteral(message: String)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
