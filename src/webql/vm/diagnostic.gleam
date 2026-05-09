import webql/vm/assembler/diagnostic as assembler_diagnostic
import webql/vm/interpreter/diagnostic as interpreter_diagnostic

pub type DiagnosticKind {
  AssemblerDiagnostic(kind: assembler_diagnostic.DiagnosticKind)
  InterpreterDiagnostic(kind: interpreter_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
