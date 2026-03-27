import webql/lang/lexer/token
import webql/lang/source/position

pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(kind: token.TokenKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: position.Span)
}
