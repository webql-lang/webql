import webql/assembler
import webql/assembler/plan
import webql/compiler
import webql/diagnostic
import webql/graph
import webql/introspection
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

/// Assembles a WebQL graph into a executable plan.
pub fn assemble(
  graph: graph.Graph,
  schema: schema.Schema,
) -> Result(plan.Plan, diagnostic.Diagnostic) {
  let assembler = assembler.new(schema)

  case assembler.assemble(assembler, graph) {
    Ok(plan) -> Ok(plan)

    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.AssemblerDiagnostic(
          diagnostic.kind,
        )),
      )
  }
}

/// Returns introspection results for a WebQL schema.
pub fn introspect(schema: schema.Schema) -> introspection.Schema {
  introspection.introspect(schema)
}
