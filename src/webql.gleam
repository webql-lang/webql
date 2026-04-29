import webql/graph
import webql/lang
import webql/lang/diagnostic
import webql/system/introspection/schema

/// Compiles a WebQL source file with a schema.
pub fn compile(
  source: String,
  schema: schema.Schema,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  lang.compile(source, schema)
}
