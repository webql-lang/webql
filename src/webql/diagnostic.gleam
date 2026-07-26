import webql/compiler/diagnostic as compiler_diagnostic
import webql/linker/diagnostic as linker_diagnostic

pub type DiagnosticKind {
  CompilerDiagnostic(kind: compiler_diagnostic.DiagnosticKind)
  LinkerDiagnostic(kind: linker_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
