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
  )
}

/// A typed parameter or return declaration.
///
/// ## Examples
///
///     token: Uuid
///     out: Int
pub type Declaration {
  Declaration(name: String, typename: String)
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
  Definition(name: String, typename: option.Option(String), element: Element)
  Edge(from: Value, to: Value)
  Value(Value)
  Block(Ast)
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
  Int(Int)
  Float(Float)
  String(String)
  Port(String)
  Node(List(String))
  Vertex(List(String))
}

/// The kind of syntax error encountered while parsing.
pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(found: lexer.TokenKind, expected: Expected)
}

/// A syntax error and the value span where it occurred.
pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// What the parser expected at the point of a syntax error.
pub type Expected {
  ExpectedDeclaration
  ExpectedElement
  ExpectedValue
  ExpectedLiteral
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
    tokens -> parse_unexpected(source, tokens, ExpectedDeclaration)
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_ast(source: String, tokens: List(lexer.Token)) {
  use #(parameters, rest) <- result.try(parse_parameters(source, tokens))
  use #(returns, rest) <- result.try(parse_returns(source, rest))
  use #(elements, rest) <- result.try(parse_elements(source, rest, []))

  Ok(#(Ast(parameters:, returns:, elements:), rest))
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
    tokens, [] | [lexer.Token(kind: lexer.Comma, ..), ..tokens], [_, ..] -> {
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
      let name = source.slice(source, name.span)
      let typename = source.slice(source, typename.span)
      Ok(#(Declaration(name:, typename:), rest))
    }

    tokens ->
      parse_unexpected(source, tokens, ExpectedToken(lexer.LowerIdentifier))
  }
}

fn parse_elements(
  source: String,
  tokens: List(lexer.Token),
  elements: List(Element),
) {
  case tokens {
    // SYNTAX: `}`
    [lexer.Token(kind: lexer.RBrace, ..), ..rest] ->
      Ok(#(list.reverse(elements), rest))

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
      parse_definition(source, name, Block(ast), rest)
    }

    // SYNTAX: `value = ...`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as identifier,
      lexer.Token(kind: lexer.Equal, ..),
      ..rest
    ] -> {
      let name = source.slice(source, identifier.span)
      use #(value, rest) <- result.try(parse_value(source, rest))
      parse_definition(source, name, Value(value), rest)
    }

    // SYNTAX: `value -> target`
    tokens -> {
      use #(value, rest) <- result.try(parse_value(source, tokens))
      parse_edge(source, value, rest)
    }
  }
}

fn parse_definition(
  source: String,
  name: String,
  element: Element,
  tokens: List(lexer.Token),
) {
  case element, tokens {
    // SYNTAX: `name = from -> to`
    Value(value), [lexer.Token(kind: lexer.RArrow, ..), ..] -> {
      use #(element, rest) <- result.try(parse_edge(source, value, tokens))
      Ok(#(Definition(name:, typename: option.None, element:), rest))
    }

    element, rest ->
      Ok(#(Definition(name:, typename: option.None, element:), rest))
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
      Ok(#(Edge(from:, to:), rest))
    }

    [lexer.Token(kind: lexer.RArrow, ..), ..tokens] ->
      parse_unexpected(source, tokens, ExpectedValue)

    tokens -> parse_unexpected(source, tokens, ExpectedToken(lexer.RArrow))
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
      let span =
        source.Span(start: token.span.start + 1, end: token.span.end - 1)
      Ok(#(String(source.slice(source, span)), rest))
    }

    // SYNTAX: `.value`
    [
      lexer.Token(kind: lexer.Dot, ..),
      lexer.Token(kind: lexer.LowerIdentifier, ..) as name,
      ..rest
    ] -> {
      let name = source.slice(source, name.span)
      Ok(#(Port(name), rest))
    }

    // SYNTAX: `root.value`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as root,
      lexer.Token(kind: lexer.Dot, ..),
      lexer.Token(kind: lexer.LowerIdentifier, ..) as member,
      ..rest
    ] -> {
      let root = source.slice(source, root.span)
      let member = source.slice(source, member.span)
      Ok(#(Vertex([root, member]), rest))
    }

    // SYNTAX: `root.Node`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as root,
      lexer.Token(kind: lexer.Dot, ..),
      lexer.Token(kind: lexer.UpperIdentifier, ..) as member,
      ..rest
    ] -> {
      let root = source.slice(source, root.span)
      let member = source.slice(source, member.span)
      Ok(#(Node([root, member]), rest))
    }

    // SYNTAX: `value`
    [lexer.Token(kind: lexer.LowerIdentifier, ..) as name, ..rest] -> {
      let name = source.slice(source, name.span)
      Ok(#(Vertex([name]), rest))
    }

    // SYNTAX: `Node`
    [lexer.Token(kind: lexer.UpperIdentifier, ..) as name, ..rest] -> {
      let name = source.slice(source, name.span)
      Ok(#(Node([name]), rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedValue)
  }
}

fn parse_int(source: String, token: lexer.Token, rest: List(lexer.Token)) {
  case int.parse(source.slice(source, token.span)) {
    Ok(value) -> Ok(#(Int(value), rest))
    Error(_) -> parse_unexpected(source, [token, ..rest], ExpectedLiteral)
  }
}

fn parse_float(source: String, token: lexer.Token, rest: List(lexer.Token)) {
  case float.parse(source.slice(source, token.span)) {
    Ok(value) -> Ok(#(Float(value), rest))
    Error(_) -> parse_unexpected(source, [token, ..rest], ExpectedLiteral)
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
