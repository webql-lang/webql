import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/parse_annotation
import webql/lang/source

pub fn parse_returns_named_type_annotation_for_upper_identifier_test() {
  let source = "Int"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: annotation, span: span, tokens: rest)) =
    parse_annotation.parse(source, tokens)

  assert annotation
    == ast.NamedTypeAnnotation(span: source.Span(start: 0, end: 3), name: "Int")

  assert span == source.Span(start: 0, end: 3)

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 3, end: 3))]
}

pub fn parse_preserves_remaining_tokens_after_annotation_test() {
  let source = "Int String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: annotation, span: span, tokens: rest)) =
    parse_annotation.parse(source, tokens)

  assert annotation
    == ast.NamedTypeAnnotation(span: source.Span(start: 0, end: 3), name: "Int")

  assert span == source.Span(start: 0, end: 3)

  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 3, end: 4)),
      token.Token(
        kind: token.UpperIdentifier,
        span: source.Span(start: 4, end: 10),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 10, end: 10)),
    ]
}

pub fn parse_skips_leading_space_before_annotation_test() {
  let source = " Int"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: annotation, span: span, tokens: rest)) =
    parse_annotation.parse(source, tokens)

  assert annotation
    == ast.NamedTypeAnnotation(span: source.Span(start: 1, end: 4), name: "Int")

  assert span == source.Span(start: 1, end: 4)

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 4, end: 4))]
}
