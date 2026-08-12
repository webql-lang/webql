import gleam/bool
import gleam/dict
import gleam/result
import gleam/set
import webql/compiler/parser_1
import webql/compiler/source

/// A reference identified by a written label or a local index.
pub type Reference(a) {
  Labeled(a)
  Unlabeled(Int)
}

/// A resolved WebQL graph.
///
/// ## Examples
///
///     token: Uuid -> out: Int {
///       service = .token -> Service
///       math = service.Math
///       math.out -> .out
///     }
pub type Ast {
  Ast(
    parameters: List(Parameter),
    returns: List(Return),
    boundaries: List(Boundary),
    nodes: List(Node),
    edges: List(Edge),
    span: source.Span,
  )
}

/// A value supplied by the caller and used on the left side of an edge.
///
/// ## Examples
///
///     token: Uuid
pub type Parameter {
  Parameter(
    name: String,
    port: Port,
    reference: Reference(List(String)),
    span: source.Span,
  )
}

/// A value produced by the graph and returned through the right side of an edge.
///
/// ## Examples
///
///     out: Int
pub type Return {
  Return(
    name: String,
    port: Port,
    reference: Reference(List(String)),
    span: source.Span,
  )
}

/// A declared parameter or return type.
///
/// ## Examples
///
///     Uuid
///     Int
pub type Port {
  Port(name: String)
}

/// A named access point into a collection of nodes or values.
///
/// ## Examples
///
///     service = .token -> Service
///     workflow = create.id -> service.Workflow
pub type Boundary {
  Boundary(
    name: String,
    from: From,
    to: List(String),
    reference: Reference(String),
    span: source.Span,
  )
}

/// A named executable node or instantiated local graph.
///
/// ## Examples
///
///     math = Math
///     add = service.Add
///     inner = Inner
pub type Node {
  Node(
    name: String,
    path: List(String),
    reference: Reference(String),
    span: source.Span,
  )
  Supernode(
    name: String,
    ast: Ast,
    reference: Reference(String),
    span: source.Span,
  )
}

/// A directed connection from an output or literal to an input.
///
/// ## Examples
///
///     .l -> add.l
///     add.out -> .out
pub type Edge {
  Edge(from: From, to: Input, reference: Reference(String), span: source.Span)
}

/// A destination that receives an edge.
///
/// ## Examples
///
///     add.l
///     .out
pub type Input {
  Input(
    path: List(String),
    reference: Reference(List(String)),
    span: source.Span,
  )
}

/// An output or literal on the left side of an arrow.
///
/// ## Examples
///
///     .token
///     add.out
///     1
pub type From {
  Output(
    path: List(String),
    reference: Reference(List(String)),
    span: source.Span,
  )
  Literal(value: Value, span: source.Span)
}

/// A literal embedded directly in the graph.
///
/// ## Examples
///
///     1
///     1.23
///     "hello"
pub type Value {
  Int(Int, span: source.Span)
  Float(Float, span: source.Span)
  String(String, span: source.Span)
}

/// A resolution error and the syntax span where it occurred.
pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// The kind of error encountered while resolving a graph.
pub type DiagnosticKind {
  UnknownNode(path: List(String))
  UnknownDefinition(name: String)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  DuplicateParameter(name: String)
  DuplicateReturn(name: String)
  DuplicateDefinition(name: String)
  DuplicateInput(path: List(String))
  ExpectedNode(path: List(String))
  ExpectedInput
  ExpectedOutput
  ExpectedDefinition
  InvalidElement
}

type Context {
  Context(
    parameters: set.Set(String),
    returns: set.Set(String),
    supernodes: dict.Dict(String, Ast),
    boundaries: set.Set(String),
    nodes: set.Set(String),
    edges: set.Set(List(String)),
  )
}

/// Resolves a parsed WebQL block into a structural graph.
pub fn resolve(ast: parser_1.Ast) -> Result(Ast, Diagnostic) {
  let parser_1.Ast(parameters:, returns:, elements:, span:) = ast
  let context =
    Context(
      parameters: set.new(),
      returns: set.new(),
      supernodes: dict.new(),
      boundaries: set.new(),
      nodes: set.new(),
      edges: set.new(),
    )

  use #(parameters, context) <- result.try(resolve_parameters(
    parameters,
    context,
  ))

  use #(returns, context) <- result.try(resolve_returns(returns, context))
  use context <- result.try(resolve_supernodes(elements, context))
  use #(boundaries, nodes, edges) <- result.try(resolve_elements(
    elements,
    context,
  ))

  Ok(Ast(parameters:, returns:, boundaries:, nodes:, edges:, span:))
}

// PRIVATE FUNCTIONS
// =================
fn resolve_parameters(
  declarations: List(parser_1.Declaration),
  context: Context,
) {
  case declarations {
    [declaration, ..rest] -> {
      use #(parameter, context) <- result.try(resolve_parameter(
        declaration,
        context,
      ))

      use #(parameters, context) <- result.try(resolve_parameters(rest, context))

      Ok(#([parameter, ..parameters], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_parameter(declaration: parser_1.Declaration, context: Context) {
  let parser_1.Declaration(name:, typename:, span:) = declaration
  use <- bool.guard(
    when: has_parameter(context, name),
    return: Error(Diagnostic(kind: DuplicateParameter(name), span:)),
  )

  let parameter =
    Parameter(name:, port: Port(typename), reference: Labeled([name]), span:)

  let context = add_parameter(context, parameter)

  Ok(#(parameter, context))
}

fn resolve_returns(declarations: List(parser_1.Declaration), context: Context) {
  case declarations {
    [declaration, ..rest] -> {
      use #(return, context) <- result.try(resolve_return(declaration, context))
      use #(returns, context) <- result.try(resolve_returns(rest, context))
      Ok(#([return, ..returns], context))
    }

    [] -> Ok(#([], context))
  }
}

fn resolve_return(declaration: parser_1.Declaration, context: Context) {
  let parser_1.Declaration(name:, typename:, span:) = declaration
  use <- bool.guard(
    when: has_return(context, name),
    return: Error(Diagnostic(kind: DuplicateReturn(name), span:)),
  )

  let return =
    Return(name:, port: Port(typename), reference: Labeled([name]), span:)

  let context = add_return(context, return)

  Ok(#(return, context))
}

fn resolve_supernodes(elements: List(parser_1.Element), context: Context) {
  case elements {
    [parser_1.Definition(name:, element:, span:, ..), ..rest] -> {
      use context <- result.try(resolve_supernode(name, element, span, context))
      resolve_supernodes(rest, context)
    }

    [parser_1.Edge(..), ..rest]
    | [parser_1.Value(..), ..rest]
    | [parser_1.Block(..), ..rest] -> resolve_supernodes(rest, context)

    [] -> Ok(context)
  }
}

fn resolve_supernode(
  name: String,
  element: parser_1.Element,
  span: source.Span,
  context: Context,
) {
  case element {
    parser_1.Block(ast, ..) -> {
      use <- bool.guard(
        when: has_supernode(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use ast <- result.try(resolve(ast))
      let context = add_supernode(context, name, ast)

      Ok(context)
    }

    parser_1.Definition(..) | parser_1.Edge(..) | parser_1.Value(..) ->
      Ok(context)
  }
}

fn resolve_elements(elements: List(parser_1.Element), context: Context) {
  case elements {
    [parser_1.Definition(name:, element:, span:, ..), ..rest] ->
      resolve_definition(name, element, span, rest, context)

    [parser_1.Edge(from:, to:, span:), ..rest] -> {
      use #(edge, context) <- result.try(resolve_edge(from, to, span, context))
      use #(boundaries, nodes, edges) <- result.try(resolve_elements(
        rest,
        context,
      ))
      Ok(#(boundaries, nodes, [edge, ..edges]))
    }

    [parser_1.Value(value, span:), ..] -> resolve_value(value, span)

    [parser_1.Block(span:, ..), ..] ->
      Error(Diagnostic(kind: InvalidElement, span:))

    [] -> Ok(#([], [], []))
  }
}

fn resolve_definition(
  name: String,
  element: parser_1.Element,
  span: source.Span,
  rest: List(parser_1.Element),
  context: Context,
) {
  case element {
    parser_1.Block(..) -> resolve_elements(rest, context)

    parser_1.Edge(from:, to:, ..) -> {
      use boundary <- result.try(resolve_boundary(name, from, to, span, context))
      let context = add_boundary(context, boundary)

      use #(boundaries, nodes, edges) <- result.try(resolve_elements(
        rest,
        context,
      ))

      Ok(#([boundary, ..boundaries], nodes, edges))
    }

    parser_1.Value(value, ..) -> {
      use node <- result.try(resolve_node(name, value, span, context))
      let context = add_node(context, node)

      use #(boundaries, nodes, edges) <- result.try(resolve_elements(
        rest,
        context,
      ))

      Ok(#(boundaries, [node, ..nodes], edges))
    }

    parser_1.Definition(..) -> Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_value(value: parser_1.Value, span: source.Span) {
  case value {
    parser_1.Node(path, span:) ->
      Error(Diagnostic(kind: ExpectedNode(path), span:))

    parser_1.Int(..)
    | parser_1.Float(..)
    | parser_1.String(..)
    | parser_1.Port(..)
    | parser_1.Vertex(..) -> Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_boundary(
  name: String,
  from: parser_1.Value,
  to: parser_1.Value,
  span: source.Span,
  context: Context,
) {
  case to {
    parser_1.Node([definition], ..) -> {
      use <- bool.guard(
        when: has_boundary(context, name) || has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use from <- result.try(resolve_from(from, context))

      Ok(Boundary(
        name:,
        from:,
        to: [definition],
        reference: Labeled(name),
        span:,
      ))
    }

    parser_1.Node([owner, member], ..) -> {
      use <- bool.guard(
        when: has_boundary(context, name) || has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use from <- result.try(resolve_from(from, context))

      use <- bool.guard(
        when: !has_boundary(context, owner) && !has_node(context, owner),
        return: Error(Diagnostic(kind: UnknownDefinition(owner), span: to.span)),
      )

      Ok(Boundary(
        name:,
        from:,
        to: [owner, member],
        reference: Labeled(name),
        span:,
      ))
    }

    parser_1.Node(path, ..) ->
      Error(Diagnostic(kind: UnknownNode(path), span: to.span))

    parser_1.Port(name, ..) ->
      Error(Diagnostic(kind: ExpectedNode([name]), span: to.span))

    parser_1.Vertex(path, ..) ->
      Error(Diagnostic(kind: ExpectedNode(path), span: to.span))

    parser_1.Int(..) | parser_1.Float(..) | parser_1.String(..) ->
      Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_node(
  name: String,
  value: parser_1.Value,
  span: source.Span,
  context: Context,
) {
  case value {
    parser_1.Node([definition], ..) -> {
      use <- bool.guard(
        when: has_boundary(context, name) || has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      let node = case dict.get(context.supernodes, definition) {
        Ok(ast) -> Supernode(name:, ast:, reference: Labeled(name), span:)
        Error(Nil) ->
          Node(name:, path: [definition], reference: Labeled(name), span:)
      }

      Ok(node)
    }

    parser_1.Node([owner, member], ..) -> {
      use <- bool.guard(
        when: has_boundary(context, name) || has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use <- bool.guard(
        when: !has_boundary(context, owner) && !has_node(context, owner),
        return: Error(Diagnostic(
          kind: UnknownDefinition(owner),
          span: value.span,
        )),
      )

      Ok(Node(name:, path: [owner, member], reference: Labeled(name), span:))
    }

    parser_1.Node(path, ..) ->
      Error(Diagnostic(kind: UnknownNode(path), span: value.span))

    parser_1.Int(..)
    | parser_1.Float(..)
    | parser_1.String(..)
    | parser_1.Port(..)
    | parser_1.Vertex(..) -> Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_edge(
  from: parser_1.Value,
  to: parser_1.Value,
  span: source.Span,
  context: Context,
) {
  use from <- result.try(resolve_from(from, context))
  use to <- result.try(resolve_input(to, context))
  use <- bool.guard(
    when: has_edge(context, to.path),
    return: Error(Diagnostic(kind: DuplicateInput(to.path), span: to.span)),
  )

  let edge =
    Edge(from:, to:, reference: Unlabeled(set.size(context.edges)), span:)

  let context = add_edge(context, edge)

  Ok(#(edge, context))
}

fn resolve_from(value: parser_1.Value, context: Context) {
  case value {
    parser_1.Int(value, span:) -> Ok(Literal(value: Int(value, span:), span:))

    parser_1.Float(value, span:) ->
      Ok(Literal(value: Float(value, span:), span:))

    parser_1.String(value, span:) ->
      Ok(Literal(value: String(value, span:), span:))

    parser_1.Port(name, span:) -> {
      let path = [name]
      use <- bool.guard(
        when: !has_parameter(context, name) && !has_return(context, name),
        return: Error(Diagnostic(kind: UnknownOutput(path), span:)),
      )

      use <- bool.guard(
        when: !has_parameter(context, name),
        return: Error(Diagnostic(kind: ExpectedOutput, span:)),
      )

      Ok(Output(path:, reference: Labeled(path), span:))
    }

    parser_1.Vertex([owner, member], span:) -> {
      use <- bool.guard(
        when: !has_boundary(context, owner) && !has_node(context, owner),
        return: Error(Diagnostic(kind: UnknownDefinition(owner), span:)),
      )

      let path = [owner, member]
      Ok(Output(path:, reference: Labeled(path), span:))
    }

    parser_1.Vertex([_], span:) ->
      Error(Diagnostic(kind: ExpectedOutput, span:))

    parser_1.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownOutput(path), span:))

    parser_1.Node(path, span:) ->
      Error(Diagnostic(kind: ExpectedNode(path), span:))
  }
}

fn resolve_input(value: parser_1.Value, context: Context) {
  case value {
    parser_1.Port(name, span:) -> {
      let path = [name]
      use <- bool.guard(
        when: !has_parameter(context, name) && !has_return(context, name),
        return: Error(Diagnostic(kind: UnknownInput(path), span:)),
      )

      use <- bool.guard(
        when: !has_return(context, name),
        return: Error(Diagnostic(kind: ExpectedInput, span:)),
      )

      Ok(Input(path:, reference: Labeled(path), span:))
    }

    parser_1.Vertex([owner, member], span:) -> {
      use <- bool.guard(
        when: !has_boundary(context, owner) && !has_node(context, owner),
        return: Error(Diagnostic(kind: UnknownDefinition(owner), span:)),
      )

      let path = [owner, member]

      Ok(Input(path:, reference: Labeled(path), span:))
    }

    parser_1.Vertex([_], span:) -> Error(Diagnostic(kind: ExpectedInput, span:))

    parser_1.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownInput(path), span:))

    parser_1.Node(span:, ..) ->
      Error(Diagnostic(kind: ExpectedDefinition, span:))

    parser_1.Int(..) | parser_1.Float(..) | parser_1.String(..) ->
      Error(Diagnostic(kind: ExpectedInput, span: value.span))
  }
}

fn add_parameter(context: Context, parameter: Parameter) -> Context {
  Context(..context, parameters: set.insert(context.parameters, parameter.name))
}

fn has_parameter(context: Context, name: String) -> Bool {
  set.contains(context.parameters, name)
}

fn add_return(context: Context, return: Return) -> Context {
  Context(..context, returns: set.insert(context.returns, return.name))
}

fn has_return(context: Context, name: String) -> Bool {
  set.contains(context.returns, name)
}

fn add_supernode(context: Context, name: String, ast: Ast) -> Context {
  Context(..context, supernodes: dict.insert(context.supernodes, name, ast))
}

fn has_supernode(context: Context, name: String) -> Bool {
  dict.has_key(context.supernodes, name)
}

fn add_boundary(context: Context, boundary: Boundary) -> Context {
  Context(..context, boundaries: set.insert(context.boundaries, boundary.name))
}

fn has_boundary(context: Context, name: String) -> Bool {
  set.contains(context.boundaries, name)
}

fn add_node(context: Context, node: Node) -> Context {
  Context(..context, nodes: set.insert(context.nodes, node.name))
}

fn has_node(context: Context, name: String) -> Bool {
  set.contains(context.nodes, name)
}

fn add_edge(context: Context, edge: Edge) -> Context {
  Context(..context, edges: set.insert(context.edges, edge.to.path))
}

fn has_edge(context: Context, path: List(String)) -> Bool {
  set.contains(context.edges, path)
}
