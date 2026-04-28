import gleam/bit_array
import webql/lang/compiler/lexer/lex_comment
import webql/lang/compiler/lexer/token
import webql/lang/compiler/source

pub fn lex_comment_stops_at_newline_test() {
  let #(tok, rest) =
    lex_comment.lex(bit_array.from_string("hello\nworld"), 0, 0)

  assert tok
    == token.Token(
      kind: token.CommentSingle,
      span: source.Span(start: 0, end: 5),
    )

  let assert <<"\nworld":utf8>> = rest
}

pub fn lex_comment_stops_at_crlf_test() {
  let #(tok, rest) =
    lex_comment.lex(bit_array.from_string("hello\r\nworld"), 0, 0)

  assert tok
    == token.Token(
      kind: token.CommentSingle,
      span: source.Span(start: 0, end: 5),
    )

  let assert <<"\r\nworld":utf8>> = rest
}

pub fn lex_comment_stops_at_cr_test() {
  let #(tok, rest) =
    lex_comment.lex(bit_array.from_string("hello\rworld"), 0, 0)

  assert tok
    == token.Token(
      kind: token.CommentSingle,
      span: source.Span(start: 0, end: 5),
    )

  let assert <<"\rworld":utf8>> = rest
}

pub fn lex_comment_stops_at_eof_test() {
  let #(tok, rest) = lex_comment.lex(bit_array.from_string("hello"), 0, 0)

  assert tok
    == token.Token(
      kind: token.CommentSingle,
      span: source.Span(start: 0, end: 5),
    )

  assert rest == bit_array.from_string("")
}

pub fn lex_comment_respects_non_zero_start_and_size_test() {
  let #(tok, rest) =
    lex_comment.lex(bit_array.from_string("hello\nworld"), 10, 1)

  assert tok
    == token.Token(
      kind: token.CommentSingle,
      span: source.Span(start: 10, end: 16),
    )

  let assert <<"\nworld":utf8>> = rest
}
