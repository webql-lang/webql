import gleam/string
import webql/lang/source/position

/// Relative to a span value slices the source.
pub fn slice(source: String, span: position.Span) -> String {
  string.slice(
    from: source,
    at_index: span.start,
    length: span.end - span.start,
  )
}
