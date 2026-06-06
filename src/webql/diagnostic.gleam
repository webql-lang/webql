import webql/assembler/diagnostic as assembler_diagnostic
import webql/compiler/diagnostic as compiler_diagnostic
import webql/runner/diagnostic as runner_diagnostic

pub type DiagnosticKind {
  AssemblerDiagnostic(kind: assembler_diagnostic.DiagnosticKind)
  CompilerDiagnostic(kind: compiler_diagnostic.DiagnosticKind)
  RunnerDiagnostic(kind: runner_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
