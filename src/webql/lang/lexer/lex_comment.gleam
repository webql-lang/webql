import webql/lang/lexer/token
import webql/lang/source

/// Lexes single line comments beginning with '#'.
pub fn lex(bytes: BitArray, start: Int, size: Int) -> #(token.Token, BitArray) {
  lex_comment(bytes, start, size)
}

// PRIVATE FUNCTIONS
// =================
fn lex_comment(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    // ========= NEW LINE =========
    <<"\r\n", _rest:bytes>> | <<"\n", _rest:bytes>> | <<"\r", _rest:bytes>> -> #(
      token.Token(
        kind: token.CommentSingle,
        span: source.Span(start: start, end: start + size),
      ),
      bytes,
    )

    // ========== COMMENT =========
    <<_char, rest:bytes>> -> lex_comment(rest, start, size + 1)

    // ============ EOF ===========
    _eof -> #(
      token.Token(
        kind: token.CommentSingle,
        span: source.Span(start: start, end: start + size),
      ),
      bytes,
    )
  }
}
