import webql/document
import webql/graph
import webql/lang/compiler
import webql/lang/diagnostic
import webql/lang/introspection

/// Compiles a WebQL source file with a schema.
pub fn compile(
  source: String,
  schema: introspection.Schema,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  let compiler = compiler.new(schema)

  case compiler.compile(compiler, source) {
    Ok(ir) -> Ok(ir)
    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.CompilerDiagnostic(
          kind: diagnostic.kind,
        )),
      )
  }
}

/// Converts a WebQL document into a schema.
pub fn introspect(document: document.Document) -> introspection.Schema {
  introspection.introspect(document)
}
