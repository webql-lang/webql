import webql/lang/lexer/token
import webql/lang/source

/// Represents a AST relative to a span and the next available tokens.
pub type Cursor(a) {
  Cursor(current: a, span: source.Span, rest: List(token.Token))
}
