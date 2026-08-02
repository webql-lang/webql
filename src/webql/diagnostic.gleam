import webql/compiler/diagnostic as compiler_diagnostic
import webql/linker

pub type DiagnosticKind {
  CompilerDiagnostic(kind: compiler_diagnostic.DiagnosticKind)
  LinkerDiagnostic(kind: linker.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
