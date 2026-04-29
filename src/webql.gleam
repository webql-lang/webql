import webql/document
import webql/graph
import webql/introspection
import webql/introspection/schema
import webql/lang
import webql/lang/diagnostic

/// Compiles a WebQL source into a executable graph.
pub fn compile(
  source: String,
  schema: schema.Schema,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  lang.compile(source, schema)
}

/// Converts a WebQL document into a schema.
pub fn introspect(document: document.Document) -> schema.Schema {
  introspection.introspect(document)
}
