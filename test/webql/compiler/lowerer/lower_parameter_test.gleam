import webql/compiler/ir
import webql/compiler/lowerer/lower_parameter
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/source

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
