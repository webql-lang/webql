import webql/compiler/lexer/token
import webql/compiler/source

/// Represents a AST relative to a span and the next available tokens.
pub type Cursor(a) {
  Cursor(current: a, span: source.Span, rest: List(token.Token))
}
