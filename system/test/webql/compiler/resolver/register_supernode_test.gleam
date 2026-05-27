import gleam/dict
import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/resolver/register_supernode
import webql/compiler/source

pub fn register_registers_supernode_and_nested_context_test() {
  let supernode =
    hir.Supernode(
      name: "Inner",
      graph: hir.Graph(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [],
        span: source.Span(start: 8, end: 12),
      ),
      reference: reference.Supernode(0),
      span: source.Span(start: 0, end: 12),
    )

  let sub_context = context.add_return(context.new(), "out")
  let context =
    register_supernode.register(context.new(), supernode, sub_context)
  let context.Context(supernodes:, contexts:, ..) = context

  assert supernodes == dict.from_list([#("Inner", reference.Supernode(0))])
  assert contexts == dict.from_list([#(reference.Supernode(0), sub_context)])
}
