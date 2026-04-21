import webql/compiler/lexer/token
import webql/compiler/source

pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(kind: token.TokenKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
