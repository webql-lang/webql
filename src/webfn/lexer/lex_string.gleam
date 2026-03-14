import webfn/lexer/token

/// Lexes string values.
pub fn lex(bytes: BitArray, start: Int, size: Int) -> #(token.Token, BitArray) {
  lex_string(bytes, start, size)
}

// ========= PRIVATE FUNCTIONS =========
fn lex_string(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    // ========= CLOSE STRING =========
    <<"\"", rest:bytes>> -> {
      let end = start + size + 1

      #(
        token.Token(
          kind: token.String,
          span: token.Span(start: start, end: end),
        ),
        rest,
      )
    }

    // ========= ESCAPE STRING =========
    <<"\\", rest:bytes>> -> {
      lex_escape_string(rest, start, size)
    }

    // =========== CHARACTER ===========
    <<_char, rest:bytes>> -> {
      lex_string(rest, start, size + 1)
    }

    // ====== UNTERMINATED STRING ======
    unterminated_string_bytes -> {
      #(
        token.Token(
          kind: token.UnterminatedString,
          span: token.Span(start: start, end: start + size),
        ),
        unterminated_string_bytes,
      )
    }
  }
}

fn lex_escape_string(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    <<_char, rest:bytes>> -> {
      lex_string(rest, start, size + 2)
    }

    unterminated_string_bytes -> {
      let end = start + size + 1

      #(
        token.Token(
          kind: token.UnterminatedString,
          span: token.Span(start: start, end: end),
        ),
        unterminated_string_bytes,
      )
    }
  }
}
