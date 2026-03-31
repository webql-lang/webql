import gleam/string

/// The total span of characters in a source.
pub type Span {
  Span(start: Int, end: Int)
}

/// Grabs the start of `a` and the end of `b` to cover the entire relative
/// span of characters.
pub fn cover(a: Span, b: Span) -> Span {
  Span(start: a.start, end: b.end)
}

/// Relative to a span value slices the source.
pub fn slice(source: String, span: Span) -> String {
  string.slice(
    from: source,
    at_index: span.start,
    length: span.end - span.start,
  )
}
