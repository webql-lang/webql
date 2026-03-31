import webql/lang/lexer/token
import webql/lang/source

const starting_token_kind = token.Int

/// Lexes number values.
/// By default the number lexer assumes it is parsing an integer.
pub fn lex(bytes: BitArray, start: Int, size: Int) -> #(token.Token, BitArray) {
  lex_number(bytes, starting_token_kind, start, size)
}

// PRIVATE FUNCTIONS
// =================
fn lex_number(bytes: BitArray, kind: token.TokenKind, start: Int, size: Int) {
  case bytes {
    // ========= INT =========
    <<"_", rest:bytes>>
    | <<"0", rest:bytes>>
    | <<"1", rest:bytes>>
    | <<"2", rest:bytes>>
    | <<"3", rest:bytes>>
    | <<"4", rest:bytes>>
    | <<"5", rest:bytes>>
    | <<"6", rest:bytes>>
    | <<"7", rest:bytes>>
    | <<"8", rest:bytes>>
    | <<"9", rest:bytes>> -> {
      lex_number(rest, kind, start, size + 1)
    }

    // ========= FLOAT =========
    <<".", rest:bytes>> -> {
      lex_number(rest, token.Float, start, size + 1)
    }

    // ========= CLOSE =========
    next_bytes -> {
      #(
        token.Token(
          kind: kind,
          span: source.Span(start: start, end: start + size),
        ),
        next_bytes,
      )
    }
  }
}
