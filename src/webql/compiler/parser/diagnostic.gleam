import webql/compiler/lexer
import webql/compiler/source

pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(kind: lexer.TokenKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
