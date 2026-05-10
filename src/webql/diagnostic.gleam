import webql/assembler/diagnostic as assembler_diagnostic
import webql/compiler/diagnostic as compiler_diagnostic
import webql/interpreter/diagnostic as interpreter_diagnostic

pub type DiagnosticKind {
  AssemblerDiagnostic(kind: assembler_diagnostic.DiagnosticKind)
  CompilerDiagnostic(kind: compiler_diagnostic.DiagnosticKind)
  InterpreterDiagnostic(kind: interpreter_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
