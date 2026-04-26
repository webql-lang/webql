import webql/compiler/ir
import webql/compiler/lowerer/lower_return
import webql/compiler/reference
import webql/compiler/resolver/ast
import webql/compiler/source

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
