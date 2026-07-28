import gleam/bit_array
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import webql/compiler/lexer
import webql/compiler/source

/// The root container for a single top-level graph.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Document {
  Document(graph: Graph, span: source.Span)
}

/// An executable graph with declared interfaces, nested supernodes, local
/// nodes, and edges.
///
/// ## Examples
///
///     in: Int -> out: Int { m = Math 1 -> m.l m.out -> .out }
pub type Graph {
  Graph(
    parameters: List(Parameter),
    returns: List(Return),
    nodes: List(Node),
    edges: List(Edge),
    span: source.Span,
  )
}

/// A declared incoming interface on a graph.
///
/// ## Examples
///
///     in: Int
pub type Parameter {
  Parameter(name: String, port: Port, span: source.Span)
}

/// A declared outgoing interface on a graph.
///
/// ## Examples
///
///     out: Int
pub type Return {
  Return(name: String, port: Port, span: source.Span)
}

/// A port annotation describing a value.
///
/// ## Examples
///
///     Int
pub type Port {
  Port(name: String, span: source.Span)
}

/// A named nested graph defined inside another graph.
///
/// ## Examples
///
///     m = Math
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Node {
  Supernode(name: String, graph: Graph, span: source.Span)
  Node(name: String, node: String, span: source.Span)
}

/// A directed connection from a producing value to a receiving location.
///
/// ## Examples
///
///     m.out -> .out
pub type Edge {
  Edge(source: Source, target: Target, span: source.Span)
}

/// A location that can receive data from an edge.
///
/// ## Examples
///
///     .in
///     m.l
pub type Target {
  Input(path: List(String), span: source.Span)
}

/// A value that can produce data into an edge.
///
/// ## Examples
///
///     .out
///     m.out
///     1
pub type Source {
  Output(path: List(String), span: source.Span)
  Literal(value: Value, span: source.Span)
}

/// A literal value embedded in the graph.
///
/// ## Examples
///
///     123
///     1.23
///     "hello"
pub type Value {
  Int(name: String, value: Int, span: source.Span)
  Float(name: String, value: Float, span: source.Span)
  String(name: String, value: String, span: source.Span)
}

pub type DiagnosticKind {
  UnexpectedEof
  UnexpectedToken(kind: lexer.TokenKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// Parses tokens into an AST.
pub fn parse(
  source: String,
  tokens: List(lexer.Token),
) -> Result(Document, Diagnostic) {
  use #(document, _span, rest) <- result.try(parse_document(source, tokens))
  parse_eof(source, rest, document)
}

fn parse_document(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Document, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.RArrow, ..), ..] -> {
      use #(graph, span, rest) <- result.try(parse_graph(source, tokens))

      Ok(#(Document(graph:, span:), span, rest))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_document(source, rest)
    }
  }
}

fn parse_eof(
  source: String,
  tokens: List(lexer.Token),
  document: Document,
) -> Result(Document, Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.EOF, ..)] -> Ok(document)

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_eof(source, rest, document)
    }
  }
}

fn parse_graph(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Graph, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..]
    | [lexer.Token(kind: lexer.Dot, span:), ..]
    | [lexer.Token(kind: lexer.RArrow, span:), ..] ->
      parse_graph_from(source, tokens, span.start)

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_graph(source, rest)
    }
  }
}

fn parse_graph_from(source: String, tokens: List(lexer.Token), start: Int) {
  use #(parameters, _span, rest) <- result.try(
    parse_parameters(source, tokens, []),
  )

  use #(returns, _span, rest) <- result.try(parse_returns(source, rest, []))

  use #(#(nodes, edges), span, rest) <- result.try(
    parse_body(source, rest, [], []),
  )

  let span = source.Span(start: start, end: span.end)

  Ok(#(
    Graph(
      parameters: list.reverse(parameters),
      returns: list.reverse(returns),
      nodes: list.reverse(nodes),
      edges: list.reverse(edges),
      span:,
    ),
    span,
    rest,
  ))
}

fn parse_parameters(
  source: String,
  tokens: List(lexer.Token),
  parameters: List(Parameter),
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..] -> {
      use #(parameter, _span, rest) <- result.try(parse_parameter(
        source,
        tokens,
      ))

      parse_parameters(source, rest, [parameter, ..parameters])
    }

    [lexer.Token(kind: lexer.Comma, ..), ..rest] ->
      parse_parameters(source, rest, parameters)

    [lexer.Token(kind: lexer.RArrow, span:), ..rest] ->
      Ok(#(parameters, span, rest))

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_parameters(source, rest, parameters)
    }
  }
}

fn parse_returns(
  source: String,
  tokens: List(lexer.Token),
  returns: List(Return),
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..] -> {
      use #(return, _span, rest) <- result.try(parse_return(source, tokens))

      parse_returns(source, rest, [return, ..returns])
    }

    [lexer.Token(kind: lexer.Comma, ..), ..rest] ->
      parse_returns(source, rest, returns)

    [lexer.Token(kind: lexer.LBrace, span:), ..] -> Ok(#(returns, span, tokens))

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_returns(source, rest, returns)
    }
  }
}

fn parse_body(
  source: String,
  tokens: List(lexer.Token),
  nodes: List(Node),
  edges: List(Edge),
) -> Result(
  #(#(List(Node), List(Edge)), source.Span, List(lexer.Token)),
  Diagnostic,
) {
  use tokens <- result.try(parse_left_brace(source, tokens))
  parse_block_body(source, tokens, nodes, edges)
}

fn parse_left_brace(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.LBrace, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_left_brace(source, rest)
    }
  }
}

fn parse_block_body(
  source: String,
  tokens: List(lexer.Token),
  nodes: List(Node),
  edges: List(Edge),
) {
  case tokens {
    [lexer.Token(kind: lexer.RBrace, span:), ..rest] ->
      Ok(#(#(nodes, edges), span, rest))

    [lexer.Token(kind: lexer.UpperIdentifier, ..), ..] -> {
      use #(node, _span, rest) <- result.try(parse_supernode(source, tokens))

      parse_block_body(source, rest, [node, ..nodes], edges)
    }

    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..] ->
      parse_lower_block_body(source, tokens, nodes, edges)

    [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] -> {
      use #(edge, _span, rest) <- result.try(parse_edge(source, tokens))

      parse_block_body(source, rest, nodes, [edge, ..edges])
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_block_body(source, rest, nodes, edges)
    }
  }
}

fn parse_lower_block_body(
  source: String,
  tokens: List(lexer.Token),
  nodes: List(Node),
  edges: List(Edge),
) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..rest] -> {
      let rest =
        list.drop_while(rest, fn(token) {
          case token {
            lexer.Token(kind: lexer.Whitespace, ..)
            | lexer.Token(kind: lexer.Comment, ..) -> True
            _ -> False
          }
        })

      case rest {
        [lexer.Token(kind: lexer.Equal, ..), ..] -> {
          use #(node, _span, rest) <- result.try(parse_node(source, tokens))

          parse_block_body(source, rest, [node, ..nodes], edges)
        }

        [lexer.Token(kind: lexer.Dot, ..), ..] -> {
          use #(edge, _span, rest) <- result.try(parse_edge(source, tokens))

          parse_block_body(source, rest, nodes, [edge, ..edges])
        }

        [lexer.Token(kind: lexer.EOF, span:), ..] ->
          Error(Diagnostic(kind: UnexpectedEof, span:))

        [lexer.Token(kind:, span:), ..] ->
          Error(Diagnostic(kind: UnexpectedToken(kind), span:))

        [] -> {
          let end = bit_array.byte_size(bit_array.from_string(source))
          Error(Diagnostic(
            kind: UnexpectedEof,
            span: source.Span(start: end, end:),
          ))
        }
      }
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_block_body(source, rest, nodes, edges)
    }
  }
}

fn parse_parameter(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Parameter, source.Span, List(lexer.Token)), Diagnostic) {
  use key <- result.try(parse_key(source, tokens))
  let #(name, key_span, rest) = key
  use rest <- result.try(parse_separator(rest))
  use #(port, port_span, rest) <- result.try(parse_port(source, rest))

  let span = source.cover(key_span, port_span)

  Ok(#(Parameter(span:, name:, port:), span, rest))
}

fn parse_return(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Return, source.Span, List(lexer.Token)), Diagnostic) {
  use key <- result.try(parse_key(source, tokens))
  let #(name, key_span, rest) = key
  use rest <- result.try(parse_separator(rest))
  use #(port, port_span, rest) <- result.try(parse_port(source, rest))

  let span = source.cover(key_span, port_span)

  Ok(#(Return(span:, name:, port:), span, rest))
}

fn parse_key(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] ->
      Ok(#(source.slice(source, span), span, rest))

    _tokens -> {
      use tokens <- result.try(parse_nonstarter(source, tokens))
      parse_key(source, tokens)
    }
  }
}

fn parse_separator(tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.Colon, ..), ..rest] -> Ok(rest)

    [lexer.Token(kind:, span:), ..] ->
      Error(Diagnostic(kind: UnexpectedToken(kind:), span:))

    [] ->
      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: 0, end: 0)))
  }
}

fn parse_port(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Port, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.UpperIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      Ok(#(Port(span:, name:), span, rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter(source, tokens))
      parse_port(source, tokens)
    }
  }
}

fn parse_node(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Node, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let name_span = span

      use rest <- result.try(parse_equal(source, rest))
      use #(node, node_span, rest) <- result.try(parse_node_name(source, rest))

      let span = source.cover(name_span, node_span)

      Ok(#(Node(name:, node:, span:), span, rest))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_node(source, rest)
    }
  }
}

fn parse_node_name(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.UpperIdentifier, span:), ..rest] ->
      Ok(#(source.slice(source, span), span, rest))

    _tokens -> {
      use tokens <- result.try(parse_nonstarter(source, tokens))
      parse_node_name(source, tokens)
    }
  }
}

fn parse_supernode(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Node, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.UpperIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let name_span = span

      use rest <- result.try(parse_equal(source, rest))
      use #(graph, graph_span, rest) <- result.try(parse_graph(source, rest))

      let span = source.Span(start: name_span.start, end: graph_span.end)

      Ok(#(Supernode(name:, graph:, span:), span, rest))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_supernode(source, rest)
    }
  }
}

fn parse_equal(source: String, tokens: List(lexer.Token)) {
  case tokens {
    [lexer.Token(kind: lexer.Equal, ..), ..rest] -> Ok(rest)

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_equal(source, rest)
    }
  }
}

fn parse_edge(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Edge, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, ..), ..]
    | [lexer.Token(kind: lexer.Dot, ..), ..]
    | [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] -> {
      use edge_source <- result.try(parse_source(source, tokens))
      parse_arrow(source, edge_source)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_edge(source, rest)
    }
  }
}

fn parse_arrow(
  source: String,
  edge_source: #(Source, source.Span, List(lexer.Token)),
) {
  let #(edge_source, source_span, rest) = edge_source

  case rest {
    [lexer.Token(kind: lexer.RArrow, ..), ..rest] -> {
      use #(target, target_span, rest) <- result.try(parse_target(source, rest))
      let span = source.cover(source_span, target_span)

      Ok(#(Edge(span:, source: edge_source, target:), span, rest))
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, rest))
      parse_arrow(source, #(edge_source, source_span, rest))
    }
  }
}

fn parse_source(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Source, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let alias = #(source.slice(source, span), span, rest)
      parse_node_source(source, alias)
    }

    [lexer.Token(kind: lexer.Dot, span:), ..rest] -> {
      let dot = #(Nil, span, rest)
      parse_graph_output(source, dot)
    }

    [lexer.Token(kind: lexer.Int, ..), ..]
    | [lexer.Token(kind: lexer.Float, ..), ..]
    | [lexer.Token(kind: lexer.String, ..), ..] -> parse_literal(source, tokens)

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_source(source, rest)
    }
  }
}

fn parse_node_source(
  source: String,
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(name, span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.Dot, ..), ..rest] ->
      parse_node_output(source, #(name, span, rest))

    [lexer.Token(kind:, span:), ..] ->
      Error(Diagnostic(kind: UnexpectedToken(kind:), span:))

    [] -> {
      let end = bit_array.byte_size(bit_array.from_string(source))
      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: end, end:)))
    }
  }
}

fn parse_node_output(
  source: String,
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(alias, alias_span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias_span, span)

      Ok(#(Output(path: [alias, name], span:), span, rest))
    }

    [lexer.Token(kind:, span:), ..] ->
      Error(Diagnostic(kind: UnexpectedToken(kind:), span:))

    [] -> {
      let end = bit_array.byte_size(bit_array.from_string(source))
      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: end, end:)))
    }
  }
}

fn parse_graph_output(
  source: String,
  dot: #(Nil, source.Span, List(lexer.Token)),
) {
  let #(_dot, dot_span, rest) = dot

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot_span, span)

      Ok(#(Output(path: [name], span:), span, rest))
    }

    [lexer.Token(kind:, span:), ..] ->
      Error(Diagnostic(kind: UnexpectedToken(kind:), span:))

    [] -> {
      let end = bit_array.byte_size(bit_array.from_string(source))
      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: end, end:)))
    }
  }
}

fn parse_literal(source: String, tokens: List(lexer.Token)) {
  use #(value, span, rest) <- result.try(parse_value(source, tokens))

  Ok(#(Literal(value:, span:), span, rest))
}

fn parse_target(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Target, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = #(source.slice(source, span), span, rest)

      parse_node_target(source, name)
    }

    [lexer.Token(kind: lexer.Dot, span:), ..rest] -> {
      let dot = #(Nil, span, rest)
      parse_graph_input(source, dot)
    }

    _tokens -> {
      use rest <- result.try(parse_nonstarter(source, tokens))
      parse_target(source, rest)
    }
  }
}

fn parse_node_target(
  source: String,
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(name, span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.Dot, ..), ..rest] ->
      parse_node_input(source, #(name, span, rest))

    [lexer.Token(kind:, span:), ..] ->
      Error(Diagnostic(kind: UnexpectedToken(kind:), span:))

    [] -> {
      let end = bit_array.byte_size(bit_array.from_string(source))
      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: end, end:)))
    }
  }
}

fn parse_node_input(
  source: String,
  alias: #(String, source.Span, List(lexer.Token)),
) {
  let #(alias, alias_span, rest) = alias

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(alias_span, span)

      Ok(#(Input(path: [alias, name], span:), span, rest))
    }

    [lexer.Token(kind:, span:), ..] ->
      Error(Diagnostic(kind: UnexpectedToken(kind:), span:))

    [] -> {
      let end = bit_array.byte_size(bit_array.from_string(source))
      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: end, end:)))
    }
  }
}

fn parse_graph_input(
  source: String,
  dot: #(Nil, source.Span, List(lexer.Token)),
) {
  let #(_dot, dot_span, rest) = dot

  case rest {
    [lexer.Token(kind: lexer.LowerIdentifier, span:), ..rest] -> {
      let name = source.slice(source, span)
      let span = source.cover(dot_span, span)

      Ok(#(Input(path: [name], span:), span, rest))
    }

    [lexer.Token(kind:, span:), ..] ->
      Error(Diagnostic(kind: UnexpectedToken(kind:), span:))

    [] -> {
      let end = bit_array.byte_size(bit_array.from_string(source))
      Error(Diagnostic(kind: UnexpectedEof, span: source.Span(start: end, end:)))
    }
  }
}

fn parse_value(
  source: String,
  tokens: List(lexer.Token),
) -> Result(#(Value, source.Span, List(lexer.Token)), Diagnostic) {
  case tokens {
    [lexer.Token(kind: lexer.Int, span:), ..rest] -> {
      use value <- result.try(parse_int(source, span))
      Ok(#(value, span, rest))
    }

    [lexer.Token(kind: lexer.Float, span:), ..rest] -> {
      use value <- result.try(parse_float(source, span))
      Ok(#(value, span, rest))
    }

    [lexer.Token(kind: lexer.String, span:), ..rest] -> {
      let value = parse_string(source, span)

      Ok(#(String(name: "String", value:, span:), span, rest))
    }

    _tokens -> {
      use tokens <- result.try(parse_nonstarter(source, tokens))
      parse_value(source, tokens)
    }
  }
}

fn parse_string(source: String, span: source.Span) {
  string.slice(
    from: source,
    at_index: span.start + 1,
    length: span.end - span.start - 2,
  )
}

fn parse_int(source: String, span: source.Span) {
  let literal = source.slice(source, span)

  case int.parse(literal) {
    Ok(value) -> Ok(Int(name: "Int", value:, span:))

    Error(_error) -> Error(Diagnostic(kind: UnexpectedToken(lexer.Int), span:))
  }
}

fn parse_float(source: String, span: source.Span) {
  let literal = source.slice(source, span)

  case float.parse(literal) {
    Ok(value) -> Ok(Float(name: "Float", value:, span:))

    Error(_error) ->
      Error(Diagnostic(kind: UnexpectedToken(lexer.Float), span:))
  }
}

/// Skips whitespace and comments when a grammar production cannot start.
///
/// If the next token is still invalid for the production, returns an
/// unexpected-token or unexpected-EOF diagnostic.
fn parse_nonstarter(
  source source: String,
  tokens tokens: List(lexer.Token),
) -> Result(List(lexer.Token), Diagnostic) {
  let bytes = bit_array.from_string(source)
  let byte_length = bit_array.byte_size(bytes)

  case tokens {
    [lexer.Token(kind: lexer.Whitespace, ..), ..rest]
    | [lexer.Token(kind: lexer.Comment, ..), ..rest] -> Ok(rest)

    [lexer.Token(kind: lexer.EOF, ..), ..] ->
      Error(Diagnostic(
        kind: UnexpectedEof,
        span: source.Span(start: byte_length, end: byte_length),
      ))

    [token, ..] ->
      Error(Diagnostic(kind: UnexpectedToken(token.kind), span: token.span))

    [] ->
      Error(Diagnostic(
        kind: UnexpectedEof,
        span: source.Span(start: byte_length, end: byte_length),
      ))
  }
}
