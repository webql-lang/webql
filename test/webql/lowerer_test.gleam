import gleam/dict
import gleam/option
import webql/typechecker
import webql/graph
import webql/lexer
import webql/lowerer
import webql/parser
import webql/resolver
import webql/schema

pub fn lower_ast_test() {
  let source =
    "token: Uuid -> out: Int { service = .token -> Service node = service.Thing 42 -> node.integer node.out -> .out }"

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
              nodes: dict.from_list([
                #(
                  "Thing",
                  schema.Node(
                    inputs: dict.from_list([
                      #(
                        "integer",
                        schema.Input(typename: schema.Typename("Int")),
                      ),
                    ]),
                    outputs: dict.from_list([
                      #("out", schema.Output(typename: schema.Typename("Int"))),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ]),
        nodes: dict.new(),
      ),
    )

  assert lowerer.lower(typechecker.Tast(ast))
    == graph.Graph(
      parameters: [
        graph.Parameter(name: "token", typename: graph.Typename("Uuid")),
      ],
      returns: [
        graph.Return(name: "out", typename: graph.Typename("Int")),
      ],
      supernodes: [],
      boundaries: [
        graph.Boundary(
          name: "service",
          from: graph.Output(path: graph.Port("token")),
          owner: option.None,
          boundary: "Service",
        ),
      ],
      nodes: [
        graph.Node(name: "node", owner: option.Some("service"), node: "Thing"),
      ],
      edges: [
        graph.Edge(
          from: graph.Literal(value: graph.Int(42)),
          to: graph.Input(path: graph.Vertex("node", "integer")),
        ),
        graph.Edge(
          from: graph.Output(path: graph.Vertex("node", "out")),
          to: graph.Input(path: graph.Port("out")),
        ),
      ],
    )
}
