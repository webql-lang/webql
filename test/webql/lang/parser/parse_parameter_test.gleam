import webql/lang/lexer
import webql/lang/lexer/token
import webql/lang/parser/ast
import webql/lang/parser/cursor
import webql/lang/parser/diagnostic
import webql/lang/parser/parse_parameter
import webql/lang/source

pub fn parse_returns_parameter_for_simple_key_value_pair_test() {
  let source = "name: String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: parameter, rest:, ..)) =
    parse_parameter.parse(source, tokens)

  assert parameter
    == ast.Parameter(
      span: source.Span(start: 0, end: 12),
      name: "name",
      typename: ast.Typename(
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

  let assert Ok(cursor.Cursor(current: parameter, rest:, ..)) =
    parse_parameter.parse(source, tokens)

  assert parameter
    == ast.Parameter(
      span: source.Span(start: 2, end: 14),
      name: "name",
      typename: ast.Typename(
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
  )) = parse_parameter.parse(source, tokens)
}

pub fn parse_skips_spaces_before_annotation_test() {
  let source = "name:   String"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: parameter, rest:, ..)) =
    parse_parameter.parse(source, tokens)

  assert parameter
    == ast.Parameter(
      span: source.Span(start: 0, end: 14),
      name: "name",
      typename: ast.Typename(
        span: source.Span(start: 8, end: 14),
        name: "String",
      ),
    )

  assert rest
    == [token.Token(kind: token.EOF, span: source.Span(start: 14, end: 14))]
}

pub fn parse_preserves_remaining_tokens_after_parameter_test() {
  let source = "name: String other"

  let assert Ok(tokens) =
    source
    |> lexer.new()
    |> lexer.lex()

  let assert Ok(cursor.Cursor(current: parameter, rest:, ..)) =
    parse_parameter.parse(source, tokens)

  assert parameter
    == ast.Parameter(
      span: source.Span(start: 0, end: 12),
      name: "name",
      typename: ast.Typename(
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

  let assert Error(error) = parse_parameter.parse(source, tokens)

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

  let assert Error(error) = parse_parameter.parse(source, tokens)

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

  let assert Error(error) = parse_parameter.parse(source, tokens)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.UnexpectedEof,
      span: source.Span(start: 6, end: 6),
    )
}
