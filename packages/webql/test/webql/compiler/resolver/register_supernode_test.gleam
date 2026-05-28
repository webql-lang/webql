import gleam/dict
import webql/compiler/context
import webql/compiler/reference
import webql/compiler/resolver/register_supernode

pub fn register_registers_supernode_and_nested_context_test() {
  let sub_context = context.add_return(context.new(), "out")
  let context =
    register_supernode.register(
      context.new(),
      "Inner",
      reference.Supernode(0),
      sub_context,
    )
  let context.Context(supernodes:, contexts:, ..) = context

  assert supernodes == dict.from_list([#("Inner", reference.Supernode(0))])
  assert contexts == dict.from_list([#(reference.Supernode(0), sub_context)])
}
