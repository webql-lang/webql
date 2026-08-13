import gleam/bit_array
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import webql/compiler/lexer
import webql/compiler/source

/// A WebQL block containing its interface and value-ordered body.
pub type Ast {
  Ast(
    parameters: List(Declaration),
    returns: List(Declaration),
    elements: List(Element),
    span: source.Span,
  )
}

/// A typed parameter or return declaration.
///
/// ## Examples
///
///     token: Uuid
///     out: Int
pub type Declaration {
  Declaration(name: String, typename: String, span: source.Span)
}

/// A value-ordered body element.
///
/// A definition can bind a value, edge, or nested block.
///
/// ## Examples
///
///     value = 1
///     service = .token -> Service
///     .input -> operation.input
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Element {
  Definition(
    name: String,
    typename: option.Option(String),
    element: Element,
    span: source.Span,
  )
  Edge(from: Value, to: Value, span: source.Span)
  Value(Value, span: source.Span)
  Block(Ast, span: source.Span)
}

/// A literal, port, node path, or vertex path.
///
/// ## Examples
///
///     1
///     1.23
///     "hello"
///     .token
///     Math
///     service.Add
///     value
///     operation.out
pub type Value {
  Int(Int, span: source.Span)
  Float(Float, span: source.Span)
  String(String, span: source.Span)
  Port(String, span: source.Span)
  Node(List(String), span: source.Span)
  Vertex(List(String), span: source.Span)
}

/// A syntax error and the value span where it occurred.
pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// The kind of syntax error encountered while parsing.
pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(found: lexer.TokenKind, expected: Expected)
}

/// What the parser expected at the point of a syntax error.
pub type Expected {
  ExpectedAst
  ExpectedDeclaration
  ExpectedElement
  ExpectedEdge
  ExpectedBlock
  ExpectedValue
  ExpectedLiteral
  ExpectedPort
  ExpectedToken(kind: lexer.TokenKind)
}

/// Parse a tokenized WebQL block into an abstract syntax tree.
pub fn parse(
  source: String,
  tokens: List(lexer.Token),
) -> Result(Ast, Diagnostic) {
  use #(ast, rest) <- result.try(parse_ast(source, tokens))

  case rest {
    [lexer.Token(kind: lexer.EOF, ..)] -> Ok(ast)
    tokens -> parse_unexpected(source, tokens, ExpectedToken(lexer.EOF))
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_ast(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Ast, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span: start), ..]
    | [lexer.Token(kind: lexer.RArrow, span: start), ..] -> {
      use #(parameters, rest) <- result.try(parse_parameters(source, tokens))
      use #(returns, rest) <- result.try(parse_returns(source, rest))
      use #(elements, end, rest) <- result.try(parse_elements(source, rest, []))

      let span = source.cover(start, end)
      Ok(#(Ast(parameters:, returns:, elements:, span:), rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedAst)
  }
}

fn parse_parameters(source: String, tokens: List(lexer.Token)) {
  use #(parameters, rest) <- result.try(parse_declarations(source, tokens, []))

  case rest {
    // SYNTAX: `->`
    [lexer.Token(kind: lexer.RArrow, ..), ..rest] -> Ok(#(parameters, rest))
    tokens -> parse_unexpected(source, tokens, ExpectedToken(lexer.RArrow))
  }
}

fn parse_returns(source: String, tokens: List(lexer.Token)) {
  use #(returns, rest) <- result.try(parse_declarations(source, tokens, []))

  case rest {
    // SYNTAX: `{`
    [lexer.Token(kind: lexer.LBrace, ..), ..rest] -> Ok(#(returns, rest))
    tokens -> parse_unexpected(source, tokens, ExpectedToken(lexer.LBrace))
  }
}

fn parse_declarations(
  source: String,
  tokens: List(lexer.Token),
  declarations: List(Declaration),
) {
  case tokens, declarations {
    // SYNTAX: `->` or `{`
    [lexer.Token(kind: lexer.RArrow, ..), ..], _
    | [lexer.Token(kind: lexer.LBrace, ..), ..], _
    -> Ok(#(list.reverse(declarations), tokens))

    // SYNTAX: `name: Type` or `, name: Type`
    tokens, [] | [lexer.Token(kind: lexer.Comma, ..), ..tokens], [_token, ..] -> {
      use #(declaration, rest) <- result.try(parse_declaration(source, tokens))
      parse_declarations(source, rest, [declaration, ..declarations])
    }

    tokens, _ -> parse_unexpected(source, tokens, ExpectedToken(lexer.Comma))
  }
}

fn parse_declaration(source: String, tokens: List(lexer.Token)) {
  case tokens {
    // SYNTAX: `name: Type`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as name,
      lexer.Token(kind: lexer.Colon, ..),
      lexer.Token(kind: lexer.UpperIdentifier, ..) as typename,
      ..rest
    ] -> {
      let span = source.cover(name.span, typename.span)
      let name = source.slice(source, name.span)
      let typename = source.slice(source, typename.span)
      Ok(#(Declaration(name:, typename:, span:), rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedDeclaration)
  }
}

fn parse_elements(
  source: String,
  tokens: List(lexer.Token),
  elements: List(Element),
) {
  case tokens {
    // SYNTAX: `}`
    [lexer.Token(kind: lexer.RBrace, span:), ..rest] ->
      Ok(#(list.reverse(elements), span, rest))

    [lexer.Token(kind: lexer.EOF, ..)] | [] ->
      parse_unexpected(source, tokens, ExpectedToken(lexer.RBrace))

    tokens -> {
      use #(element, rest) <- result.try(parse_element(source, tokens))
      parse_elements(source, rest, [element, ..elements])
    }
  }
}

fn parse_element(source: String, tokens: List(lexer.Token)) {
  case tokens {
    // SYNTAX: `Value = in: Int -> { ... }` or `Value = -> { ... }`
    [
      lexer.Token(kind: lexer.UpperIdentifier, ..) as identifier,
      lexer.Token(kind: lexer.Equal, ..),
      lexer.Token(kind: lexer.LowerIdentifier, ..) as first,
      lexer.Token(kind: lexer.Colon, ..) as second,
      ..rest
    ]
    | [
        lexer.Token(kind: lexer.UpperIdentifier, ..) as identifier,
        lexer.Token(kind: lexer.Equal, ..),
        lexer.Token(kind: lexer.RArrow, ..) as first,
        lexer.Token(..) as second,
        ..rest
      ] -> {
      let name = source.slice(source, identifier.span)
      use #(ast, rest) <- result.try(parse_ast(source, [first, second, ..rest]))
      let span = source.cover(identifier.span, ast.span)

      Ok(#(
        Definition(
          name:,
          typename: option.None,
          element: Block(ast, span: ast.span),
          span:,
        ),
        rest,
      ))
    }

    // SYNTAX: `Value = in: Int -> { ... }` or `Value = -> { ... }`
    [
      lexer.Token(kind: lexer.UpperIdentifier, ..),
      lexer.Token(kind: lexer.Equal, ..),
      ..tokens
    ] -> parse_unexpected(source, tokens, ExpectedBlock)

    // SYNTAX: `value = ...`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as identifier,
      lexer.Token(kind: lexer.Equal, ..),
      ..rest
    ] -> {
      use #(value, rest) <- result.try(parse_value(source, rest))

      let name = source.slice(source, identifier.span)
      use #(element, element_span, rest) <- result.try(parse_definition(
        source,
        rest,
        value,
      ))
      let span = source.cover(identifier.span, element_span)
      Ok(#(Definition(name:, typename: option.None, element:, span:), rest))
    }

    // SYNTAX: `from -> to`
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.UpperIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] -> {
      use #(value, rest) <- result.try(parse_value(source, tokens))
      use #(edge, _span, rest) <- result.try(parse_edge(source, value, rest))
      Ok(#(edge, rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedElement)
  }
}

fn parse_definition(source: String, tokens: List(lexer.Token), value: Value) {
  case tokens {
    // SYNTAX: `name = from -> to`
    [lexer.Token(kind: lexer.RArrow, ..), ..] -> {
      use #(element, span, rest) <- result.try(parse_edge(source, value, tokens))
      Ok(#(element, span, rest))
    }

    rest -> {
      Ok(#(Value(value, span: value.span), value.span, rest))
    }
  }
}

fn parse_edge(source: String, from: Value, tokens: List(lexer.Token)) {
  case tokens {
    // SYNTAX: `from -> to`
    [
      lexer.Token(kind: lexer.RArrow, ..),
      lexer.Token(kind: lexer.Dot, ..) as token,
      ..tokens
    ]
    | [
        lexer.Token(kind: lexer.RArrow, ..),
        lexer.Token(kind: lexer.LowerIdentifier, ..) as token,
        ..tokens
      ]
    | [
        lexer.Token(kind: lexer.RArrow, ..),
        lexer.Token(kind: lexer.UpperIdentifier, ..) as token,
        ..tokens
      ] -> {
      use #(to, rest) <- result.try(parse_value(source, [token, ..tokens]))
      let span = source.cover(from.span, to.span)
      Ok(#(Edge(from:, to:, span:), span, rest))
    }

    [lexer.Token(kind: lexer.RArrow, ..), ..tokens] ->
      parse_unexpected(source, tokens, ExpectedValue)

    tokens -> parse_unexpected(source, tokens, ExpectedEdge)
  }
}

fn parse_value(source: String, tokens: List(lexer.Token)) {
  case tokens {
    // SYNTAX: `1`
    [lexer.Token(kind: lexer.Int, ..) as token, ..rest] ->
      parse_int(source, token, rest)

    // SYNTAX: `1.23`
    [lexer.Token(kind: lexer.Float, ..) as token, ..rest] ->
      parse_float(source, token, rest)

    // SYNTAX: `"hello world!"`
    [lexer.Token(kind: lexer.String, ..) as token, ..rest] -> {
      let inner =
        source.Span(start: token.span.start + 1, end: token.span.end - 1)
      Ok(#(String(source.slice(source, inner), span: token.span), rest))
    }

    // SYNTAX: `.value`
    [
      lexer.Token(kind: lexer.Dot, ..) as dot,
      lexer.Token(kind: lexer.LowerIdentifier, ..) as name,
      ..rest
    ] -> {
      let span = source.cover(dot.span, name.span)
      let name = source.slice(source, name.span)
      Ok(#(Port(name, span:), rest))
    }

    [lexer.Token(kind: lexer.Dot, ..), ..tokens] ->
      parse_unexpected(source, tokens, ExpectedPort)

    // SYNTAX: `root.value`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as root,
      lexer.Token(kind: lexer.Dot, ..),
      lexer.Token(kind: lexer.LowerIdentifier, ..) as member,
      ..rest
    ] -> {
      let span = source.cover(root.span, member.span)
      let root = source.slice(source, root.span)
      let member = source.slice(source, member.span)
      Ok(#(Vertex([root, member], span:), rest))
    }

    // SYNTAX: `root.Node`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as root,
      lexer.Token(kind: lexer.Dot, ..),
      lexer.Token(kind: lexer.UpperIdentifier, ..) as member,
      ..rest
    ] -> {
      let span = source.cover(root.span, member.span)
      let root = source.slice(source, root.span)
      let member = source.slice(source, member.span)
      Ok(#(Node([root, member], span:), rest))
    }

    // SYNTAX: `value`
    [lexer.Token(kind: lexer.LowerIdentifier, ..) as token, ..rest] -> {
      let name = source.slice(source, token.span)
      Ok(#(Vertex([name], span: token.span), rest))
    }

    // SYNTAX: `Node`
    [lexer.Token(kind: lexer.UpperIdentifier, ..) as token, ..rest] -> {
      let name = source.slice(source, token.span)
      Ok(#(Node([name], span: token.span), rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedValue)
  }
}

fn parse_int(source: String, token: lexer.Token, rest: List(lexer.Token)) {
  case int.parse(source.slice(source, token.span)) {
    Ok(value) -> Ok(#(Int(value, span: token.span), rest))
    Error(_) -> parse_unexpected(source, [token, ..rest], ExpectedLiteral)
  }
}

fn parse_float(source: String, token: lexer.Token, rest: List(lexer.Token)) {
  case float.parse(source.slice(source, token.span)) {
    Ok(value) -> Ok(#(Float(value, span: token.span), rest))
    Error(_nil) -> parse_unexpected(source, [token, ..rest], ExpectedLiteral)
  }
}

fn parse_unexpected(
  source: String,
  tokens: List(lexer.Token),
  expected: Expected,
) {
  case tokens {
    [lexer.Token(kind: lexer.EOF, ..) as token, ..] ->
      Error(Diagnostic(kind: UnexpectedEof, span: token.span))

    [lexer.Token(..) as token, ..] ->
      Error(Diagnostic(
        kind: UnexpectedToken(found: token.kind, expected:),
        span: token.span,
      ))

    [] -> {
      let end =
        source
        |> bit_array.from_string()
        |> bit_array.byte_size()

      Error(Diagnostic(
        kind: UnexpectedEof,
        span: source.Span(start: end, end: end),
      ))
    }
  }
}
