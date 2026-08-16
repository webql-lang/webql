import gleam/dict
import gleam/option
import webql/lexer
import webql/parser
import webql/resolver
import webql/schema
import webql/source

pub fn resolve_graph_test() {
  let source =
    "token: Uuid, l: Int, r: Int -> out: Int { service = .token -> Service add = service.Add .l -> add.l .r -> add.r add.out -> .out }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(resolver.Ast(
    parameters: [
      resolver.Parameter(
        name: "token",
        typename: resolver.Typename("Uuid"),
        reference: resolver.Reference(_),
        ..,
      ),
      resolver.Parameter(name: "l", ..),
      resolver.Parameter(name: "r", ..),
    ],
    returns: [
      resolver.Return(
        name: "out",
        typename: resolver.Typename("Int"),
        reference: resolver.Reference(_),
        ..,
      ),
    ],
    boundaries: [
      resolver.Boundary(
        name: "service",
        from: resolver.Output(path: resolver.Port("token"), ..),
        owner: option.None,
        boundary: "Service",
        reference: resolver.Reference(_),
        ..,
      ),
    ],
    nodes: [
      resolver.Node(
        name: "add",
        owner: option.Some("service"),
        node: "Add",
        reference: resolver.Reference(_),
        ..,
      ),
    ],
    edges: [
      resolver.Edge(
        from: resolver.Output(path: resolver.Port("l"), ..),
        to: resolver.Input(path: resolver.Vertex("add", "l"), ..),
        reference: resolver.Reference(_),
        ..,
      ),
      resolver.Edge(
        from: resolver.Output(path: resolver.Port("r"), ..),
        to: resolver.Input(path: resolver.Vertex("add", "r"), ..),
        reference: resolver.Reference(_),
        ..,
      ),
      resolver.Edge(
        from: resolver.Output(path: resolver.Vertex("add", "out"), ..),
        to: resolver.Input(path: resolver.Port("out"), ..),
        reference: resolver.Reference(_),
        ..,
      ),
    ],
    ..,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.from_list([
          #(
            "Service",
            schema.Boundary(
              typename: schema.Typename(name: "Uuid"),
              boundaries: dict.new(),
              nodes: dict.from_list([
                #(
                  "Add",
                  schema.Node(
                    inputs: dict.from_list([
                      #(
                        "l",
                        schema.Input(typename: schema.Typename(name: "Int")),
                      ),
                      #(
                        "r",
                        schema.Input(typename: schema.Typename(name: "Int")),
                      ),
                    ]),
                    outputs: dict.from_list([
                      #(
                        "out",
                        schema.Output(typename: schema.Typename(name: "Int")),
                      ),
                    ]),
                  ),
                ),
              ]),
              outputs: dict.new(),
            ),
          ),
        ]),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Uuid", schema.Typename(name: "Uuid")),
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )
}

pub fn resolve_nested_boundaries_test() {
  let source =
    "value: Int -> { a = .value -> NodeA b = .value -> a.NodeB c = b.NodeC }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(resolver.Ast(
    boundaries: [
      resolver.Boundary(name: "a", owner: option.None, boundary: "NodeA", ..),
      resolver.Boundary(
        name: "b",
        owner: option.Some("a"),
        boundary: "NodeB",
        ..,
      ),
    ],
    nodes: [
      resolver.Node(name: "c", owner: option.Some("b"), node: "NodeC", ..),
    ],
    ..,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.from_list([
          #(
            "NodeA",
            schema.Boundary(
              typename: schema.Typename(name: "Int"),
              boundaries: dict.from_list([
                #(
                  "NodeB",
                  schema.Boundary(
                    typename: schema.Typename(name: "Int"),
                    boundaries: dict.new(),
                    nodes: dict.from_list([
                      #(
                        "NodeC",
                        schema.Node(inputs: dict.new(), outputs: dict.new()),
                      ),
                    ]),
                    outputs: dict.new(),
                  ),
                ),
              ]),
              nodes: dict.new(),
              outputs: dict.new(),
            ),
          ),
        ]),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )
}

pub fn resolve_forward_supernode_test() {
  let source = "-> { inner = Inner Inner = -> { node = Thing } }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(resolver.Ast(
    supernodes: [
      resolver.Supernode(
        name: "Inner",
        ast: resolver.Ast(
          nodes: [resolver.Node(name: "node", node: "Thing", ..)],
          ..,
        ),
        reference: resolver.Reference(_),
        ..,
      ),
    ],
    nodes: [
      resolver.Node(
        name: "inner",
        owner: option.None,
        node: "Inner",
        reference: resolver.Reference(_),
        ..,
      ),
    ],
    ..,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.from_list([
          #("Thing", schema.Node(inputs: dict.new(), outputs: dict.new())),
        ]),
        typenames: dict.new(),
      ),
    )
}

pub fn resolve_literals_test() {
  let source =
    "-> integer: Int, decimal: Float, text: String { 1 -> .integer 1.5 -> .decimal \"x\" -> .text }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(resolver.Ast(
    edges: [
      resolver.Edge(
        from: resolver.Literal(value: resolver.Int(1, ..), ..),
        to: resolver.Input(path: resolver.Port("integer"), ..),
        ..,
      ),
      resolver.Edge(
        from: resolver.Literal(value: resolver.Float(1.5, ..), ..),
        to: resolver.Input(path: resolver.Port("decimal"), ..),
        ..,
      ),
      resolver.Edge(
        from: resolver.Literal(value: resolver.String("x", ..), ..),
        to: resolver.Input(path: resolver.Port("text"), ..),
        ..,
      ),
    ],
    ..,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
          #("Float", schema.Typename(name: "Float")),
          #("String", schema.Typename(name: "String")),
        ]),
      ),
    )
}

pub fn paths_are_directional_test() {
  let source =
    "value: Int -> value: Int { node = Thing .value -> node.value node.value -> .value }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(resolver.Ast(
    parameters: [resolver.Parameter(reference: resolver.Reference(_), ..)],
    returns: [resolver.Return(reference: resolver.Reference(_), ..)],
    edges: [
      resolver.Edge(
        from: resolver.Output(path: resolver.Port("value"), ..),
        to: resolver.Input(path: resolver.Vertex("node", "value"), ..),
        ..,
      ),
      resolver.Edge(
        from: resolver.Output(path: resolver.Vertex("node", "value"), ..),
        to: resolver.Input(path: resolver.Port("value"), ..),
        ..,
      ),
    ],
    ..,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.from_list([
          #(
            "Thing",
            schema.Node(
              inputs: dict.from_list([
                #("value", schema.Input(typename: schema.Typename(name: "Int"))),
              ]),
              outputs: dict.from_list([
                #(
                  "value",
                  schema.Output(typename: schema.Typename(name: "Int")),
                ),
              ]),
            ),
          ),
        ]),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )
}

pub fn unknown_typename_diagnostic_test() {
  let source = "value: Missing -> {}"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownTypename("Missing"),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.new(),
      ),
    )

  assert source.slice(source, span) == "value: Missing"
}

pub fn unknown_boundary_diagnostic_test() {
  let source = "value: Int -> { item = .value -> Missing }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownBoundary(["Missing"]),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "Missing"
}

pub fn unknown_node_diagnostic_test() {
  let source = "-> { node = Missing }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownNode(["Missing"]),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.new(),
      ),
    )

  assert source.slice(source, span) == "Missing"
}

pub fn unknown_definition_diagnostic_test() {
  let source = "-> { value = missing.Add }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownDefinition("missing"),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.new(),
      ),
    )

  assert source.slice(source, span) == "missing.Add"
}

pub fn unknown_input_diagnostic_test() {
  let source = "-> { node = Thing 1 -> node.missing }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownInput(["node", "missing"]),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.from_list([
          #("Thing", schema.Node(inputs: dict.new(), outputs: dict.new())),
        ]),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "node.missing"
}

pub fn unknown_output_diagnostic_test() {
  let source = "-> out: Int { node = Thing node.missing -> .out }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.UnknownOutput(["node", "missing"]),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.from_list([
          #("Thing", schema.Node(inputs: dict.new(), outputs: dict.new())),
        ]),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "node.missing"
}

pub fn duplicate_parameter_diagnostic_test() {
  let source = "value: Int, value: Int -> {}"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateParameter("value"),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "value: Int"
}

pub fn duplicate_return_diagnostic_test() {
  let source = "-> value: Int, value: Int {}"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateReturn("value"),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "value: Int"
}

pub fn duplicate_definition_diagnostic_test() {
  let source = "-> { math = Math math = Math }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateDefinition("math"),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.from_list([
          #("Math", schema.Node(inputs: dict.new(), outputs: dict.new())),
        ]),
        typenames: dict.new(),
      ),
    )

  assert source.slice(source, span) == "math = Math"
}

pub fn duplicate_input_diagnostic_test() {
  let source = "-> { node = Thing 1 -> node.in 2 -> node.in }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.DuplicateInput(resolver.Vertex("node", "in")),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.from_list([
          #(
            "Thing",
            schema.Node(
              inputs: dict.from_list([
                #("in", schema.Input(typename: schema.Typename(name: "Int"))),
              ]),
              outputs: dict.new(),
            ),
          ),
        ]),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "node.in"
}

pub fn expected_boundary_diagnostic_test() {
  let source = "value: Int -> { item = .value -> Math }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.ExpectedBoundary(["Math"]),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.from_list([
          #("Math", schema.Node(inputs: dict.new(), outputs: dict.new())),
        ]),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "Math"
}

pub fn expected_node_diagnostic_test() {
  let source = "value: Int -> { a = .value -> NodeA node = a.NodeB }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(
    kind: resolver.ExpectedNode(["a", "NodeB"]),
    span:,
  )) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.from_list([
          #(
            "NodeA",
            schema.Boundary(
              typename: schema.Typename(name: "Int"),
              boundaries: dict.from_list([
                #(
                  "NodeB",
                  schema.Boundary(
                    typename: schema.Typename(name: "Int"),
                    boundaries: dict.new(),
                    nodes: dict.new(),
                    outputs: dict.new(),
                  ),
                ),
              ]),
              nodes: dict.new(),
              outputs: dict.new(),
            ),
          ),
        ]),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == "a.NodeB"
}

pub fn expected_input_diagnostic_test() {
  let source = "in: Int -> { 1 -> .in }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(kind: resolver.ExpectedInput, span:)) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == ".in"
}

pub fn expected_output_diagnostic_test() {
  let source = "-> out: Int { .out -> .out }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(kind: resolver.ExpectedOutput, span:)) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Int", schema.Typename(name: "Int")),
        ]),
      ),
    )

  assert source.slice(source, span) == ".out"
}

pub fn expected_definition_diagnostic_test() {
  let source = "token: Uuid -> { .token -> Service }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(kind: resolver.ExpectedDefinition, span:)) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.from_list([
          #(
            "Service",
            schema.Boundary(
              typename: schema.Typename(name: "Uuid"),
              boundaries: dict.new(),
              nodes: dict.new(),
              outputs: dict.new(),
            ),
          ),
        ]),
        nodes: dict.new(),
        typenames: dict.from_list([
          #("Uuid", schema.Typename(name: "Uuid")),
        ]),
      ),
    )

  assert source.slice(source, span) == "Service"
}

pub fn invalid_element_diagnostic_test() {
  let source = "-> { value = 1 }"
  let assert Ok(parsed) = parser.parse(source, lexer.lex_recovering(source))
  let assert Error(resolver.Diagnostic(kind: resolver.InvalidElement, span:)) =
    resolver.resolve(
      parsed,
      schema.Schema(
        boundaries: dict.new(),
        nodes: dict.new(),
        typenames: dict.new(),
      ),
    )

  assert source.slice(source, span) == "value = 1"
}
