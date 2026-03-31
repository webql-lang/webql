import webql/lang/lexer/token
import webql/lang/source

pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(kind: token.TokenKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
