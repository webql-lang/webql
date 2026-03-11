import webfn/lexer/token

/// Tokenizes number values.
/// By default the number tokenizer assumes it is parsing an integer.
pub fn tokenize(
  bytes: BitArray,
  start: Int,
  size: Int,
) -> #(token.Token, BitArray) {
  tokenize_int(bytes, start, size)
}

// ========= PRIVATE FUNCTIONS =========
fn tokenize_int(bytes: BitArray, start: Int, size: Int) {
  case bytes {
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
      tokenize_int(rest, start, size + 1)
    }

    <<".", rest:bytes>> -> {
      tokenize_float(rest, start, size + 1)
    }

    next -> {
      #(
        token.Token(
          kind: token.Int,
          span: token.Span(start: start, end: start + size),
        ),
        next,
      )
    }
  }
}

fn tokenize_float(bytes: BitArray, start: Int, size: Int) {
  case bytes {
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
      tokenize_float(rest, start, size + 1)
    }

    next -> {
      #(
        token.Token(
          kind: token.Float,
          span: token.Span(start: start, end: start + size),
        ),
        next,
      )
    }
  }
}
