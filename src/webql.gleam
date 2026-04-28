import webql/graph/ir
import webql/lang
import webql/lang/diagnostic
import webql/lang/loader/preschema

/// Compiles a WebQL source file with a preschema.
pub fn compile(
  source: String,
  preschema: preschema.Preschema,
) -> Result(ir.Module, diagnostic.Diagnostic) {
  lang.compile(source, preschema)
}
