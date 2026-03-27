import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_field
import webql/lang/source/position

pub fn parse_returns_field_for_simple_key_value_pair_test() {
  let source = "name: String"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 4),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 4, end: 5)),
    token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 6, end: 12),
    ),
  ]

  let assert Ok(#(field, rest)) = parse_field.parse(source, tokens)

  assert field
    == ast.Field(name: "name", annotation: ast.NamedTypeAnnotation("String"))

  assert rest == []
}

pub fn parse_skips_leading_spaces_before_key_test() {
  let source = "  name: String"
  let tokens = [
    token.Token(kind: token.Space, span: position.Span(start: 0, end: 1)),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 2, end: 6),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 8, end: 14),
    ),
  ]

  let assert Ok(#(field, rest)) = parse_field.parse(source, tokens)

  assert field
    == ast.Field(name: "name", annotation: ast.NamedTypeAnnotation("String"))

  assert rest == []
}

pub fn parse_skips_spaces_before_separator_test() {
  let source = "name : String"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 4),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 4, end: 5)),
    token.Token(kind: token.Colon, span: position.Span(start: 5, end: 6)),
    token.Token(kind: token.Space, span: position.Span(start: 6, end: 7)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 7, end: 13),
    ),
  ]

  let assert Ok(#(field, rest)) = parse_field.parse(source, tokens)

  assert field
    == ast.Field(name: "name", annotation: ast.NamedTypeAnnotation("String"))

  assert rest == []
}

pub fn parse_skips_spaces_before_annotation_test() {
  let source = "name:   String"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 4),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 4, end: 5)),
    token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
    token.Token(kind: token.Space, span: position.Span(start: 6, end: 7)),
    token.Token(kind: token.Space, span: position.Span(start: 7, end: 8)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 8, end: 14),
    ),
  ]

  let assert Ok(#(field, rest)) = parse_field.parse(source, tokens)

  assert field
    == ast.Field(name: "name", annotation: ast.NamedTypeAnnotation("String"))

  assert rest == []
}

pub fn parse_preserves_remaining_tokens_after_field_test() {
  let source = "name: String other"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 4),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 4, end: 5)),
    token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 6, end: 12),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 12, end: 13)),
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 13, end: 18),
    ),
  ]

  let assert Ok(#(field, rest)) = parse_field.parse(source, tokens)

  assert field
    == ast.Field(name: "name", annotation: ast.NamedTypeAnnotation("String"))

  assert rest
    == [
      token.Token(kind: token.Space, span: position.Span(start: 12, end: 13)),
      token.Token(
        kind: token.LowerIdentifier,
        span: position.Span(start: 13, end: 18),
      ),
    ]
}

pub fn parse_returns_unexpected_token_when_key_is_invalid_test() {
  let source = ": String"
  let tokens = [
    token.Token(kind: token.Colon, span: position.Span(start: 0, end: 1)),
    token.Token(kind: token.Space, span: position.Span(start: 1, end: 2)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 2, end: 8),
    ),
  ]

  let assert Error(error) = parse_field.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Colon),
      span: position.Span(start: 0, end: 1),
    )
}

pub fn parse_returns_unexpected_eof_when_tokens_are_empty_test() {
  let source = ""
  let tokens = []

  let assert Error(error) = parse_field.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: position.Span(start: 0, end: 0),
    )
}

pub fn parse_returns_unexpected_token_when_separator_is_missing_test() {
  let source = "name String"
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 4),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 4, end: 5)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 5, end: 11),
    ),
  ]

  let assert Error(error) = parse_field.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.UpperIdentifier),
      span: position.Span(start: 5, end: 11),
    )
}

pub fn parse_returns_unexpected_eof_when_annotation_is_missing_test() {
  let source = "name: "
  let tokens = [
    token.Token(
      kind: token.LowerIdentifier,
      span: position.Span(start: 0, end: 4),
    ),
    token.Token(kind: token.Colon, span: position.Span(start: 4, end: 5)),
    token.Token(kind: token.Space, span: position.Span(start: 5, end: 6)),
  ]

  let assert Error(error) = parse_field.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: position.Span(start: 6, end: 6),
    )
}
