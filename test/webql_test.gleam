import gleam/dict
import gleeunit
import webql
import webql/typechecker
import webql/graph
import webql/lexer
import webql/parser
import webql/resolver
import webql/schema
import webql/source

pub fn main() {
  gleeunit.main()
}

pub fn compile_returns_graph_test() {
  assert webql.compile(
      "value: Int -> out: Int { .value -> .out }",
      schema.Schema(
        typenames: dict.from_list([#("Int", schema.Typename("Int"))]),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )
    == Ok(
      graph.Graph(
        parameters: [
          graph.Parameter(name: "value", typename: graph.Typename("Int")),
        ],
        returns: [graph.Return(name: "out", typename: graph.Typename("Int"))],
        supernodes: [],
        boundaries: [],
        nodes: [],
        edges: [
          graph.Edge(
            from: graph.Output(path: graph.Port("value")),
            to: graph.Input(path: graph.Port("out")),
          ),
        ],
      ),
    )
}

pub fn compile_wraps_lexer_diagnostic_test() {
  let code = "!"
  let assert Error(webql.Diagnostic(
    kind: webql.LexerDiagnostic(lexer.IllegalToken),
    span:,
  )) =
    webql.compile(
      code,
      schema.Schema(
        typenames: dict.new(),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )

  assert source.slice(code, span) == code
}

pub fn compile_wraps_parser_diagnostic_test() {
  let code = "{"
  let assert Error(webql.Diagnostic(
    kind: webql.ParserDiagnostic(parser.UnexpectedToken(
      found: lexer.LBrace,
      expected: parser.ExpectedAst,
    )),
    span:,
  )) =
    webql.compile(
      code,
      schema.Schema(
        typenames: dict.new(),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )

  assert source.slice(code, span) == code
}

pub fn compile_wraps_resolver_diagnostic_test() {
  let code = "value: Missing -> {}"
  let assert Error(webql.Diagnostic(
    kind: webql.ResolverDiagnostic(resolver.UnknownTypename("Missing")),
    span:,
  )) =
    webql.compile(
      code,
      schema.Schema(
        typenames: dict.new(),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )

  assert source.slice(code, span) == "value: Missing"
}

pub fn compile_wraps_typechecker_diagnostic_test() {
  let code = "value: Int -> out: String { .value -> .out }"
  let assert Error(webql.Diagnostic(
    kind: webql.CheckerDiagnostic(typechecker.TypeMismatch(
      expected: resolver.Typename("String"),
      found: resolver.Typename("Int"),
    )),
    span:,
  )) =
    webql.compile(
      code,
      schema.Schema(
        typenames: dict.from_list([
          #("Int", schema.Typename("Int")),
          #("String", schema.Typename("String")),
        ]),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )

  assert source.slice(code, span) == ".value -> .out"
}
