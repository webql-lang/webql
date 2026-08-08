import gleam/bit_array
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import webql/compiler/lexer
import webql/compiler/source

/// A block containing interface declarations and body statements.
///
/// ## Examples
///
///     token: Uuid, in: Int -> out: Int {
///       math = .token -> Math
///       add = math.Add
///       1 -> add.l
///       add.out -> .out
///     }
pub type Ast {
  Ast(ports: List(Port), elements: List(Element), span: source.Span)
}

/// A named parameter or return declared by a block.
///
/// ## Examples
///
///     token: Uuid
///     in: Int
///     -> out: Int
pub type Port {
  Input(name: String, typename: Typename, span: source.Span)
  Output(name: String, typename: Typename, span: source.Span)
}

/// A body statement, optionally assigned to a name.
///
/// ## Examples
///
///     math = .token -> Math
///     add = math.Add
///     1 -> add.l
pub type Element {
  Labeled(name: String, value: Value, span: source.Span)
  Unlabeled(Value, span: source.Span)
}

/// A value stored by a labeled element or used as an unlabeled edge.
///
/// ## Examples
///
///     math.Add
///     1 -> add.l
///     in: Int -> out: Int { .in -> .out }
pub type Value {
  Member(Path, span: source.Span)
  Block(Ast, span: source.Span)
  Edge(from: Vertex, to: Vertex, span: source.Span)
  Literal(Literal, span: source.Span)
}

/// One end of an edge, represented by a reference or a literal source.
///
/// ## Examples
///
///     .token
///     add.l
///     Math
///     1
pub type Vertex {
  Reference(Path, span: source.Span)
  Source(Literal, span: source.Span)
}

/// The parsed payload of a primitive literal.
///
/// `lexeme` preserves the literal's original source representation.
///
/// ## Examples
///
///     123
///     1.23
///     "hello"
pub type Literal {
  Int(lexeme: String, value: Int, span: source.Span)
  Float(lexeme: String, value: Float, span: source.Span)
  String(lexeme: String, value: String, span: source.Span)
}

/// A type name referenced by an interface declaration.
///
/// ## Examples
///
///     Int
///     Float
///     String
///     Uuid
pub type Typename {
  Typename(String, span: source.Span)
}

/// A reference to an interface port or a local named element.
///
/// ## Examples
///
///     Port("token")
///     Neighbor(["add", "l"])
///     Neighbor(["math", "Add"])
///     Port("out")
pub type Path {
  Port(String)
  Neighbor(List(String))
}

/// The kind of syntax error encountered while parsing.
///
/// ## Examples
///
///     UnexpectedEof
///     UnexpectedToken(found: found, expected: ExpectedElement)
pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(found: lexer.TokenKind, expected: Expected)
}

/// A syntax error and the source span where it occurred.
///
/// ## Examples
///
///     Diagnostic(kind: UnexpectedEof, span: span)
pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// What the parser expected at the point of a syntax error.
///
/// ## Examples
///
///     ExpectedElement
///     ExpectedToken(kind)
pub type Expected {
  ExpectedElement
  ExpectedPath
  ExpectedVertex
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
    tokens -> parse_unexpected(source, tokens, ExpectedElement)
  }
}

// PRIVATE FUNCTIONS
// =================
fn parse_ast(source: String, tokens: List(lexer.Token)) {
  use #(ports, start, rest) <- result.try(parse_ports(source, tokens))
  use #(elements, end, rest) <- result.try(parse_elements(source, rest, []))

  let span = source.Span(start:, end:)

  Ok(#(Ast(ports:, elements:, span:), rest))
}

fn parse_elements(
  source: String,
  tokens: List(lexer.Token),
  elements: List(Element),
) {
  case tokens {
    [lexer.Token(kind: lexer.RBrace, ..) as brace, ..rest] ->
      Ok(#(list.reverse(elements), brace.span.end, rest))

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
    // SYNTAX: `value = ...` or `Value = ...`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..),
      lexer.Token(kind: lexer.Equal, ..),
      ..
    ]
    | [
        lexer.Token(kind: lexer.UpperIdentifier, ..),
        lexer.Token(kind: lexer.Equal, ..),
        ..
      ] -> parse_labeled_element(source, tokens)

    // SYNTAX: `from -> to`
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.UpperIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] ->
      parse_unlabeled_element(source, tokens)

    tokens -> parse_unexpected(source, tokens, ExpectedElement)
  }
}

fn parse_labeled_element(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as identifier,
      lexer.Token(kind: lexer.Equal, ..),
      ..rest
    ]
    | [
        lexer.Token(kind: lexer.UpperIdentifier, ..) as identifier,
        lexer.Token(kind: lexer.Equal, ..),
        ..rest
      ] -> {
      let name = source.slice(source, identifier.span)
      use #(value, end, rest) <- result.try(parse_value(source, rest))
      let span = source.Span(start: identifier.span.start, end: end.end)

      Ok(#(Labeled(name:, value:, span:), rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedElement)
  }
}

fn parse_unlabeled_element(source: String, tokens: List(lexer.Token)) {
  use #(from, rest) <- result.try(parse_vertex(source, tokens))
  use #(value, span, rest) <- result.try(parse_edge(source, from, rest))
  Ok(#(Unlabeled(value, span:), rest))
}

fn parse_value(source: String, tokens: List(lexer.Token)) {
  let vertex = fn(tokens) {
    use #(from, rest) <- result.try(parse_vertex(source, tokens))

    case rest, from {
      [lexer.Token(kind: lexer.RArrow, ..), ..], from ->
        parse_edge(source, from, rest)

      rest, Reference(path, span:) -> Ok(#(Member(path, span:), span, rest))

      rest, Source(literal, span:) -> Ok(#(Literal(literal, span:), span, rest))
    }
  }

  case tokens {
    // SYNTAX: `in: Int -> out: Int { ... }` or `-> { ... }`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..),
      lexer.Token(kind: lexer.Colon, ..),
      ..
    ]
    | [lexer.Token(kind: lexer.RArrow, ..), ..] -> {
      use #(ast, rest) <- result.try(parse_ast(source, tokens))
      Ok(#(Block(ast, span: ast.span), ast.span, rest))
    }

    tokens -> vertex(tokens)
  }
}

fn parse_edge(source: String, from: Vertex, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.RArrow, ..), ..rest] -> {
      use #(to, rest) <- result.try(parse_reference(source, rest))
      let span = source.Span(start: from.span.start, end: to.span.end)

      Ok(#(Edge(from:, to:, span:), span, rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedToken(lexer.RArrow))
  }
}

fn parse_vertex(source: String, tokens: List(lexer.Token)) {
  case tokens {
    // SYNTAX: `1` or `1.23` or `"hello world!"`
    [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] -> {
      use #(literal, rest) <- result.try(parse_literal(source, tokens))
      Ok(#(Source(literal, span: literal.span), rest))
    }

    // SYNTAX: `reference` or `root.reference` or `.port`
    [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.LowerIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.UpperIdentifier, ..), ..] ->
      parse_reference(source, tokens)

    tokens -> parse_unexpected(source, tokens, ExpectedVertex)
  }
}

fn parse_reference(source: String, tokens: List(lexer.Token)) {
  use #(path, span, rest) <- result.try(parse_path(source, tokens))
  Ok(#(Reference(path, span:), rest))
}

fn parse_literal(source: String, tokens: List(lexer.Token)) {
  let parse_int = fn(lexeme: String, span: source.Span) {
    case int.parse(lexeme) {
      Ok(value) -> Ok(Int(lexeme:, value:, span:))
      Error(_error) -> parse_unexpected(source, tokens, ExpectedLiteral)
    }
  }

  let parse_float = fn(lexeme: String, span: source.Span) {
    case float.parse(lexeme) {
      Ok(value) -> Ok(Float(lexeme:, value:, span:))
      Error(_error) -> parse_unexpected(source, tokens, ExpectedLiteral)
    }
  }

  case tokens {
    // SYNTAX: `1`
    [lexer.Token(kind: lexer.Int, ..) as token, ..rest] -> {
      let lexeme = source.slice(source, token.span)
      use literal <- result.try(parse_int(lexeme, token.span))
      Ok(#(literal, rest))
    }

    // SYNTAX: `1.23`
    [lexer.Token(kind: lexer.Float, ..) as token, ..rest] -> {
      let lexeme = source.slice(source, token.span)
      use literal <- result.try(parse_float(lexeme, token.span))
      Ok(#(literal, rest))
    }

    // SYNTAX: `"hello world!"`
    [lexer.Token(kind: lexer.String, ..) as token, ..rest] -> {
      let lexeme = source.slice(source, token.span)
      let inner =
        source.Span(start: token.span.start + 1, end: token.span.end - 1)
      let value = source.slice(source, inner)
      Ok(#(String(lexeme:, value:, span: token.span), rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedLiteral)
  }
}

fn parse_path(source: String, tokens: List(lexer.Token)) {
  case tokens {
    // SYNTAX: `.value`
    [
      lexer.Token(kind: lexer.Dot, ..) as dot,
      lexer.Token(kind: lexer.LowerIdentifier, ..) as identifier,
      ..rest
    ] -> {
      let name = source.slice(source, identifier.span)
      let span = source.Span(start: dot.span.start, end: identifier.span.end)
      Ok(#(Port(name), span, rest))
    }

    // SYNTAX: `root.value` or `root.Node`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as root,
      lexer.Token(kind: lexer.Dot, ..),
      lexer.Token(kind: lexer.LowerIdentifier, ..) as member,
      ..rest
    ]
    | [
        lexer.Token(kind: lexer.LowerIdentifier, ..) as root,
        lexer.Token(kind: lexer.Dot, ..),
        lexer.Token(kind: lexer.UpperIdentifier, ..) as member,
        ..rest
      ] -> {
      let span = source.Span(start: root.span.start, end: member.span.end)
      let root = source.slice(source, root.span)
      let member = source.slice(source, member.span)
      Ok(#(Neighbor([root, member]), span, rest))
    }

    // SYNTAX: `value` or `Node`
    [lexer.Token(kind: lexer.LowerIdentifier, ..) as identifier, ..rest]
    | [lexer.Token(kind: lexer.UpperIdentifier, ..) as identifier, ..rest] -> {
      let name = source.slice(source, identifier.span)
      Ok(#(Neighbor([name]), identifier.span, rest))
    }

    tokens -> parse_unexpected(source, tokens, ExpectedPath)
  }
}

fn parse_ports(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(span:, ..), ..] -> {
      use #(inputs, rest) <- result.try(parse_port_inputs(source, tokens, []))
      use #(outputs, rest) <- result.try(parse_port_outputs(source, rest, []))

      let ports = list.append(inputs, outputs)
      Ok(#(ports, span.start, rest))
    }

    [] -> parse_unexpected(source, tokens, ExpectedToken(lexer.LowerIdentifier))
  }
}

fn parse_port_inputs(
  source: String,
  tokens: List(lexer.Token),
  inputs: List(Port),
) {
  case tokens, inputs {
    // SYNTAX: `->`
    [lexer.Token(kind: lexer.RArrow, ..), ..rest], _ ->
      Ok(#(list.reverse(inputs), rest))

    // SYNTAX: `name: Type`
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..], [] -> {
      use #(#(name, typename, span), rest) <- result.try(parse_port(
        source,
        tokens,
      ))
      let inputs = [Input(name:, typename:, span:), ..inputs]
      parse_port_inputs(source, rest, inputs)
    }

    // SYNTAX: `, name: Type`
    [lexer.Token(kind: lexer.Comma, ..), ..rest], [_, ..] -> {
      use #(#(name, typename, span), rest) <- result.try(parse_port(
        source,
        rest,
      ))
      let inputs = [Input(name:, typename:, span:), ..inputs]
      parse_port_inputs(source, rest, inputs)
    }

    tokens, [] ->
      parse_unexpected(source, tokens, ExpectedToken(lexer.LowerIdentifier))

    tokens, _ -> parse_unexpected(source, tokens, ExpectedToken(lexer.Comma))
  }
}

fn parse_port_outputs(
  source: String,
  tokens: List(lexer.Token),
  outputs: List(Port),
) {
  case tokens, outputs {
    // SYNTAX: `{`
    [lexer.Token(kind: lexer.LBrace, ..), ..rest], _ ->
      Ok(#(list.reverse(outputs), rest))

    // SYNTAX: `name: Type`
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..], [] -> {
      use #(#(name, typename, span), rest) <- result.try(parse_port(
        source,
        tokens,
      ))
      let outputs = [Output(name:, typename:, span:), ..outputs]
      parse_port_outputs(source, rest, outputs)
    }

    // SYNTAX: `, name: Type`
    [lexer.Token(kind: lexer.Comma, ..), ..rest], [_, ..] -> {
      use #(#(name, typename, span), rest) <- result.try(parse_port(
        source,
        rest,
      ))
      let outputs = [Output(name:, typename:, span:), ..outputs]
      parse_port_outputs(source, rest, outputs)
    }

    tokens, [] ->
      parse_unexpected(source, tokens, ExpectedToken(lexer.LowerIdentifier))

    tokens, _ -> parse_unexpected(source, tokens, ExpectedToken(lexer.Comma))
  }
}

fn parse_port(source: String, tokens: List(lexer.Token)) {
  case tokens {
    // SYNTAX: `name: Type`
    [
      lexer.Token(kind: lexer.LowerIdentifier, ..) as lower,
      lexer.Token(kind: lexer.Colon, ..),
      lexer.Token(kind: lexer.UpperIdentifier, ..) as upper,
      ..rest
    ] -> {
      let span = source.Span(start: lower.span.start, end: upper.span.end)

      let name = source.slice(source, lower.span)
      let typename =
        Typename(source.slice(source, upper.span), span: upper.span)

      Ok(#(#(name, typename, span), rest))
    }

    tokens ->
      parse_unexpected(source, tokens, ExpectedToken(lexer.LowerIdentifier))
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

      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: end, end:)))
    }
  }
}
