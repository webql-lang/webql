import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/parse_annotation
import webql/lang/source/position

pub fn parse_returns_named_type_annotation_for_upper_identifier_test() {
  let source = "Int"
  let tokens = [
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 0, end: 3),
    ),
  ]

  let assert Ok(#(annotation, rest)) = parse_annotation.parse(source, tokens)

  assert annotation == ast.NamedTypeAnnotation("Int")
  assert rest == []
}

pub fn parse_preserves_remaining_tokens_after_annotation_test() {
  let source = "Int String"
  let tokens = [
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 0, end: 3),
    ),
    token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 4, end: 10),
    ),
  ]

  let assert Ok(#(annotation, rest)) = parse_annotation.parse(source, tokens)

  assert annotation == ast.NamedTypeAnnotation("Int")
  assert rest
    == [
      token.Token(kind: token.Space, span: position.Span(start: 3, end: 4)),
      token.Token(
        kind: token.UpperIdentifier,
        span: position.Span(start: 4, end: 10),
      ),
    ]
}

pub fn parse_skips_leading_space_before_annotation_test() {
  let source = " Int"
  let tokens = [
    token.Token(kind: token.Space, span: position.Span(start: 0, end: 1)),
    token.Token(
      kind: token.UpperIdentifier,
      span: position.Span(start: 1, end: 4),
    ),
  ]

  let assert Ok(#(annotation, rest)) = parse_annotation.parse(source, tokens)

  assert annotation == ast.NamedTypeAnnotation("Int")
  assert rest == []
}
