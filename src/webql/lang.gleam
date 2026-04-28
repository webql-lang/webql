import webql/graph/ir
import webql/lang/compiler
import webql/lang/diagnostic
import webql/lang/loader
import webql/lang/loader/preschema

/// Compiles a WebQL source file with a blueprint.
pub fn compile(
  source: String,
  preschema: preschema.Preschema,
) -> Result(ir.Module, diagnostic.Diagnostic) {
  let schema = loader.load(preschema)
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
