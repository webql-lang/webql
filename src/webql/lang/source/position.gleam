pub type Span {
  Span(start: Int, end: Int)
}

/// Grabs the start of `a` and the end of `b` to cover the entire relative
/// span of characters.
pub fn cover(a: Span, b: Span) -> Span {
  Span(start: a.start, end: b.end)
}
