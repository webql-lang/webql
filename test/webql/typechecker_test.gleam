import gleam/dict
import webql/typechecker
import webql/lexer
import webql/parser
import webql/resolver
import webql/schema
import webql/source

pub fn check_ast_test() {
  let source = "value: Int -> result: Int { .value -> .result }"
  let assert Ok(ast) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(ast) =
    resolver.resolve(
      ast,
      schema.Schema(
        typenames: dict.from_list([#("Int", schema.Typename("Int"))]),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )

  assert typechecker.check(ast) == Ok(typechecker.Tast(ast))
}

pub fn edge_type_mismatch_diagnostic_test() {
  let source = "value: Int -> out: String { .value -> .out }"
  let assert Ok(ast) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(ast) =
    resolver.resolve(
      ast,
      schema.Schema(
        typenames: dict.from_list([
          #("Int", schema.Typename("Int")),
          #("String", schema.Typename("String")),
        ]),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )
  let assert Error(typechecker.Diagnostic(
    kind: typechecker.TypeMismatch(
      expected: resolver.Typename("String"),
      found: resolver.Typename("Int"),
    ),
    span:,
  )) = typechecker.check(ast)

  assert source.slice(source, span) == ".value -> .out"
}

pub fn boundary_type_mismatch_diagnostic_test() {
  let source = "value: Int -> { service = .value -> Service }"
  let assert Ok(ast) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(ast) =
    resolver.resolve(
      ast,
      schema.Schema(
        typenames: dict.from_list([
          #("Uuid", schema.Typename("Uuid")),
          #("Int", schema.Typename("Int")),
        ]),
        boundaries: dict.from_list([
          #(
            "Service",
            schema.Boundary(
              typename: schema.Typename("Uuid"),
              outputs: dict.new(),
              boundaries: dict.new(),
              nodes: dict.new(),
            ),
          ),
        ]),
        nodes: dict.new(),
      ),
    )
  let assert Error(typechecker.Diagnostic(
    kind: typechecker.TypeMismatch(
      expected: resolver.Typename("Uuid"),
      found: resolver.Typename("Int"),
    ),
    span:,
  )) = typechecker.check(ast)

  assert source.slice(source, span) == "service = .value -> Service"
}

pub fn nested_supernode_type_mismatch_diagnostic_test() {
  let source =
    "-> { Inner = value: Int -> result: String { .value -> .result } }"
  let assert Ok(ast) = parser.parse(source, lexer.lex_recovering(source))
  let assert Ok(ast) =
    resolver.resolve(
      ast,
      schema.Schema(
        typenames: dict.from_list([
          #("Int", schema.Typename("Int")),
          #("String", schema.Typename("String")),
        ]),
        boundaries: dict.new(),
        nodes: dict.new(),
      ),
    )
  let assert Error(typechecker.Diagnostic(
    kind: typechecker.TypeMismatch(
      expected: resolver.Typename("String"),
      found: resolver.Typename("Int"),
    ),
    span:,
  )) = typechecker.check(ast)

  assert source.slice(source, span) == ".value -> .result"
}
