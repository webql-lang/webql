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
        operations: [
          schema.Operation(name: "Types", inputs: [], outputs: [
            schema.Output(name: "value", port: "Int"),
          ]),
        ],
        ports: [],
      ),
    )

  let assert Ok(document) = compiler.compile(c, operation_source)

  assert document
    == graph.Graph(
      parameters: [],
      returns: [graph.Return(name: "out", port: "Int")],
      nodes: [],
      edges: [],
    )
}

pub fn compile_materializes_node_binding_ports_test() {
  let operation_source =
    "in: Int -> out: Int { m = Math .in -> m.l 1 -> m.r m.value -> .out }"

  let c =
    compiler.new(
      schema.Schema(
        operations: [
          schema.Operation(
            name: "Math",
            inputs: [
              schema.Input(name: "r", port: "Int"),
              schema.Input(name: "l", port: "Int"),
            ],
            outputs: [schema.Output(name: "value", port: "Int")],
          ),
        ],
        ports: [],
      ),
    )

  let assert Ok(graph) = compiler.compile(c, operation_source)

  assert graph.nodes == [graph.Node(name: "m", node: "Math")]

  assert graph.edges
    == [
      graph.Edge(
        source: graph.Output(path: ["in"]),
        target: graph.Input(path: ["m", "l"]),
      ),
      graph.Edge(
        source: graph.Static(value: graph.Int(1)),
        target: graph.Input(path: ["m", "r"]),
      ),
      graph.Edge(
        source: graph.Output(path: ["m", "value"]),
        target: graph.Input(path: ["out"]),
      ),
    ]
}

pub fn compile_materializes_definition_binding_ports_test() {
  let operation_source =
    "in: Int -> out: Int { SubOperation = in: String -> out: Int { ti = ToInt .in -> ti.value ti.value -> .out } m = Math so = SubOperation \"123\" -> so.in so.out -> m.l .in -> m.r m.value -> .out }"

  let c =
    compiler.new(
      schema.Schema(
        operations: [
          schema.Operation(
            name: "ToInt",
            inputs: [schema.Input(name: "value", port: "String")],
            outputs: [schema.Output(name: "value", port: "Int")],
          ),
          schema.Operation(
            name: "Math",
            inputs: [
              schema.Input(name: "l", port: "Int"),
              schema.Input(name: "r", port: "Int"),
            ],
            outputs: [schema.Output(name: "value", port: "Int")],
          ),
        ],
        ports: [],
      ),
    )

  let assert Ok(graph) = compiler.compile(c, operation_source)

  assert graph.nodes
    == [
      graph.Node(name: "m", node: "Math"),
      graph.Supernode(
        name: "so",
        graph: graph.Graph(
          parameters: [graph.Parameter(name: "in", port: "String")],
          returns: [graph.Return(name: "out", port: "Int")],
          nodes: [graph.Node(name: "ti", node: "ToInt")],
          edges: [
            graph.Edge(
              source: graph.Output(path: ["in"]),
              target: graph.Input(path: ["ti", "value"]),
            ),
            graph.Edge(
              source: graph.Output(path: ["ti", "value"]),
              target: graph.Input(path: ["out"]),
            ),
          ],
        ),
      ),
    ]

  assert graph.edges
    == [
      graph.Edge(
        source: graph.Static(value: graph.String("123")),
        target: graph.Input(path: ["so", "in"]),
      ),
      graph.Edge(
        source: graph.Output(path: ["so", "out"]),
        target: graph.Input(path: ["m", "l"]),
      ),
      graph.Edge(
        source: graph.Output(path: ["in"]),
        target: graph.Input(path: ["m", "r"]),
      ),
      graph.Edge(
        source: graph.Output(path: ["m", "value"]),
        target: graph.Input(path: ["out"]),
      ),
    ]
}

pub fn compile_ignores_unknown_node_port_registration_test() {
  let operation_source =
    "in: Int -> out: Int { m = Math .in -> m.l m.value -> .out }"

  let c =
    compiler.new(
      schema.Schema(
        operations: [
          schema.Operation(name: "Math", inputs: [], outputs: [
            schema.Output(name: "value", port: "Int"),
          ]),
        ],
        ports: [],
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
        operations: [
          schema.Operation(
            name: "Math",
            inputs: [schema.Input(name: "unused", port: "Int")],
            outputs: [schema.Output(name: "value", port: "String")],
          ),
        ],
        ports: [],
      ),
    )

  let assert Error(error) = compiler.compile(c, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.TypecheckerDiagnostic(
        typechecker_diagnostic.TypeMismatch(
          expected: reference.Port(0),
          found: reference.Port(1),
        ),
      ),
      span: source.Span(start: 23, end: 38),
    )
}

pub fn compile_wraps_lexer_diagnostic_test() {
  let c = compiler.new(schema.Schema(operations: [], ports: []))

  let assert Error(error) = compiler.compile(c, "!")

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.LexerDiagnostic(lexer_diagnostic.IllegalToken),
      span: source.Span(start: 0, end: 1),
    )
}

pub fn compile_wraps_parser_diagnostic_test() {
  let c = compiler.new(schema.Schema(operations: [], ports: []))

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
  let c = compiler.new(schema.Schema(operations: [], ports: []))

  let assert Error(error) = compiler.compile(c, operation_source)

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.ResolverDiagnostic(resolver_diagnostic.UnknownPort("Int")),
      span: source.Span(start: 8, end: 11),
    )
}
