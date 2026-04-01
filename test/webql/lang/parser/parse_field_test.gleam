import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_field
import webql/lang/source

pub fn parse_returns_field_for_simple_key_value_pair_test() {
  let source = "name: String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: field, tokens: rest, ..)) =
    parse_field.parse(source, tokens)

  assert field
    == ast.Field(
      span: source.Span(start: 0, end: 12),
      name: "name",
      annotation: ast.NamedTypeAnnotation(
        span: source.Span(start: 6, end: 12),
        name: "String",
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 12, end: 12))]
}

pub fn parse_skips_leading_spaces_before_key_test() {
  let source = "  name: String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: field, tokens: rest, ..)) =
    parse_field.parse(source, tokens)

  assert field
    == ast.Field(
      span: source.Span(start: 2, end: 14),
      name: "name",
      annotation: ast.NamedTypeAnnotation(
        span: source.Span(start: 8, end: 14),
        name: "String",
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 14, end: 14))]
}

pub fn parse_skips_spaces_before_separator_test() {
  let source = "name : String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(diagnostic.Diagnostic(
    diagnostic.UnexpectedToken(token.Space),
    source.Span(4, 5),
  )) = parse_field.parse(source, tokens)
}

pub fn parse_skips_spaces_before_annotation_test() {
  let source = "name:   String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: field, tokens: rest, ..)) =
    parse_field.parse(source, tokens)

  assert field
    == ast.Field(
      span: source.Span(start: 0, end: 14),
      name: "name",
      annotation: ast.NamedTypeAnnotation(
        span: source.Span(start: 8, end: 14),
        name: "String",
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 14, end: 14))]
}

pub fn parse_preserves_remaining_tokens_after_field_test() {
  let source = "name: String other"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(ast.Parsed(node: field, tokens: rest, ..)) =
    parse_field.parse(source, tokens)

  assert field
    == ast.Field(
      span: source.Span(start: 0, end: 12),
      name: "name",
      annotation: ast.NamedTypeAnnotation(
        span: source.Span(start: 6, end: 12),
        name: "String",
      ),
    )

  assert rest
    == [
      token.Token(kind: token.Space, span: source.Span(start: 12, end: 13)),
      token.Token(
        kind: token.LowerIdentifier,
        span: source.Span(start: 13, end: 18),
      ),
      token.Token(kind: token.EOF, span: source.Span(start: 18, end: 18)),
    ]
}

pub fn parse_returns_unexpected_eof_when_tokens_are_empty_test() {
  let source = ""

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_field.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 0, end: 0),
    )
}

pub fn parse_returns_unexpected_token_when_separator_is_missing_test() {
  let source = "name String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_field.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedToken(token.Space),
      span: source.Span(start: 4, end: 5),
    )
}

pub fn parse_returns_unexpected_eof_when_annotation_is_missing_test() {
  let source = "name: "

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Error(error) = parse_field.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 6, end: 6),
    )
}
