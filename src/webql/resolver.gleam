import gleam/bool
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import webql/parser
import webql/schema
import webql/source

/// A reference to a resolved graph component.
pub type Reference(a) {
  Reference(a)
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
    typename: Typename,
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
  Edge(from: From, to: To, reference: Reference(Int), span: source.Span)
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
  Input(
    path: Path,
    typename: Typename,
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
    path: Path,
    typename: Typename,
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
    typenames: dict.Dict(String, schema.Typename),
    parameters: dict.Dict(String, Parameter),
    returns: dict.Dict(String, Return),
    boundaries: dict.Dict(String, schema.Boundary),
    nodes: dict.Dict(String, schema.Node),
    outputs: dict.Dict(String, dict.Dict(String, schema.Output)),
    edges: set.Set(Path),
  )
}

/// Resolves a parsed WebQL block against a schema into a structural graph.
pub fn resolve(
  ast: parser.Ast,
  schema: schema.Schema,
) -> Result(Ast, Diagnostic) {
  let outputs =
    dict.merge(
      dict.map_values(schema.nodes, fn(_, node) { node.outputs }),
      dict.map_values(schema.boundaries, fn(_, boundary) { boundary.outputs }),
    )

  let context =
    Context(
      typenames: schema.typenames,
      parameters: dict.new(),
      returns: dict.new(),
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
  declarations: List(parser.Declaration),
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

fn resolve_parameter(declaration: parser.Declaration, context: Context) {
  let parser.Declaration(name:, typename:, span:) = declaration
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
      reference: Reference([name]),
      span:,
    )

  let context = add_parameter(context, parameter)

  Ok(#(parameter, context))
}

fn resolve_returns(declarations: List(parser.Declaration), context: Context) {
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

fn resolve_return(declaration: parser.Declaration, context: Context) {
  let parser.Declaration(name:, typename:, span:) = declaration
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
      reference: Reference([name]),
      span:,
    )

  let context = add_return(context, return)

  Ok(#(return, context))
}

fn resolve_supernodes(
  elements: List(parser.Element),
  schema: schema.Schema,
  context: Context,
) {
  case elements {
    [
      parser.Definition(name:, element: parser.Block(ast, ..), span:, ..),
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

    [parser.Definition(..), ..rest]
    | [parser.Edge(..), ..rest]
    | [parser.Value(..), ..rest]
    | [parser.Block(..), ..rest] -> resolve_supernodes(rest, schema, context)

    [] -> Ok(#([], context))
  }
}

fn resolve_supernode(
  name: String,
  ast: parser.Ast,
  span: source.Span,
  schema: schema.Schema,
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
    schema.Node(
      inputs: add_inputs(ast.parameters),
      outputs: add_outputs(ast.returns),
    )

  let context = add_node(context, name, node)
  Ok(#(Supernode(name:, ast:, reference: Reference(name), span:), context))
}

fn resolve_elements(elements: List(parser.Element), context: Context) {
  case elements {
    [parser.Definition(name:, element:, span:, ..), ..rest] ->
      resolve_definition(name, element, span, rest, context)

    // SYNTAX: `value -> input`
    [parser.Edge(from:, to:, span:), ..rest] -> {
      use #(edge, context) <- result.try(resolve_edge(from, to, span, context))
      use #(boundaries, nodes, edges) <- result.try(resolve_elements(
        rest,
        context,
      ))

      Ok(#(boundaries, nodes, [edge, ..edges]))
    }

    [parser.Value(value, span:), ..] -> resolve_value(value, span)

    [parser.Block(span:, ..), ..] ->
      Error(Diagnostic(kind: InvalidElement, span:))

    [] -> Ok(#([], [], []))
  }
}

fn resolve_definition(
  name: String,
  element: parser.Element,
  span: source.Span,
  rest: List(parser.Element),
  context: Context,
) {
  case element {
    // SYNTAX: `Inner = in: Int -> out: Int { ... }`
    parser.Block(..) -> resolve_elements(rest, context)

    // SYNTAX: `name = value -> Node`
    parser.Edge(from:, to:, ..) -> {
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
    parser.Value(value, ..) -> {
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

    parser.Definition(..) -> Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_value(value: parser.Value, span: source.Span) {
  case value {
    // SYNTAX: `Node`
    parser.Node(path, span:) ->
      Error(Diagnostic(kind: ExpectedNode(path), span:))

    parser.Int(..)
    | parser.Float(..)
    | parser.String(..)
    | parser.Port(..)
    | parser.Vertex(..) -> Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_boundary(
  name: String,
  from: parser.Value,
  to: parser.Value,
  span: source.Span,
  context: Context,
) {
  case to {
    // SYNTAX: `name = value -> Node`
    parser.Node([definition] as path, ..) -> {
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

      let context = add_boundary(context, name, declaration)
      Ok(#(
        Boundary(
          name:,
          from:,
          typename: resolve_typename(declaration.typename),
          owner: option.None,
          boundary: definition,
          reference: Reference(name),
          span:,
        ),
        context,
      ))
    }

    // SYNTAX: `name = value -> owner.Node`
    parser.Node([owner, member] as path, ..) -> {
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

      let context = add_boundary(context, name, declaration)

      Ok(#(
        Boundary(
          name:,
          from:,
          typename: resolve_typename(declaration.typename),
          owner: option.Some(owner),
          boundary: member,
          reference: Reference(name),
          span:,
        ),
        context,
      ))
    }

    parser.Node(path, span:) ->
      Error(Diagnostic(kind: UnknownBoundary(path), span:))

    parser.Port(name, span:) ->
      Error(Diagnostic(kind: ExpectedBoundary([name]), span:))

    parser.Vertex(path, span:) ->
      Error(Diagnostic(kind: ExpectedBoundary(path), span:))

    parser.Int(..) | parser.Float(..) | parser.String(..) ->
      Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_node(
  name: String,
  value: parser.Value,
  span: source.Span,
  context: Context,
) {
  case value {
    // SYNTAX: `name = Node`
    parser.Node([definition] as path, ..) -> {
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

      Ok(#(
        Node(
          name:,
          owner: option.None,
          node: definition,
          reference: Reference(name),
          span:,
        ),
        add_node(context, name, declaration),
      ))
    }

    // SYNTAX: `name = owner.Node`
    parser.Node([owner, member] as path, ..) -> {
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

      Ok(#(
        Node(
          name:,
          owner: option.Some(owner),
          node: member,
          reference: Reference(name),
          span:,
        ),
        add_node(context, name, declaration),
      ))
    }

    parser.Node(path, span:) ->
      Error(Diagnostic(kind: UnknownNode(path), span:))

    parser.Int(..)
    | parser.Float(..)
    | parser.String(..)
    | parser.Port(..)
    | parser.Vertex(..) -> Error(Diagnostic(kind: InvalidElement, span:))
  }
}

fn resolve_edge(
  from: parser.Value,
  to: parser.Value,
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
    Edge(from:, to:, reference: Reference(set.size(context.edges)), span:)

  Ok(#(edge, add_edge(context, edge)))
}

fn resolve_from(value: parser.Value, context: Context) {
  case value {
    // SYNTAX: `1`
    parser.Int(value, span:) -> {
      use <- bool.guard(
        when: !has_typename(context, "Int"),
        return: Error(Diagnostic(kind: UnknownTypename("Int"), span:)),
      )

      Ok(Literal(value: Int(value, span:), span:))
    }

    // SYNTAX: `1.23`
    parser.Float(value, span:) -> {
      use <- bool.guard(
        when: !has_typename(context, "Float"),
        return: Error(Diagnostic(kind: UnknownTypename("Float"), span:)),
      )

      Ok(Literal(value: Float(value, span:), span:))
    }

    // SYNTAX: `"value"`
    parser.String(value, span:) -> {
      use <- bool.guard(
        when: !has_typename(context, "String"),
        return: Error(Diagnostic(kind: UnknownTypename("String"), span:)),
      )

      Ok(Literal(value: String(value, span:), span:))
    }

    // SYNTAX: `.parameter`
    parser.Port(name, span:) -> {
      let reference = [name]
      use <- bool.guard(
        when: !has_parameter(context, name) && !has_return(context, name),
        return: Error(Diagnostic(kind: UnknownOutput(reference), span:)),
      )

      use parameter <- result.try(get_parameter(
        context.parameters,
        name,
        Diagnostic(kind: ExpectedOutput, span:),
      ))

      Ok(Output(
        path: Port(name),
        typename: parameter.typename,
        reference: Reference(reference),
        span:,
      ))
    }

    // SYNTAX: `owner.member`
    parser.Vertex([owner, member], span:) -> {
      resolve_output(context, owner, member, span)
    }

    // SYNTAX: `value`
    parser.Vertex([_value], span:) ->
      Error(Diagnostic(kind: ExpectedOutput, span:))

    parser.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownOutput(path), span:))

    // SYNTAX: `Node`
    parser.Node(path, span:) ->
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

  use outputs <- result.try(get_outputs(
    context.outputs,
    owner,
    Diagnostic(kind: UnknownDefinition(owner), span:),
  ))

  use output <- result.try(get_output(
    outputs,
    name,
    Diagnostic(kind: UnknownOutput(path), span:),
  ))

  Ok(Output(
    path: Vertex(owner:, name:),
    typename: resolve_typename(output.typename),
    reference: Reference(path),
    span:,
  ))
}

fn resolve_to(value: parser.Value, context: Context) {
  case value {
    // SYNTAX: `.return`
    parser.Port(name, span:) -> {
      let reference = [name]
      use <- bool.guard(
        when: !has_parameter(context, name) && !has_return(context, name),
        return: Error(Diagnostic(kind: UnknownInput(reference), span:)),
      )

      use return <- result.try(get_return(
        context.returns,
        name,
        Diagnostic(kind: ExpectedInput, span:),
      ))

      Ok(Input(
        path: Port(name),
        typename: return.typename,
        reference: Reference(reference),
        span:,
      ))
    }

    // SYNTAX: `owner.input`
    parser.Vertex([owner, member], span:) -> {
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

      use input <- result.try(get_input(
        node.inputs,
        member,
        Diagnostic(kind: UnknownInput(reference), span:),
      ))

      Ok(Input(
        path: Vertex(owner:, name: member),
        typename: resolve_typename(input.typename),
        reference: Reference(reference),
        span:,
      ))
    }

    // SYNTAX: `value`
    parser.Vertex([_], span:) -> Error(Diagnostic(kind: ExpectedInput, span:))

    parser.Vertex(path, span:) ->
      Error(Diagnostic(kind: UnknownInput(path), span:))

    parser.Node(span:, ..) -> Error(Diagnostic(kind: ExpectedDefinition, span:))

    parser.Int(..) | parser.Float(..) | parser.String(..) ->
      Error(Diagnostic(kind: ExpectedInput, span: value.span))
  }
}

fn resolve_typename(typename: schema.Typename) -> Typename {
  Typename(typename.name)
}

fn has_typename(context: Context, name: String) -> Bool {
  dict.has_key(context.typenames, name)
}

fn add_parameter(context: Context, parameter: Parameter) -> Context {
  Context(
    ..context,
    parameters: dict.insert(context.parameters, parameter.name, parameter),
  )
}

fn has_parameter(context: Context, name: String) -> Bool {
  dict.has_key(context.parameters, name)
}

fn get_parameter(
  parameters: dict.Dict(String, Parameter),
  name: String,
  diagnostic: Diagnostic,
) -> Result(Parameter, Diagnostic) {
  case dict.get(parameters, name) {
    Ok(parameter) -> Ok(parameter)
    Error(Nil) -> Error(diagnostic)
  }
}

fn add_return(context: Context, return: Return) -> Context {
  Context(..context, returns: dict.insert(context.returns, return.name, return))
}

fn has_return(context: Context, name: String) -> Bool {
  dict.has_key(context.returns, name)
}

fn get_return(
  returns: dict.Dict(String, Return),
  name: String,
  diagnostic: Diagnostic,
) -> Result(Return, Diagnostic) {
  case dict.get(returns, name) {
    Ok(return) -> Ok(return)
    Error(Nil) -> Error(diagnostic)
  }
}

fn add_boundary(
  context: Context,
  name: String,
  boundary: schema.Boundary,
) -> Context {
  Context(
    ..context,
    boundaries: dict.insert(context.boundaries, name, boundary),
    outputs: dict.insert(context.outputs, name, boundary.outputs),
  )
}

fn has_boundary(
  boundaries: dict.Dict(String, schema.Boundary),
  name: String,
) -> Bool {
  dict.has_key(boundaries, name)
}

fn get_boundary(
  boundaries: dict.Dict(String, schema.Boundary),
  name: String,
  diagnostic: Diagnostic,
) -> Result(schema.Boundary, Diagnostic) {
  case dict.get(boundaries, name) {
    Ok(boundary) -> Ok(boundary)
    Error(Nil) -> Error(diagnostic)
  }
}

fn add_inputs(parameters: List(Parameter)) -> dict.Dict(String, schema.Input) {
  list.fold(parameters, dict.new(), add_input)
}

fn add_input(
  inputs: dict.Dict(String, schema.Input),
  parameter: Parameter,
) -> dict.Dict(String, schema.Input) {
  let input =
    schema.Input(typename: schema.Typename(name: parameter.typename.name))

  dict.insert(inputs, parameter.name, input)
}

fn get_input(
  inputs: dict.Dict(String, schema.Input),
  name: String,
  diagnostic: Diagnostic,
) -> Result(schema.Input, Diagnostic) {
  case dict.get(inputs, name) {
    Ok(input) -> Ok(input)
    Error(Nil) -> Error(diagnostic)
  }
}

fn add_outputs(returns: List(Return)) -> dict.Dict(String, schema.Output) {
  list.fold(returns, dict.new(), add_output)
}

fn add_output(
  outputs: dict.Dict(String, schema.Output),
  return: Return,
) -> dict.Dict(String, schema.Output) {
  let output =
    schema.Output(typename: schema.Typename(name: return.typename.name))

  dict.insert(outputs, return.name, output)
}

fn get_outputs(
  outputs: dict.Dict(String, dict.Dict(String, schema.Output)),
  owner: String,
  diagnostic: Diagnostic,
) -> Result(dict.Dict(String, schema.Output), Diagnostic) {
  case dict.get(outputs, owner) {
    Ok(outputs) -> Ok(outputs)
    Error(Nil) -> Error(diagnostic)
  }
}

fn get_output(
  outputs: dict.Dict(String, schema.Output),
  name: String,
  diagnostic: Diagnostic,
) -> Result(schema.Output, Diagnostic) {
  case dict.get(outputs, name) {
    Ok(output) -> Ok(output)
    Error(Nil) -> Error(diagnostic)
  }
}

fn add_node(context: Context, name: String, node: schema.Node) -> Context {
  Context(
    ..context,
    nodes: dict.insert(context.nodes, name, node),
    outputs: dict.insert(context.outputs, name, node.outputs),
  )
}

fn has_node(nodes: dict.Dict(String, schema.Node), name: String) -> Bool {
  dict.has_key(nodes, name)
}

fn get_node(
  nodes: dict.Dict(String, schema.Node),
  name: String,
  diagnostic: Diagnostic,
) -> Result(schema.Node, Diagnostic) {
  case dict.get(nodes, name) {
    Ok(node) -> Ok(node)
    Error(Nil) -> Error(diagnostic)
  }
}

fn add_edge(context: Context, edge: Edge) -> Context {
  Context(..context, edges: set.insert(context.edges, edge.to.path))
}

fn has_edge(context: Context, path: Path) -> Bool {
  set.contains(context.edges, path)
}
