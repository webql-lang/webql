import webql/graph/ir
import webql/lang/compiler/lowerer/lower_parameter
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/source

pub fn lower_parameter_test() {
  let parameter =
    ast.Parameter(
      name: "in",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 4, end: 7),
      ),
      reference: reference.Parameter(0),
      span: source.Span(start: 0, end: 7),
    )

  assert lower_parameter.lower(parameter)
    == ir.Parameter(name: "in", typename: "Int")
}
