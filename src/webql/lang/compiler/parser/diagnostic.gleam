import webql/lang/compiler/lexer/token
import webql/lang/compiler/source

pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(kind: token.TokenKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
