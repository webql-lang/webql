import gleam/dict
import webql/compiler/reference
import webql/loader
import webql/loader/schema

pub fn load_uses_json_loader_by_default_test() {
  let document =
    "{\"typenames\":[\"Int\"],\"nodes\":[{\"name\":\"Node\",\"inputs\":[{\"name\":\"value\",\"typename\":\"Int\"}],\"outputs\":[{\"name\":\"value\",\"typename\":\"Int\"}]}]}"
  let instance = loader.new()

  assert loader.load(instance, document)
    == Ok(schema.Schema(
      typenames: dict.from_list([#("Int", reference.Typename(0))]),
      nodes: dict.from_list([#("Node", reference.Node(0))]),
      inputs: dict.from_list([
        #(reference.Node(0), [#("value", reference.Typename(0))]),
      ]),
      outputs: dict.from_list([
        #(reference.Node(0), [#("value", reference.Typename(0))]),
      ]),
    ))
}
