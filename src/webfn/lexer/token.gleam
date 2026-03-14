pub type TokenSpan {
  Span(start: Int, end: Int)
}

pub type TokenKind {
  // ========== LITERALS ==========
  Name
  Int
  Float
  String
  Bool
  CommentSingle
  CommentMulti

  // ========= GROUPINGS ==========
  LParen
  RParen
  LBrace
  RBrace
  LSquare
  RSquare

  // ========= INTEGERS ===========
  Plus
  Minus

  // ======== PUNCTUATION =========
  Colon
  Comma
  Equal
  Arrow
  EOF
  Space

  // ========== ERRORS ============
  UnterminatedString
}

pub type Token {
  Token(kind: TokenKind, span: TokenSpan)
}
