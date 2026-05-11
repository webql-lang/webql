import webql/compiler
import webql/compiler/diagnostic
import webql/compiler/lexer/diagnostic as lexer_diagnostic
import webql/compiler/lexer/token
import webql/compiler/parser/diagnostic as parser_diagnostic
import webql/compiler/reference
import webql/compiler/resolver/diagnostic as resolver_diagnostic
import webql/compiler/source
import webql/compiler/typechecker/diagnostic as typechecker_diagnostic
import webql/graph
import webql/introspection as schema

pub fn compile_resolves_module_test() {
  let operation_source = "-> out: Int {}"

  let c =
    compiler.new(
      schema.Schema(
        operators: [
          schema.Operator(name: "Types", parameters: [], returns: [
            schema.Return(name: "value", typename: "Int"),
          ]),
        ],
        typenames: [],
      ),
    )

  let assert Ok(module) = compiler.compile(c, operation_source)

  assert module
    == graph.Module(
      operation: graph.Operation(
        parameters: [],
        returns: [graph.Return(name: "out", typename: "Int")],
        nodes: [],
        edges: [],
      ),
    )
}

pub fn compile_materializes_node_binding_ports_test() {
  let operation_source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let c =
    compiler.new(
      schema.Schema(
        operators: [
          schema.Operator(
            name: "Math",
            parameters: [
              schema.Parameter(name: "r", typename: "Int"),
              schema.Parameter(name: "l", typename: "Int"),
            ],
            returns: [schema.Return(name: "value", typename: "Int")],
          ),
        ],
        typenames: [],
      ),
    )

  let assert Ok(graph.Module(operation:)) =
    compiler.compile(c, operation_source)

  assert operation.nodes == [graph.ExternalNode(name: "m", node: "Math")]

  assert operation.edges
    == [
      graph.Edge(
        from: graph.Output(path: ["in"]),
        to: graph.Input(path: ["m", "l"]),
      ),
      graph.Edge(
        from: graph.PrimitiveOutput(value: graph.IntPrimitive(1)),
        to: graph.Input(path: ["m", "r"]),
      ),
      graph.Edge(
        from: graph.Output(path: ["m", "value"]),
        to: graph.Input(path: ["out"]),
      ),
    ]
}

pub fn compile_materializes_definition_binding_ports_test() {
  let operation_source =
    "in: Int -> out: Int { SubOperation = in: String -> out: Int { ti = ToInt .in -> ti.value ti.value -> .out } m = Math so = SubOperation \"123\" -> so.in so.out -> m.l .in -> m.r m.value -> .out }"

  let c =
    compiler.new(
      schema.Schema(
        operators: [
          schema.Operator(
            name: "ToInt",
            parameters: [schema.Parameter(name: "value", typename: "String")],
            returns: [schema.Return(name: "value", typename: "Int")],
          ),
          schema.Operator(
            name: "Math",
            parameters: [
              schema.Parameter(name: "l", typename: "Int"),
              schema.Parameter(name: "r", typename: "Int"),
            ],
            returns: [schema.Return(name: "value", typename: "Int")],
          ),
        ],
        typenames: [],
      ),
    )

  let assert Ok(graph.Module(operation:)) =
    compiler.compile(c, operation_source)

  assert operation.nodes
    == [
      graph.ExternalNode(name: "m", node: "Math"),
      graph.InlineNode(
        name: "so",
        operation: graph.Operation(
          parameters: [graph.Parameter(name: "in", typename: "String")],
          returns: [graph.Return(name: "out", typename: "Int")],
          nodes: [graph.ExternalNode(name: "ti", node: "ToInt")],
          edges: [
            graph.Edge(
              from: graph.Output(path: ["in"]),
              to: graph.Input(path: ["ti", "value"]),
            ),
            graph.Edge(
              from: graph.Output(path: ["ti", "value"]),
              to: graph.Input(path: ["out"]),
            ),
          ],
        ),
      ),
    ]

  assert operation.edges
    == [
      graph.Edge(
        from: graph.PrimitiveOutput(value: graph.StringPrimitive("123")),
        to: graph.Input(path: ["so", "in"]),
      ),
      graph.Edge(
        from: graph.Output(path: ["so", "out"]),
        to: graph.Input(path: ["m", "l"]),
      ),
      graph.Edge(
        from: graph.Output(path: ["in"]),
        to: graph.Input(path: ["m", "r"]),
      ),
      graph.Edge(
        from: graph.Output(path: ["m", "value"]),
        to: graph.Input(path: ["out"]),
      ),
    ]
}

pub fn compile_ignores_unknown_node_port_registration_test() {
  let operation_source =
    "in: Int -> out: Int { m = Math .in -> m.l m.value -> .out }"

  let c =
    compiler.new(
      schema.Schema(
        operators: [
          schema.Operator(name: "Math", parameters: [], returns: [
            schema.Return(name: "value", typename: "Int"),
          ]),
        ],
        typenames: [],
      ),
    )

  let assert Error(error) = compiler.compile(c, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(
        resolver_diagnostic.UnknownInput(["m", "l"]),
      ),
      span: source.Span(start: 38, end: 41),
    )
}

pub fn compile_rejects_port_typename_mismatch_test() {
  let operation_source = "-> out: Int { m = Math m.value -> .out }"

  let c =
    compiler.new(
      schema.Schema(
        operators: [
          schema.Operator(
            name: "Math",
            parameters: [schema.Parameter(name: "unused", typename: "Int")],
            returns: [schema.Return(name: "value", typename: "String")],
          ),
        ],
        typenames: [],
      ),
    )

  let assert Error(error) = compiler.compile(c, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.TypecheckerDiagnostic(
        typechecker_diagnostic.TypeMismatch(
          expected: reference.Typename(0),
          found: reference.Typename(1),
        ),
      ),
      span: source.Span(start: 23, end: 38),
    )
}

pub fn compile_wraps_lexer_diagnostic_test() {
  let c = compiler.new(schema.Schema(operators: [], typenames: []))

  let assert Error(error) = compiler.compile(c, "!")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.LexerDiagnostic(lexer_diagnostic.IllegalToken),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_parser_diagnostic_test() {
  let c = compiler.new(schema.Schema(operators: [], typenames: []))

  let assert Error(error) = compiler.compile(c, "{")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ParserDiagnostic(parser_diagnostic.UnexpectedToken(
        token.LBrace,
      )),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_resolver_diagnostic_test() {
  let operation_source = "-> out: Int {}"
  let c = compiler.new(schema.Schema(operators: [], typenames: []))

  let assert Error(error) = compiler.compile(c, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(resolver_diagnostic.UnknownTypename(
        "Int",
      )),
      span: source.Span(start: 8, end: 11),
    )
}
