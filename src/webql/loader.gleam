import gleam/dynamic
import gleam/dynamic/decode as dynamic_decode
import webql/loader/builder
import webql/loader/decoder as loader_decoder
import webql/loader/diagnostic
import webql/loader/schema

/// Decode dynamic data into a schema.
pub fn load(
  data: dynamic.Dynamic,
) -> Result(schema.Schema, diagnostic.Diagnostic) {
  let decoder = decoder()

  case dynamic_decode.run(data, decoder) {
    Ok(schema) -> Ok(schema)
    Error(errors) ->
      Error(diagnostic.Diagnostic(kind: diagnostic.DynamicDecodeError(errors:)))
  }
}

/// Create a schema decoder for use with other dynamic data sources.
pub fn decoder() -> dynamic_decode.Decoder(schema.Schema) {
  loader_decoder.decode(builder.build)
}
