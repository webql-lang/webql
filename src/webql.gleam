import webql/document
import webql/graph
import webql/introspection
import webql/lang
import webql/lang/diagnostic

/// Compiles a WebQL source into a executable graph.
pub fn compile(
  source: String,
  schema: introspection.Schema,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  lang.compile(source, schema)
}

/// Converts a WebQL document into a schema.
pub fn introspect(document: document.Document) -> introspection.Schema {
  introspection.introspect(document)
}
