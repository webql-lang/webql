import gleam/dict
import webql/lang/compiler/reference
import webql/lang/loader
import webql/lang/loader/preschema
import webql/lang/loader/schema

pub fn load_loads_preschema_test() {
  assert loader.load(
      preschema.Preschema(typenames: ["Int"], nodes: [
        #("Node", [#("input", "Int")], [#("output", "Int")]),
      ]),
    )
    == schema()
}

fn schema() {
  schema.Schema(
    typenames: dict.from_list([#("Int", reference.Typename(0))]),
    nodes: dict.from_list([#("Node", reference.Node(0))]),
    inputs: dict.from_list([
      #(reference.Node(0), [#("input", reference.Typename(0))]),
    ]),
    outputs: dict.from_list([
      #(reference.Node(0), [#("output", reference.Typename(0))]),
    ]),
  )
}
