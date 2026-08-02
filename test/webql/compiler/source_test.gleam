import webql/compiler/source

pub fn cover_combines_start_and_end_test() {
  let a = source.Span(start: 0, end: 3)
  let b = source.Span(start: 5, end: 10)

  let result = source.cover(a, b)

  assert result == source.Span(start: 0, end: 10)
}

pub fn cover_with_adjacent_sources_test() {
  let a = source.Span(start: 0, end: 3)
  let b = source.Span(start: 3, end: 6)

  let result = source.cover(a, b)

  assert result == source.Span(start: 0, end: 6)
}

pub fn slice_returns_substring_test() {
  let source = "hello world"
  let span = source.Span(start: 0, end: 5)

  let result = source.slice(source, span)

  assert result == "hello"
}

pub fn slice_middle_of_string_test() {
  let source = "hello world"
  let span = source.Span(start: 6, end: 11)

  let result = source.slice(source, span)

  assert result == "world"
}

pub fn slice_empty_source_test() {
  let source = "hello"
  let span = source.Span(start: 2, end: 2)

  let result = source.slice(source, span)

  assert result == ""
}

pub fn slice_uses_character_offsets_test() {
  let source = "🌲hello"
  let span = source.Span(start: 1, end: 6)

  let result = source.slice(source, span)

  assert result == "hello"
}
