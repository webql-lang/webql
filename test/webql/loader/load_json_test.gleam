import gleam/dict
import webql/compiler/reference
import webql/loader/diagnostic
import webql/loader/load_json
import webql/loader/schema

pub fn load_decodes_schema_from_json_test() {
  let document =
    "{\"typenames\":[\"Int\"],\"nodes\":[{\"name\":\"Node\",\"inputs\":[{\"name\":\"value\",\"typename\":\"Int\"}],\"outputs\":[{\"name\":\"value\",\"typename\":\"Int\"}]}]}"

  assert load_json.load(document)
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

pub fn load_wraps_json_decode_errors_test() {
  let assert Error(diagnostic.Diagnostic(kind: diagnostic.JsonDecodeError(_))) =
    load_json.load("{")
}
