import gleam/dynamic/decode

/// Given a dynamic type, supplies typenames and nodes to construct a desired schema.
pub fn decode(build) {
  let decode_port = {
    use name <- decode.field("name", decode.string)
    use typename <- decode.field("typename", decode.string)
    decode.success(#(name, typename))
  }

  let decode_node = {
    use name <- decode.field("name", decode.string)
    use inputs <- decode.field("inputs", decode.list(decode_port))
    use outputs <- decode.field("outputs", decode.list(decode_port))

    decode.success(#(name, inputs, outputs))
  }

  use typenames <- decode.field("typenames", decode.list(decode.string))
  use nodes <- decode.field("nodes", decode.list(decode_node))

  let schema = build(typenames, nodes)
  decode.success(schema)
}
