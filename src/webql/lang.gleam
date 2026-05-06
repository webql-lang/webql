import webql/graph
import webql/lang/compiler
import webql/lang/diagnostic
import webql/lang/introspection as schema

/// Compiles a WebQL source file with a schema.
pub fn compile(
  source: String,
  schema: schema.Schema,
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
