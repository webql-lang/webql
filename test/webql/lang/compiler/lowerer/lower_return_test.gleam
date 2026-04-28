import webql/graph/ir
import webql/lang/compiler/lowerer/lower_return
import webql/lang/compiler/reference
import webql/lang/compiler/resolver/ast
import webql/lang/compiler/source

pub fn lower_return_test() {
  let return =
    ast.Return(
      name: "out",
      typename: ast.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 8, end: 11),
      ),
      reference: reference.Return(0),
      span: source.Span(start: 3, end: 11),
    )

  assert lower_return.lower(return) == ir.Return(name: "out", typename: "Int")
}
