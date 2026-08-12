import gleam/bool
import gleam/dict
import gleam/list
import gleam/result
import webql/compiler/parser_1
import webql/compiler/source

/// A reference identified by a written label or a local index.
pub type Reference(a) {
  Labeled(a)
  Unlabeled(Int)
}

/// A resolved WebQL graph with its interface and objects grouped by kind.
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
    supernodes: List(Supernode),
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

/// A named graph nested inside another graph.
///
/// ## Examples
///
///     Inner = in: Int -> out: Int { .in -> .out }
pub type Supernode {
  Supernode(
    name: String,
    ast: Ast,
    reference: Reference(String),
    span: source.Span,
  )
}

/// A labeled connection into a node.
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

/// A named node.
///
/// ## Examples
///
///     math = Math
///     add = service.Add
pub type Node {
  Node(
    name: String,
    path: List(String),
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
  ExpectedBinding
  InvalidElement
}

type Context {
  Context(
    parameters: dict.Dict(String, Parameter),
    returns: dict.Dict(String, Return),
    supernodes: dict.Dict(String, Supernode),
    boundaries: dict.Dict(String, Boundary),
    nodes: dict.Dict(String, Node),
    edges: dict.Dict(List(String), Edge),
  )
}

/// Resolves a parsed WebQL block into a structural graph.
pub fn resolve(ast: parser_1.Ast) -> Result(Ast, Diagnostic) {
  let parser_1.Ast(parameters:, returns:, elements:, span:) = ast
  let context =
    Context(
      parameters: dict.new(),
      returns: dict.new(),
      supernodes: dict.new(),
      boundaries: dict.new(),
      nodes: dict.new(),
      edges: dict.new(),
    )

  use #(parameters, context) <- result.try(resolve_parameters(
    parameters,
    context,
  ))
  use #(returns, context) <- result.try(resolve_returns(returns, context))
  use #(supernodes, boundaries, nodes, edges) <- result.try(
    resolve_elements(elements, context, [], [], [], []),
  )

  Ok(Ast(parameters:, returns:, supernodes:, boundaries:, nodes:, edges:, span:))
}

// PRIVATE FUNCTIONS
// =================
fn resolve_parameters(
  declarations: List(parser_1.Declaration),
  context: Context,
) {
  case declarations {
    // SYNTAX: `name: Type`
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

  let context =
    Context(
      ..context,
      parameters: dict.insert(context.parameters, name, parameter),
    )

  Ok(#(parameter, context))
}

fn resolve_returns(declarations: List(parser_1.Declaration), context: Context) {
  case declarations {
    // SYNTAX: `name: Type`
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

  let context =
    Context(..context, returns: dict.insert(context.returns, name, return))

  Ok(#(return, context))
}

fn resolve_elements(
  elements: List(parser_1.Element),
  context: Context,
  supernodes: List(Supernode),
  boundaries: List(Boundary),
  nodes: List(Node),
  edges: List(Edge),
) {
  case elements {
    // SYNTAX: `Inner = in: Int -> out: Int { ... }`
    [parser_1.Definition(element: parser_1.Block(..), ..) as definition, ..rest] -> {
      use #(supernode, context) <- result.try(resolve_supernode(
        definition,
        context,
      ))
      resolve_elements(
        rest,
        context,
        [supernode, ..supernodes],
        boundaries,
        nodes,
        edges,
      )
    }

    // SYNTAX: `name = value -> Node`
    [
      parser_1.Definition(element: parser_1.Edge(to: parser_1.Node(..), ..), ..) as definition,
      ..rest
    ] -> {
      use #(boundary, context) <- result.try(resolve_boundary(
        definition,
        context,
      ))

      resolve_elements(
        rest,
        context,
        supernodes,
        [boundary, ..boundaries],
        nodes,
        edges,
      )
    }

    // SYNTAX: `name = Node`
    [
      parser_1.Definition(element: parser_1.Value(parser_1.Node(..), ..), ..) as definition,
      ..rest
    ] -> {
      use #(node, context) <- result.try(resolve_node(definition, context))
      resolve_elements(
        rest,
        context,
        supernodes,
        boundaries,
        [node, ..nodes],
        edges,
      )
    }

    // SYNTAX: `name = value`
    [parser_1.Definition(element: parser_1.Value(..), span:, ..), ..] ->
      Error(Diagnostic(kind: ExpectedBinding, span:))

    // SYNTAX: `value -> Node`
    [parser_1.Edge(to: parser_1.Node(..) as node, ..), ..] ->
      Error(Diagnostic(kind: ExpectedBinding, span: node.span))

    // SYNTAX: `name = value -> .input`
    [
      parser_1.Definition(
        element: parser_1.Edge(to: parser_1.Port(name, span:), ..),
        ..,
      ),
      ..
    ] -> Error(Diagnostic(kind: ExpectedNode([name]), span:))

    // SYNTAX: `name = value -> owner.input`
    [
      parser_1.Definition(
        element: parser_1.Edge(to: parser_1.Vertex(path, span:), ..),
        ..,
      ),
      ..
    ] -> Error(Diagnostic(kind: ExpectedNode(path), span:))

    // SYNTAX: `value -> input`
    [parser_1.Edge(..) as edge, ..rest] -> {
      use #(edge, context) <- result.try(resolve_edge(edge, context))
      resolve_elements(rest, context, supernodes, boundaries, nodes, [
        edge,
        ..edges
      ])
    }

    // SYNTAX: `Node`
    [parser_1.Value(parser_1.Node(path, span:), ..), ..] ->
      Error(Diagnostic(kind: ExpectedNode(path), span:))

    [parser_1.Definition(span:, ..), ..]
    | [parser_1.Value(span:, ..), ..]
    | [parser_1.Block(span:, ..), ..] ->
      Error(Diagnostic(kind: InvalidElement, span:))

    [] ->
      Ok(#(
        list.reverse(supernodes),
        list.reverse(boundaries),
        list.reverse(nodes),
        list.reverse(edges),
      ))
  }
}

fn resolve_supernode(definition: parser_1.Element, context: Context) {
  case definition {
    // SYNTAX: `Inner = in: Int -> out: Int { ... }`
    parser_1.Definition(name:, element: parser_1.Block(nested, ..), span:, ..) -> {
      use <- bool.guard(
        when: has_supernode(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use ast <- result.try(resolve(nested))
      let supernode = Supernode(name:, ast:, reference: Labeled(name), span:)
      let context =
        Context(
          ..context,
          supernodes: dict.insert(context.supernodes, name, supernode),
        )

      Ok(#(supernode, context))
    }

    parser_1.Definition(span:, ..)
    | parser_1.Edge(span:, ..)
    | parser_1.Value(span:, ..)
    | parser_1.Block(span:, ..) ->
      Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_boundary(definition: parser_1.Element, context: Context) {
  case definition {
    // SYNTAX: `name = value -> Node`
    parser_1.Definition(
      name:,
      element: parser_1.Edge(from:, to: parser_1.Node([_node] as to, ..), ..),
      span:,
      ..,
    ) -> {
      use <- bool.guard(
        when: has_boundary(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use <- bool.guard(
        when: has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use from <- result.try(resolve_from(from, context))

      let boundary =
        Boundary(name:, from:, to:, reference: Labeled(name), span:)

      let context =
        Context(
          ..context,
          boundaries: dict.insert(context.boundaries, name, boundary),
        )

      Ok(#(boundary, context))
    }

    // SYNTAX: `name = value -> owner.Node`
    parser_1.Definition(
      name:,
      element: parser_1.Edge(
        from:,
        to: parser_1.Node([owner, _member] as to, ..) as node,
        ..,
      ),
      span:,
      ..,
    ) -> {
      use <- bool.guard(
        when: has_boundary(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )
      use <- bool.guard(
        when: has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use from <- result.try(resolve_from(from, context))
      let has_boundary = has_boundary(context, owner)
      let has_node = has_node(context, owner)
      use <- bool.guard(
        when: !has_boundary && !has_node,
        return: Error(Diagnostic(
          kind: UnknownDefinition(owner),
          span: node.span,
        )),
      )

      let boundary =
        Boundary(name:, from:, to:, reference: Labeled(name), span:)
      let context =
        Context(
          ..context,
          boundaries: dict.insert(context.boundaries, name, boundary),
        )

      Ok(#(boundary, context))
    }

    parser_1.Definition(
      element: parser_1.Edge(to: parser_1.Node(to, ..) as node, ..),
      ..,
    ) -> Error(Diagnostic(kind: UnknownNode(to), span: node.span))

    parser_1.Definition(span:, ..)
    | parser_1.Edge(span:, ..)
    | parser_1.Value(span:, ..)
    | parser_1.Block(span:, ..) ->
      Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_node(definition: parser_1.Element, context: Context) {
  case definition {
    // SYNTAX: `name = Node`
    parser_1.Definition(
      name:,
      element: parser_1.Value(parser_1.Node([_node] as path, ..), ..),
      span:,
      ..,
    ) -> {
      use <- bool.guard(
        when: has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )
      use <- bool.guard(
        when: has_boundary(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      let node = Node(name:, path:, reference: Labeled(name), span:)
      let context =
        Context(..context, nodes: dict.insert(context.nodes, name, node))

      Ok(#(node, context))
    }

    // SYNTAX: `name = owner.Node`
    parser_1.Definition(
      name:,
      element: parser_1.Value(
        parser_1.Node([owner, _member] as path, ..) as node,
        ..,
      ),
      span:,
      ..,
    ) -> {
      use <- bool.guard(
        when: has_node(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )
      use <- bool.guard(
        when: has_boundary(context, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      let has_boundary = has_boundary(context, owner)
      let has_node = has_node(context, owner)
      use <- bool.guard(
        when: !has_boundary && !has_node,
        return: Error(Diagnostic(
          kind: UnknownDefinition(owner),
          span: node.span,
        )),
      )

      let node = Node(name:, path:, reference: Labeled(name), span:)
      let context =
        Context(..context, nodes: dict.insert(context.nodes, name, node))

      Ok(#(node, context))
    }

    parser_1.Definition(
      element: parser_1.Value(parser_1.Node(path, ..) as node, ..),
      ..,
    ) -> Error(Diagnostic(kind: UnknownNode(path), span: node.span))

    parser_1.Definition(span:, ..)
    | parser_1.Edge(span:, ..)
    | parser_1.Value(span:, ..)
    | parser_1.Block(span:, ..) ->
      Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_edge(edge: parser_1.Element, context: Context) {
  case edge {
    // SYNTAX: `value -> input`
    parser_1.Edge(from:, to:, span:) -> {
      use from <- result.try(resolve_from(from, context))
      use to <- result.try(resolve_input(to, context))
      use <- bool.guard(
        when: has_edge(context, to.path),
        return: Error(Diagnostic(kind: DuplicateInput(to.path), span: to.span)),
      )

      let reference = Unlabeled(dict.size(context.edges))
      let edge = Edge(from:, to:, reference:, span:)
      let context =
        Context(..context, edges: dict.insert(context.edges, to.path, edge))

      Ok(#(edge, context))
    }

    parser_1.Definition(span:, ..)
    | parser_1.Value(span:, ..)
    | parser_1.Block(span:, ..) ->
      Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_from(value: parser_1.Value, context: Context) {
  case value {
    // SYNTAX: `1`
    parser_1.Int(value, span:) -> Ok(Literal(value: Int(value, span:), span:))

    // SYNTAX: `1.23`
    parser_1.Float(value, span:) ->
      Ok(Literal(value: Float(value, span:), span:))

    // SYNTAX: `"value"`
    parser_1.String(value, span:) ->
      Ok(Literal(value: String(value, span:), span:))

    // SYNTAX: `.parameter`
    parser_1.Port(name, span:) -> {
      let path = [name]
      let has_parameter = has_parameter(context, name)
      let has_return = has_return(context, name)

      use <- bool.guard(
        when: !has_parameter && !has_return,
        return: Error(Diagnostic(kind: UnknownOutput(path), span:)),
      )
      use <- bool.guard(
        when: !has_parameter,
        return: Error(Diagnostic(kind: ExpectedOutput, span:)),
      )

      Ok(Output(path:, reference: Labeled(path), span:))
    }

    // SYNTAX: `owner.output`
    parser_1.Vertex([owner, _member] as path, span:) -> {
      let has_boundary = has_boundary(context, owner)
      let has_node = has_node(context, owner)
      use <- bool.guard(
        when: !has_boundary && !has_node,
        return: Error(Diagnostic(kind: UnknownDefinition(owner), span:)),
      )

      Ok(Output(path:, reference: Labeled(path), span:))
    }

    // SYNTAX: `value`
    parser_1.Vertex([_name], span:) ->
      Error(Diagnostic(kind: ExpectedOutput, span:))

    parser_1.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownOutput(path), span:))

    // SYNTAX: `Node`
    parser_1.Node(path, span:) ->
      Error(Diagnostic(kind: ExpectedNode(path), span:))
  }
}

fn resolve_input(value: parser_1.Value, context: Context) {
  case value {
    // SYNTAX: `.return`
    parser_1.Port(name, span:) -> {
      let path = [name]
      let has_parameter = has_parameter(context, name)
      let has_return = has_return(context, name)

      use <- bool.guard(
        when: !has_parameter && !has_return,
        return: Error(Diagnostic(kind: UnknownInput(path), span:)),
      )
      use <- bool.guard(
        when: !has_return,
        return: Error(Diagnostic(kind: ExpectedInput, span:)),
      )

      Ok(Input(path:, reference: Labeled(path), span:))
    }

    // SYNTAX: `owner.input`
    parser_1.Vertex([owner, _member] as path, span:) -> {
      let has_boundary = has_boundary(context, owner)
      let has_node = has_node(context, owner)
      use <- bool.guard(
        when: !has_boundary && !has_node,
        return: Error(Diagnostic(kind: UnknownDefinition(owner), span:)),
      )

      Ok(Input(path:, reference: Labeled(path), span:))
    }

    // SYNTAX: `value`
    parser_1.Vertex([_name], span:) ->
      Error(Diagnostic(kind: ExpectedInput, span:))

    parser_1.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownInput(path), span:))

    parser_1.Node(path, span:) ->
      Error(Diagnostic(kind: ExpectedNode(path), span:))

    value -> Error(Diagnostic(kind: ExpectedInput, span: value.span))
  }
}

fn has_parameter(context: Context, name: String) {
  dict.has_key(context.parameters, name)
}

fn has_return(context: Context, name: String) {
  dict.has_key(context.returns, name)
}

fn has_supernode(context: Context, name: String) {
  dict.has_key(context.supernodes, name)
}

fn has_node(context: Context, name: String) {
  dict.has_key(context.nodes, name)
}

fn has_edge(context: Context, path: List(String)) {
  dict.has_key(context.edges, path)
}

fn has_boundary(context: Context, name: String) {
  dict.has_key(context.boundaries, name)
}
