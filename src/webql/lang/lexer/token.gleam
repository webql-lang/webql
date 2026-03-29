import webql/lang/lexer/diagnostic
import webql/lang/source/position

pub type TokenKind {
  // ========== LITERALS ==========
  Name
  Int
  Float
  String
  CommentSingle

  // ========= GROUPINGS ==========
  LParen
  RParen
  LBrace
  RBrace
  LSquare
  RSquare

  // ======== PUNCTUATION =========
  Colon
  Comma
  Equal
  RArrow
  Dot

  // ======== IDENTIFIERS =========
  UpperIdentifier
  LowerIdentifier

  // ========== SPACING ===========
  Space
  EOF

  // ========= UNSTRICT ===========
  Diagnostic(kind: diagnostic.DiagnosticKind)
}

pub type Token {
  Token(kind: TokenKind, span: position.Span)
}
