import webql/compiler
import webql/diagnostic
import webql/graph
import webql/introspection
import webql/linker
import webql/program
import webql/schema

/// Compiles WebQL source into a graph.
pub fn compile(
  source: String,
  introspection: introspection.Schema,
) -> Result(graph.Graph, diagnostic.Diagnostic) {
  let compiler = compiler.new(introspection)

  case compiler.compile(compiler, source) {
    Ok(output) -> Ok(output)
    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.CompilerDiagnostic(
          diagnostic.kind,
        )),
      )
  }
}

/// Links a WebQL graph into a program.
pub fn link(
  graph: graph.Graph,
  schema: schema.Schema,
) -> Result(program.Program, diagnostic.Diagnostic) {
  let linker = linker.new(graph, schema)

  case linker.link(linker) {
    Ok(program) -> Ok(program)

    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.LinkerDiagnostic(diagnostic.kind)),
      )
  }
}

/// Returns introspection results for a WebQL schema.
pub fn introspect(schema: schema.Schema) -> introspection.Schema {
  introspection.introspect(schema)
}
