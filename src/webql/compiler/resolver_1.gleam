import gleam/bool
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import webql/compiler/parser_1
import webql/compiler/source
import webql/schema_1

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
    typename: Typename,
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
    typename: Typename,
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
pub type Typename {
  Typename(name: String)
}

/// A reusable graph declared inside another graph.
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
    owner: option.Option(String),
    boundary: String,
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
    owner: option.Option(String),
    node: String,
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
  Edge(from: From, to: To, reference: Reference(String), span: source.Span)
}

/// A resolved graph path.
pub type Path {
  Port(name: String)
  Vertex(owner: String, name: String)
}

/// The right side of an edge.
///
/// ## Examples
///
///     add.l
///     .out
pub type To {
  Input(path: Path, reference: Reference(List(String)), span: source.Span)
}

/// An output or literal on the left side of an arrow.
///
/// ## Examples
///
///     .token
///     add.out
///     1
pub type From {
  Output(path: Path, reference: Reference(List(String)), span: source.Span)
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
  UnknownTypename(name: String)
  UnknownBoundary(path: List(String))
  UnknownNode(path: List(String))
  UnknownDefinition(name: String)
  UnknownInput(path: List(String))
  UnknownOutput(path: List(String))
  DuplicateParameter(name: String)
  DuplicateReturn(name: String)
  DuplicateDefinition(name: String)
  DuplicateInput(path: Path)
  ExpectedBoundary(path: List(String))
  ExpectedNode(path: List(String))
  ExpectedInput
  ExpectedOutput
  ExpectedDefinition
  InvalidElement
}

type Context {
  Context(
    typenames: dict.Dict(String, schema_1.Typename),
    parameters: set.Set(String),
    returns: set.Set(String),
    boundaries: dict.Dict(String, schema_1.Boundary),
    nodes: dict.Dict(String, schema_1.Node),
    outputs: dict.Dict(String, dict.Dict(String, schema_1.Output)),
    edges: set.Set(Path),
  )
}

/// Resolves a parsed WebQL block against a schema into a structural graph.
pub fn resolve(
  ast: parser_1.Ast,
  schema: schema_1.Schema,
) -> Result(Ast, Diagnostic) {
  let outputs =
    dict.fold(
      schema.boundaries,
      dict.map_values(schema.nodes, fn(_, node) { node.outputs }),
      fn(outputs, name, boundary) {
        dict.insert(outputs, name, boundary.outputs)
      },
    )

  let context =
    Context(
      typenames: schema.typenames,
      parameters: set.new(),
      returns: set.new(),
      boundaries: schema.boundaries,
      nodes: schema.nodes,
      outputs:,
      edges: set.new(),
    )

  use #(parameters, context) <- result.try(resolve_parameters(
    ast.parameters,
    context,
  ))

  use #(returns, context) <- result.try(resolve_returns(ast.returns, context))
  use #(supernodes, context) <- result.try(resolve_supernodes(
    ast.elements,
    schema,
    context,
  ))
  use #(boundaries, nodes, edges) <- result.try(resolve_elements(
    ast.elements,
    context,
  ))

  Ok(Ast(
    parameters:,
    returns:,
    supernodes:,
    boundaries:,
    nodes:,
    edges:,
    span: ast.span,
  ))
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

  use <- bool.guard(
    when: !has_typename(context, typename),
    return: Error(Diagnostic(kind: UnknownTypename(typename), span:)),
  )

  let parameter =
    Parameter(
      name:,
      typename: Typename(typename),
      reference: Labeled([name]),
      span:,
    )

  let context = add_parameter(context, parameter)

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

  use <- bool.guard(
    when: !has_typename(context, typename),
    return: Error(Diagnostic(kind: UnknownTypename(typename), span:)),
  )

  let return =
    Return(
      name:,
      typename: Typename(typename),
      reference: Labeled([name]),
      span:,
    )

  let context = add_return(context, return)

  Ok(#(return, context))
}

fn resolve_supernodes(
  elements: List(parser_1.Element),
  schema: schema_1.Schema,
  context: Context,
) {
  case elements {
    [
      parser_1.Definition(name:, element: parser_1.Block(ast, ..), span:, ..),
      ..rest
    ] -> {
      use #(supernode, context) <- result.try(resolve_supernode(
        name,
        ast,
        span,
        schema,
        context,
      ))
      use #(supernodes, context) <- result.try(resolve_supernodes(
        rest,
        schema,
        context,
      ))

      Ok(#([supernode, ..supernodes], context))
    }

    [parser_1.Definition(..), ..rest]
    | [parser_1.Edge(..), ..rest]
    | [parser_1.Value(..), ..rest]
    | [parser_1.Block(..), ..rest] -> resolve_supernodes(rest, schema, context)

    [] -> Ok(#([], context))
  }
}

fn resolve_supernode(
  name: String,
  ast: parser_1.Ast,
  span: source.Span,
  schema: schema_1.Schema,
  context: Context,
) {
  // SYNTAX: `Inner = in: Int -> out: Int { ... }`
  use <- bool.guard(
    when: has_boundary(context.boundaries, name)
      || has_node(context.nodes, name),
    return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
  )

  use ast <- result.try(resolve(ast, schema))

  let node =
    schema_1.Node(
      inputs: add_inputs(ast.parameters),
      outputs: add_outputs(ast.returns),
    )

  let supernode = Supernode(name:, ast:, reference: Labeled(name), span:)
  let context = add_node(context, name, node)

  Ok(#(supernode, context))
}

fn resolve_elements(elements: List(parser_1.Element), context: Context) {
  case elements {
    [parser_1.Definition(name:, element:, span:, ..), ..rest] ->
      resolve_definition(name, element, span, rest, context)

    // SYNTAX: `value -> input`
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
    // SYNTAX: `Inner = in: Int -> out: Int { ... }`
    parser_1.Block(..) -> resolve_elements(rest, context)

    // SYNTAX: `name = value -> Node`
    parser_1.Edge(from:, to:, ..) -> {
      use #(boundary, context) <- result.try(resolve_boundary(
        name,
        from,
        to,
        span,
        context,
      ))

      use #(boundaries, nodes, edges) <- result.try(resolve_elements(
        rest,
        context,
      ))

      Ok(#([boundary, ..boundaries], nodes, edges))
    }

    // SYNTAX: `name = Node` or `name = owner.Node`
    parser_1.Value(value, ..) -> {
      use #(node, context) <- result.try(resolve_node(
        name,
        value,
        span,
        context,
      ))

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
    // SYNTAX: `Node`
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
    // SYNTAX: `name = value -> Node`
    parser_1.Node([definition] as path, ..) -> {
      use <- bool.guard(
        when: has_boundary(context.boundaries, name)
          || has_node(context.nodes, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use from <- result.try(resolve_from(from, context))
      use <- bool.guard(
        when: !has_boundary(context.boundaries, definition)
          && has_node(context.nodes, definition),
        return: Error(Diagnostic(kind: ExpectedBoundary(path), span: to.span)),
      )

      use declaration <- result.try(get_boundary(
        context.boundaries,
        definition,
        Diagnostic(kind: UnknownBoundary(path), span: to.span),
      ))

      let boundary =
        Boundary(
          name:,
          from:,
          owner: option.None,
          boundary: definition,
          reference: Labeled(name),
          span:,
        )
      let context = add_boundary(context, name, declaration)

      Ok(#(boundary, context))
    }

    // SYNTAX: `name = value -> owner.Node`
    parser_1.Node([owner, member] as path, ..) -> {
      use <- bool.guard(
        when: has_boundary(context.boundaries, name)
          || has_node(context.nodes, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use from <- result.try(resolve_from(from, context))
      use <- bool.guard(
        when: !has_boundary(context.boundaries, owner)
          && has_node(context.nodes, owner),
        return: Error(Diagnostic(kind: ExpectedBoundary([owner]), span: to.span)),
      )

      use boundary <- result.try(get_boundary(
        context.boundaries,
        owner,
        Diagnostic(kind: UnknownDefinition(owner), span: to.span),
      ))

      use <- bool.guard(
        when: !has_boundary(boundary.boundaries, member)
          && has_node(boundary.nodes, member),
        return: Error(Diagnostic(kind: ExpectedBoundary(path), span: to.span)),
      )

      use declaration <- result.try(get_boundary(
        boundary.boundaries,
        member,
        Diagnostic(kind: UnknownBoundary(path), span: to.span),
      ))

      let boundary =
        Boundary(
          name:,
          from:,
          owner: option.Some(owner),
          boundary: member,
          reference: Labeled(name),
          span:,
        )
      let context = add_boundary(context, name, declaration)

      Ok(#(boundary, context))
    }

    parser_1.Node(path, span:) ->
      Error(Diagnostic(kind: UnknownBoundary(path), span:))

    parser_1.Port(name, span:) ->
      Error(Diagnostic(kind: ExpectedBoundary([name]), span:))

    parser_1.Vertex(path, span:) ->
      Error(Diagnostic(kind: ExpectedBoundary(path), span:))

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
    // SYNTAX: `name = Node`
    parser_1.Node([definition] as path, ..) -> {
      use <- bool.guard(
        when: has_boundary(context.boundaries, name)
          || has_node(context.nodes, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use <- bool.guard(
        when: !has_node(context.nodes, definition)
          && has_boundary(context.boundaries, definition),
        return: Error(Diagnostic(kind: ExpectedNode(path), span: value.span)),
      )

      use declaration <- result.try(get_node(
        context.nodes,
        definition,
        Diagnostic(kind: UnknownNode(path), span: value.span),
      ))

      let node =
        Node(
          name:,
          owner: option.None,
          node: definition,
          reference: Labeled(name),
          span:,
        )
      let context = add_node(context, name, declaration)

      Ok(#(node, context))
    }

    // SYNTAX: `name = owner.Node`
    parser_1.Node([owner, member] as path, ..) -> {
      use <- bool.guard(
        when: has_boundary(context.boundaries, name)
          || has_node(context.nodes, name),
        return: Error(Diagnostic(kind: DuplicateDefinition(name), span:)),
      )

      use <- bool.guard(
        when: !has_boundary(context.boundaries, owner)
          && has_node(context.nodes, owner),
        return: Error(Diagnostic(
          kind: ExpectedBoundary([owner]),
          span: value.span,
        )),
      )

      use boundary <- result.try(get_boundary(
        context.boundaries,
        owner,
        Diagnostic(kind: UnknownDefinition(owner), span: value.span),
      ))

      use <- bool.guard(
        when: !has_node(boundary.nodes, member)
          && has_boundary(boundary.boundaries, member),
        return: Error(Diagnostic(kind: ExpectedNode(path), span: value.span)),
      )

      use declaration <- result.try(get_node(
        boundary.nodes,
        member,
        Diagnostic(kind: UnknownNode(path), span: value.span),
      ))

      let node =
        Node(
          name:,
          owner: option.Some(owner),
          node: member,
          reference: Labeled(name),
          span:,
        )
      let context = add_node(context, name, declaration)

      Ok(#(node, context))
    }

    parser_1.Node(path, span:) ->
      Error(Diagnostic(kind: UnknownNode(path), span:))

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
  // SYNTAX: `value -> input`
  use from <- result.try(resolve_from(from, context))
  use to <- result.try(resolve_to(to, context))
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
    // SYNTAX: `1`
    parser_1.Int(value, span:) -> {
      use <- bool.guard(
        when: !has_typename(context, "Int"),
        return: Error(Diagnostic(kind: UnknownTypename("Int"), span:)),
      )

      Ok(Literal(value: Int(value, span:), span:))
    }

    // SYNTAX: `1.23`
    parser_1.Float(value, span:) -> {
      use <- bool.guard(
        when: !has_typename(context, "Float"),
        return: Error(Diagnostic(kind: UnknownTypename("Float"), span:)),
      )

      Ok(Literal(value: Float(value, span:), span:))
    }

    // SYNTAX: `"value"`
    parser_1.String(value, span:) -> {
      use <- bool.guard(
        when: !has_typename(context, "String"),
        return: Error(Diagnostic(kind: UnknownTypename("String"), span:)),
      )

      Ok(Literal(value: String(value, span:), span:))
    }

    // SYNTAX: `.parameter`
    parser_1.Port(name, span:) -> {
      let reference = [name]
      use <- bool.guard(
        when: !has_parameter(context, name) && !has_return(context, name),
        return: Error(Diagnostic(kind: UnknownOutput(reference), span:)),
      )

      use <- bool.guard(
        when: !has_parameter(context, name),
        return: Error(Diagnostic(kind: ExpectedOutput, span:)),
      )

      Ok(Output(path: Port(name), reference: Labeled(reference), span:))
    }

    // SYNTAX: `owner.member`
    parser_1.Vertex([owner, member], span:) -> {
      resolve_output(context, owner, member, span)
    }

    // SYNTAX: `value`
    parser_1.Vertex([_value], span:) ->
      Error(Diagnostic(kind: ExpectedOutput, span:))

    parser_1.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownOutput(path), span:))

    // SYNTAX: `Node`
    parser_1.Node(path, span:) ->
      Error(Diagnostic(kind: ExpectedNode(path), span:))
  }
}

fn resolve_output(
  context: Context,
  owner: String,
  name: String,
  span: source.Span,
) {
  let path = [owner, name]
  case dict.get(context.outputs, owner) {
    Ok(outputs) -> {
      use <- bool.guard(
        when: !dict.has_key(outputs, name),
        return: Error(Diagnostic(kind: UnknownOutput(path), span:)),
      )

      Ok(Output(path: Vertex(owner:, name:), reference: Labeled(path), span:))
    }

    Error(Nil) -> Error(Diagnostic(kind: UnknownDefinition(owner), span:))
  }
}

fn resolve_to(value: parser_1.Value, context: Context) {
  case value {
    // SYNTAX: `.return`
    parser_1.Port(name, span:) -> {
      let reference = [name]
      use <- bool.guard(
        when: !has_parameter(context, name) && !has_return(context, name),
        return: Error(Diagnostic(kind: UnknownInput(reference), span:)),
      )

      use <- bool.guard(
        when: !has_return(context, name),
        return: Error(Diagnostic(kind: ExpectedInput, span:)),
      )

      Ok(Input(path: Port(name), reference: Labeled(reference), span:))
    }

    // SYNTAX: `owner.input`
    parser_1.Vertex([owner, member], span:) -> {
      let reference = [owner, member]
      use <- bool.guard(
        when: has_boundary(context.boundaries, owner),
        return: Error(Diagnostic(kind: ExpectedNode([owner]), span:)),
      )

      use node <- result.try(get_node(
        context.nodes,
        owner,
        Diagnostic(kind: UnknownDefinition(owner), span:),
      ))

      use _ <- result.try(get_input(node.inputs, member, reference, span))

      Ok(Input(
        path: Vertex(owner:, name: member),
        reference: Labeled(reference),
        span:,
      ))
    }

    // SYNTAX: `value`
    parser_1.Vertex([_], span:) -> Error(Diagnostic(kind: ExpectedInput, span:))

    parser_1.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownInput(path), span:))

    parser_1.Node(span:, ..) ->
      Error(Diagnostic(kind: ExpectedDefinition, span:))

    parser_1.Int(..) | parser_1.Float(..) | parser_1.String(..) ->
      Error(Diagnostic(kind: ExpectedInput, span: value.span))
  }
}

fn has_typename(context: Context, name: String) -> Bool {
  dict.has_key(context.typenames, name)
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

fn add_boundary(
  context: Context,
  name: String,
  boundary: schema_1.Boundary,
) -> Context {
  Context(
    ..context,
    boundaries: dict.insert(context.boundaries, name, boundary),
    outputs: dict.insert(context.outputs, name, boundary.outputs),
  )
}

fn has_boundary(
  boundaries: dict.Dict(String, schema_1.Boundary),
  name: String,
) -> Bool {
  dict.has_key(boundaries, name)
}

fn get_boundary(
  boundaries: dict.Dict(String, schema_1.Boundary),
  name: String,
  diagnostic: Diagnostic,
) -> Result(schema_1.Boundary, Diagnostic) {
  case dict.get(boundaries, name) {
    Ok(boundary) -> Ok(boundary)
    Error(Nil) -> Error(diagnostic)
  }
}

fn add_inputs(
  parameters: List(Parameter),
) -> dict.Dict(String, schema_1.Input) {
  list.fold(parameters, dict.new(), add_input)
}

fn add_input(
  inputs: dict.Dict(String, schema_1.Input),
  parameter: Parameter,
) -> dict.Dict(String, schema_1.Input) {
  let input =
    schema_1.Input(typename: schema_1.Typename(name: parameter.typename.name))

  dict.insert(inputs, parameter.name, input)
}

fn add_outputs(returns: List(Return)) -> dict.Dict(String, schema_1.Output) {
  list.fold(returns, dict.new(), add_output)
}

fn add_output(
  outputs: dict.Dict(String, schema_1.Output),
  return: Return,
) -> dict.Dict(String, schema_1.Output) {
  let output =
    schema_1.Output(typename: schema_1.Typename(name: return.typename.name))

  dict.insert(outputs, return.name, output)
}

fn add_node(context: Context, name: String, node: schema_1.Node) -> Context {
  Context(
    ..context,
    nodes: dict.insert(context.nodes, name, node),
    outputs: dict.insert(context.outputs, name, node.outputs),
  )
}

fn has_node(nodes: dict.Dict(String, schema_1.Node), name: String) -> Bool {
  dict.has_key(nodes, name)
}

fn get_node(
  nodes: dict.Dict(String, schema_1.Node),
  name: String,
  diagnostic: Diagnostic,
) -> Result(schema_1.Node, Diagnostic) {
  case dict.get(nodes, name) {
    Ok(node) -> Ok(node)
    Error(Nil) -> Error(diagnostic)
  }
}

fn get_input(
  inputs: dict.Dict(String, schema_1.Input),
  name: String,
  path: List(String),
  span: source.Span,
) -> Result(schema_1.Input, Diagnostic) {
  case dict.get(inputs, name) {
    Ok(input) -> Ok(input)
    Error(Nil) -> Error(Diagnostic(kind: UnknownInput(path), span:))
  }
}

fn add_edge(context: Context, edge: Edge) -> Context {
  Context(..context, edges: set.insert(context.edges, edge.to.path))
}

fn has_edge(context: Context, path: Path) -> Bool {
  set.contains(context.edges, path)
}
