import webql/compiler/lexer/token
import webql/compiler/source

/// Lexes contiguous whitespace (spaces, tabs, newlines).
pub fn lex(bytes: BitArray, start: Int, size: Int) -> #(token.Token, BitArray) {
  lex_whitespace(bytes, start, size)
}

// PRIVATE FUNCTIONS
// =================
fn lex_whitespace(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    // ========= CONTINUE =======
    <<" ", rest:bytes>>
    | <<"\t", rest:bytes>>
    | <<"\n", rest:bytes>>
    | <<"\r", rest:bytes>> -> lex_whitespace(rest, start, size + 1)

    // ========== STOP ==========
    _bytes -> #(
      token.Token(
        kind: token.Space,
        span: source.Span(start: start, end: start + size),
      ),
      bytes,
    )
  }
}
