import webql/graph
import webql/lang/compiler
import webql/lang/diagnostic
import webql/lang/loader
import webql/lang/loader/blueprint

/// Compiles a WebQL source file with a blueprint.
pub fn compile(
  source: String,
  blueprint: blueprint.Blueprint,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  let schema = loader.load(blueprint)
  let compiler = compiler.new(schema)

  case compiler.compile(compiler, source) {
    Ok(ir) -> Ok(ir)
    Error(diagnostic) ->
      Error(
        diagnostic.Diagnostic(kind: diagnostic.CompilerError(
          kind: diagnostic.kind,
        )),
      )
  }
}
