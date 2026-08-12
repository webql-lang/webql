import webql/compiler/lexer
import webql/compiler/parser_1
import webql/compiler/resolver_1
import webql/compiler/source

pub fn resolve_services_test() {
  let code =
    "token: Uuid, l: Int, r: Int -> out: Int { service = .token -> Service add = service.Add .l -> add.l .r -> add.r add.out -> .out }"
  let assert Ok(ast) = resolve(code)

  let assert resolver_1.Ast(
    parameters: [
      resolver_1.Parameter(
        name: "token",
        port: resolver_1.Port("Uuid"),
        reference: resolver_1.Labeled(["token"]),
        span: token_parameter_span,
      ),
      resolver_1.Parameter(
        name: "l",
        port: resolver_1.Port("Int"),
        reference: resolver_1.Labeled(["l"]),
        ..,
      ),
      resolver_1.Parameter(
        name: "r",
        port: resolver_1.Port("Int"),
        reference: resolver_1.Labeled(["r"]),
        ..,
      ),
    ],
    returns: [
      resolver_1.Return(
        name: "out",
        port: resolver_1.Port("Int"),
        reference: resolver_1.Labeled(["out"]),
        span: return_span,
      ),
    ],
    boundaries: [
      resolver_1.Boundary(
        name: "service",
        from: resolver_1.Output(
          path: ["token"],
          reference: resolver_1.Labeled(["token"]),
          span: token_from_span,
        ),
        to: ["Service"],
        reference: resolver_1.Labeled("service"),
        span: service_span,
      ),
    ],
    nodes: [
      resolver_1.Node(
        name: "add",
        path: ["service", "Add"],
        reference: resolver_1.Labeled("add"),
        span: add_span,
      ),
    ],
    edges: [
      resolver_1.Edge(
        from: resolver_1.Output(
          path: ["l"],
          reference: resolver_1.Labeled(["l"]),
          ..,
        ),
        to: resolver_1.Input(
          path: ["add", "l"],
          reference: resolver_1.Labeled(["add", "l"]),
          ..,
        ),
        reference: resolver_1.Unlabeled(0),
        span: left_edge_span,
      ),
      resolver_1.Edge(
        from: resolver_1.Output(
          path: ["r"],
          reference: resolver_1.Labeled(["r"]),
          ..,
        ),
        to: resolver_1.Input(
          path: ["add", "r"],
          reference: resolver_1.Labeled(["add", "r"]),
          ..,
        ),
        reference: resolver_1.Unlabeled(1),
        ..,
      ),
      resolver_1.Edge(
        from: resolver_1.Output(
          path: ["add", "out"],
          reference: resolver_1.Labeled(["add", "out"]),
          ..,
        ),
        to: resolver_1.Input(
          path: ["out"],
          reference: resolver_1.Labeled(["out"]),
          ..,
        ),
        reference: resolver_1.Unlabeled(2),
        span: output_edge_span,
      ),
    ],
    span: ast_span,
  ) = ast

  assert source.slice(code, token_parameter_span) == "token: Uuid"
  assert source.slice(code, return_span) == "out: Int"
  assert source.slice(code, token_from_span) == ".token"
  assert source.slice(code, service_span) == "service = .token -> Service"
  assert source.slice(code, add_span) == "add = service.Add"
  assert source.slice(code, left_edge_span) == ".l -> add.l"
  assert source.slice(code, output_edge_span) == "add.out -> .out"
  assert source.slice(code, ast_span) == code
  assert resolve(code) == Ok(ast)
}

pub fn resolve_boundary_endpoints_test() {
  let code =
    "token: Uuid -> out: Int { service = .token -> Service 1 -> service.in service.out -> .out }"
  let assert Ok(resolver_1.Ast(
    boundaries: [
      resolver_1.Boundary(
        name: "service",
        from: resolver_1.Output(path: ["token"], ..),
        to: ["Service"],
        reference: resolver_1.Labeled("service"),
        ..,
      ),
    ],
    edges: [
      resolver_1.Edge(
        to: resolver_1.Input(path: ["service", "in"], ..),
        reference: resolver_1.Unlabeled(0),
        ..,
      ),
      resolver_1.Edge(
        from: resolver_1.Output(path: ["service", "out"], ..),
        reference: resolver_1.Unlabeled(1),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)
}

pub fn resolve_member_boundary_test() {
  let code =
    "token: Uuid -> { editor = .token -> Editor workflow = editor.id -> editor.Workflow }"
  let assert Ok(resolver_1.Ast(
    boundaries: [
      resolver_1.Boundary(
        name: "editor",
        from: resolver_1.Output(path: ["token"], ..),
        to: ["Editor"],
        reference: resolver_1.Labeled("editor"),
        ..,
      ),
      resolver_1.Boundary(
        name: "workflow",
        from: resolver_1.Output(path: ["editor", "id"], ..),
        to: ["editor", "Workflow"],
        reference: resolver_1.Labeled("workflow"),
        ..,
      ),
    ],
    edges: [],
    ..,
  )) = resolve(code)
}

pub fn resolve_literals_test() {
  let code =
    "-> integer: Int, decimal: Float, text: String { 1 -> .integer 1.5 -> .decimal \"x\" -> .text }"
  let assert Ok(resolver_1.Ast(
    returns: [
      resolver_1.Return(reference: resolver_1.Labeled(["integer"]), ..),
      resolver_1.Return(reference: resolver_1.Labeled(["decimal"]), ..),
      resolver_1.Return(reference: resolver_1.Labeled(["text"]), ..),
    ],
    edges: [
      resolver_1.Edge(
        from: resolver_1.Literal(
          value: resolver_1.Int(1, span: int_span),
          span: int_from_span,
        ),
        to: resolver_1.Input(
          path: ["integer"],
          reference: resolver_1.Labeled(["integer"]),
          ..,
        ),
        reference: resolver_1.Unlabeled(0),
        ..,
      ),
      resolver_1.Edge(
        from: resolver_1.Literal(
          value: resolver_1.Float(1.5, span: float_span),
          ..,
        ),
        to: resolver_1.Input(
          path: ["decimal"],
          reference: resolver_1.Labeled(["decimal"]),
          ..,
        ),
        reference: resolver_1.Unlabeled(1),
        ..,
      ),
      resolver_1.Edge(
        from: resolver_1.Literal(
          value: resolver_1.String("x", span: string_span),
          ..,
        ),
        to: resolver_1.Input(
          path: ["text"],
          reference: resolver_1.Labeled(["text"]),
          ..,
        ),
        reference: resolver_1.Unlabeled(2),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)

  assert int_span == int_from_span
  assert source.slice(code, int_span) == "1"
  assert source.slice(code, float_span) == "1.5"
  assert source.slice(code, string_span) == "\"x\""
}

pub fn resolve_supernode_test() {
  let code =
    "in: Int -> out: Int { Inner = value: Int -> result: Int { .value -> .result } inner = Inner .in -> inner.value inner.result -> .out }"
  let assert Ok(resolver_1.Ast(
    parameters: [
      resolver_1.Parameter(reference: resolver_1.Labeled(["in"]), ..),
    ],
    returns: [resolver_1.Return(reference: resolver_1.Labeled(["out"]), ..)],
    nodes: [
      resolver_1.Supernode(
        name: "inner",
        ast: resolver_1.Ast(
          parameters: [
            resolver_1.Parameter(reference: resolver_1.Labeled(["value"]), ..),
          ],
          returns: [
            resolver_1.Return(reference: resolver_1.Labeled(["result"]), ..),
          ],
          edges: [
            resolver_1.Edge(
              reference: resolver_1.Unlabeled(0),
              span: nested_edge_span,
              ..,
            ),
          ],
          span: nested_span,
          ..,
        ),
        reference: resolver_1.Labeled("inner"),
        span: node_span,
      ),
    ],
    edges: [
      resolver_1.Edge(
        from: resolver_1.Output(reference: resolver_1.Labeled(["in"]), ..),
        to: resolver_1.Input(
          path: ["inner", "value"],
          reference: resolver_1.Labeled(["inner", "value"]),
          ..,
        ),
        reference: resolver_1.Unlabeled(0),
        ..,
      ),
      resolver_1.Edge(
        from: resolver_1.Output(
          path: ["inner", "result"],
          reference: resolver_1.Labeled(["inner", "result"]),
          ..,
        ),
        to: resolver_1.Input(reference: resolver_1.Labeled(["out"]), ..),
        reference: resolver_1.Unlabeled(1),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)

  assert source.slice(code, nested_edge_span) == ".value -> .result"
  assert source.slice(code, nested_span)
    == "value: Int -> result: Int { .value -> .result }"
  assert source.slice(code, node_span) == "inner = Inner"
}

pub fn resolve_forward_supernode_reference_test() {
  let code = "-> { inner = Inner Inner = -> { node = Thing } }"
  let assert Ok(resolver_1.Ast(
    nodes: [
      resolver_1.Supernode(
        name: "inner",
        ast: resolver_1.Ast(
          nodes: [resolver_1.Node(name: "node", path: ["Thing"], ..)],
          ..,
        ),
        reference: resolver_1.Labeled("inner"),
        span: instance_span,
      ),
    ],
    ..,
  )) = resolve(code)

  assert source.slice(code, instance_span) == "inner = Inner"
}

pub fn unused_supernode_definitions_are_omitted_test() {
  let code = "-> { Unused = -> {} node = Thing }"
  let assert Ok(resolver_1.Ast(
    boundaries: [],
    nodes: [resolver_1.Node(name: "node", path: ["Thing"], ..)],
    ..,
  )) = resolve(code)
}

pub fn supernode_definition_can_be_instantiated_twice_test() {
  let code = "-> { first = Shared Shared = -> {} second = Shared }"
  let assert Ok(resolver_1.Ast(
    nodes: [
      resolver_1.Supernode(
        name: "first",
        ast: first,
        reference: resolver_1.Labeled("first"),
        ..,
      ),
      resolver_1.Supernode(
        name: "second",
        ast: second,
        reference: resolver_1.Labeled("second"),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)

  assert first == second
}

pub fn edge_definition_requires_node_diagnostic_test() {
  assert_diagnostic(
    "in: Int -> out: Int { route = .in -> .out }",
    resolver_1.ExpectedNode(["out"]),
    ".out",
  )

  assert_diagnostic(
    "in: Int -> { node = Thing route = .in -> node.in }",
    resolver_1.ExpectedNode(["node", "in"]),
    "node.in",
  )
}

pub fn resolve_external_nodes_structurally_test() {
  let code =
    "value: Missing -> out: Other { node = Unknown child = node.Anything .value -> child.anything child.result -> .out }"
  let assert Ok(resolver_1.Ast(
    parameters: [resolver_1.Parameter(port: resolver_1.Port("Missing"), ..)],
    returns: [resolver_1.Return(port: resolver_1.Port("Other"), ..)],
    nodes: [
      resolver_1.Node(name: "node", path: ["Unknown"], ..),
      resolver_1.Node(name: "child", path: ["node", "Anything"], ..),
    ],
    edges: [
      resolver_1.Edge(to: resolver_1.Input(path: ["child", "anything"], ..), ..),
      resolver_1.Edge(
        from: resolver_1.Output(path: ["child", "result"], ..),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)
}

pub fn output_references_are_reused_test() {
  let code =
    "-> left: Int, right: Int { node = Thing node.out -> .left node.out -> .right }"
  let assert Ok(resolver_1.Ast(
    edges: [
      resolver_1.Edge(
        from: resolver_1.Output(
          path: ["node", "out"],
          reference: first,
          span: first_span,
        ),
        ..,
      ),
      resolver_1.Edge(
        from: resolver_1.Output(
          path: ["node", "out"],
          reference: second,
          span: second_span,
        ),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)

  assert first == second
  assert first_span != second_span
  assert source.slice(code, first_span) == "node.out"
  assert source.slice(code, second_span) == "node.out"
}

pub fn interface_names_are_directional_test() {
  let code = "value: Int -> value: Int { .value -> .value }"
  let assert Ok(resolver_1.Ast(
    parameters: [
      resolver_1.Parameter(reference: resolver_1.Labeled(["value"]), ..),
    ],
    returns: [resolver_1.Return(reference: resolver_1.Labeled(["value"]), ..)],
    edges: [
      resolver_1.Edge(
        from: resolver_1.Output(reference: resolver_1.Labeled(["value"]), ..),
        to: resolver_1.Input(reference: resolver_1.Labeled(["value"]), ..),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)
}

pub fn node_members_are_directional_test() {
  let code = "-> out: Int { node = Thing 1 -> node.value node.value -> .out }"
  let assert Ok(resolver_1.Ast(
    edges: [
      resolver_1.Edge(
        to: resolver_1.Input(
          path: ["node", "value"],
          reference: resolver_1.Labeled(["node", "value"]),
          ..,
        ),
        ..,
      ),
      resolver_1.Edge(
        from: resolver_1.Output(
          path: ["node", "value"],
          reference: resolver_1.Labeled(["node", "value"]),
          ..,
        ),
        ..,
      ),
    ],
    ..,
  )) = resolve(code)
}

pub fn unknown_definition_diagnostic_test() {
  assert_diagnostic(
    "-> { value = missing.Add }",
    resolver_1.UnknownDefinition("missing"),
    "missing.Add",
  )

  assert_diagnostic(
    "-> out: Int { missing.out -> .out }",
    resolver_1.UnknownDefinition("missing"),
    "missing.out",
  )
}

pub fn unknown_input_diagnostic_test() {
  assert_diagnostic(
    "-> out: Int { 1 -> .missing }",
    resolver_1.UnknownInput(["missing"]),
    ".missing",
  )
}

pub fn unknown_output_diagnostic_test() {
  assert_diagnostic(
    "-> out: Int { .missing -> .out }",
    resolver_1.UnknownOutput(["missing"]),
    ".missing",
  )

  assert_diagnostic(
    "-> { item = .missing -> missing.Node }",
    resolver_1.UnknownOutput(["missing"]),
    ".missing",
  )
}

pub fn duplicate_parameter_diagnostic_test() {
  assert_diagnostic(
    "value:Int, value: Int -> {}",
    resolver_1.DuplicateParameter("value"),
    "value: Int",
  )
}

pub fn duplicate_return_diagnostic_test() {
  assert_diagnostic(
    "-> value:Int, value: Int {}",
    resolver_1.DuplicateReturn("value"),
    "value: Int",
  )
}

pub fn duplicate_definition_diagnostic_test() {
  assert_diagnostic(
    "-> { math=Math math = Math }",
    resolver_1.DuplicateDefinition("math"),
    "math = Math",
  )

  assert_diagnostic(
    "token: Uuid -> { item = Math item = .token -> Service }",
    resolver_1.DuplicateDefinition("item"),
    "item = .token -> Service",
  )

  assert_diagnostic(
    "token: Uuid -> { item = .token -> Service item = Math }",
    resolver_1.DuplicateDefinition("item"),
    "item = Math",
  )

  assert_diagnostic(
    "token: Uuid -> { item = .token -> Service item = .token -> Other }",
    resolver_1.DuplicateDefinition("item"),
    "item = .token -> Other",
  )

  assert_diagnostic(
    "-> { Inner = -> {} Inner = -> {} }",
    resolver_1.DuplicateDefinition("Inner"),
    "Inner = -> {}",
  )

  assert_diagnostic(
    "-> { item = Math item = missing.Node }",
    resolver_1.DuplicateDefinition("item"),
    "item = missing.Node",
  )

  assert_diagnostic(
    "-> { item = Math item = .missing -> Service }",
    resolver_1.DuplicateDefinition("item"),
    "item = .missing -> Service",
  )

  assert_diagnostic(
    "-> { Inner = -> {} Inner = -> { .missing -> .also } }",
    resolver_1.DuplicateDefinition("Inner"),
    "Inner = -> { .missing -> .also }",
  )
}

pub fn duplicate_input_diagnostic_test() {
  assert_diagnostic(
    "-> { node = Thing 1 -> node.in 2 -> node.in }",
    resolver_1.DuplicateInput(["node", "in"]),
    "node.in",
  )
}

pub fn boundary_requires_definition_diagnostic_test() {
  assert_diagnostic(
    "token: Uuid -> { .token -> Service }",
    resolver_1.ExpectedDefinition,
    "Service",
  )
}

pub fn expected_input_diagnostic_test() {
  assert_diagnostic("in: Int -> { 1 -> .in }", resolver_1.ExpectedInput, ".in")

  assert_diagnostic(
    "-> out: Int { foo = Math 1 -> foo }",
    resolver_1.ExpectedInput,
    "foo",
  )
}

pub fn expected_output_diagnostic_test() {
  assert_diagnostic(
    "-> out: Int { .out -> .out }",
    resolver_1.ExpectedOutput,
    ".out",
  )

  assert_diagnostic(
    "foo: Int -> out: Int { node = Math node -> .out }",
    resolver_1.ExpectedOutput,
    "node",
  )
}

pub fn invalid_definition_diagnostic_test() {
  assert_diagnostic("-> { value = 1 }", resolver_1.InvalidElement, "value = 1")
  assert_diagnostic(
    "in: Int -> { value = .in }",
    resolver_1.InvalidElement,
    "value = .in",
  )
  assert_diagnostic(
    "-> { math = Math value = math.out }",
    resolver_1.InvalidElement,
    "value = math.out",
  )
}

pub fn invalid_element_diagnostic_test() {
  let value_span = source.Span(start: 5, end: 6)
  let ast =
    parser_1.Ast(
      parameters: [],
      returns: [],
      elements: [
        parser_1.Value(parser_1.Int(1, span: value_span), span: value_span),
      ],
      span: source.Span(start: 0, end: 7),
    )

  assert resolver_1.resolve(ast)
    == Error(resolver_1.Diagnostic(
      kind: resolver_1.InvalidElement,
      span: value_span,
    ))
}

fn assert_diagnostic(
  code: String,
  kind: resolver_1.DiagnosticKind,
  selected: String,
) {
  let assert Error(resolver_1.Diagnostic(kind: found, span:)) = resolve(code)

  assert found == kind
  assert source.slice(code, span) == selected
}

fn resolve(code: String) {
  let assert Ok(tokens) = lexer.lex(code)
  let assert Ok(ast) = parser_1.parse(code, tokens)
  resolver_1.resolve(ast)
}
