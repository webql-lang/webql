import webql/compiler/lexer
import webql/compiler/parser
import webql/compiler/resolver/diagnostic as resolver_diagnostic
import webql/compiler/typechecker/diagnostic as typechecker_diagnostic

import webql/compiler/source

pub type DiagnosticKind {
  LexerDiagnostic(kind: lexer.DiagnosticKind)
  ParserDiagnostic(kind: parser.DiagnosticKind)
  ResolverDiagnostic(kind: resolver_diagnostic.DiagnosticKind)
  TypecheckerDiagnostic(kind: typechecker_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
