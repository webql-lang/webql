import webql/source

pub fn cover_combines_spans_test() {
  assert source.cover(
      source.Span(start: 0, end: 3),
      source.Span(start: 5, end: 10),
    )
    == source.Span(start: 0, end: 10)
}

pub fn slice_returns_selected_text_test() {
  assert source.slice("hello world", source.Span(start: 6, end: 11)) == "world"
}

pub fn slice_uses_character_offsets_test() {
  assert source.slice("🌲hello", source.Span(start: 1, end: 6)) == "hello"
}
