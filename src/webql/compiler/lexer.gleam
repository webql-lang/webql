import gleam/bit_array
import gleam/list
import webql/compiler/source

pub type TokenKind {
  // ========== LITERALS ==========
  Name
  Int
  Float
  String
  Comment

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
  Whitespace
  EOF

  // ======== DIAGNOSTICS =========
  Invalid(kind: DiagnosticKind)
}

pub type Token {
  Token(kind: TokenKind, span: source.Span)
}

pub type DiagnosticKind {
  IllegalToken
  UnterminatedString
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}

/// Tokenizes source, stopping at the first invalid token.
pub fn tokenize(source: String) -> Result(List(Token), Diagnostic) {
  let bytes = bit_array.from_string(source)
  let cursor = Cursor(remaining_bytes: bytes, position: 0)

  case tokenize_strict_source(cursor, []) {
    Ok(result) -> Ok(list.reverse(result))
    Error(diagnostic) -> Error(diagnostic)
  }
}

/// Tokenizes source, preserving invalid tokens so callers can recover.
pub fn tokenize_recovering(source: String) -> List(Token) {
  let bytes = bit_array.from_string(source)
  let cursor = Cursor(remaining_bytes: bytes, position: 0)

  cursor
  |> tokenize_recovering_source([])
  |> list.reverse()
}

type Cursor {
  Cursor(remaining_bytes: BitArray, position: Int)
}

// PRIVATE FUNCTIONS
// =================
fn tokenize_strict_source(cursor: Cursor, tokens: List(Token)) {
  let #(token, rest) = lex_token(cursor)
  let cursor = Cursor(remaining_bytes: rest, position: token.span.end)

  case token.kind {
    // ========== INVALID =========
    Invalid(kind) -> Error(Diagnostic(kind:, span: token.span))

    // ============ EOF ===========
    EOF -> Ok([token, ..tokens])

    // =========== CONT ===========
    _continue -> tokenize_strict_source(cursor, [token, ..tokens])
  }
}

fn tokenize_recovering_source(cursor: Cursor, tokens: List(Token)) {
  let #(token, rest) = lex_token(cursor)
  let cursor = Cursor(remaining_bytes: rest, position: token.span.end)

  case token.kind {
    // ============ EOF ===========
    EOF -> [token, ..tokens]

    // =========== CONT ===========
    _continue -> tokenize_recovering_source(cursor, [token, ..tokens])
  }
}

fn lex_token(cursor: Cursor) {
  case cursor.remaining_bytes {
    // ========= NUMBER ===========
    <<"0", rest:bytes>>
    | <<"1", rest:bytes>>
    | <<"2", rest:bytes>>
    | <<"3", rest:bytes>>
    | <<"4", rest:bytes>>
    | <<"5", rest:bytes>>
    | <<"6", rest:bytes>>
    | <<"7", rest:bytes>>
    | <<"8", rest:bytes>>
    | <<"9", rest:bytes>> -> lex_number(rest, Int, cursor.position, 1)

    // ========== STRING ==========
    <<"\"", rest:bytes>> -> lex_string(rest, cursor.position, 1)

    // ======== COMMENTS ==========
    <<"#", rest:bytes>> -> lex_comment(rest, cursor.position, 1)

    // ======== GROUPINGS =========
    <<"(", rest:bytes>> -> #(
      Token(
        kind: LParen,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<")", rest:bytes>> -> #(
      Token(
        kind: RParen,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<"{", rest:bytes>> -> #(
      Token(
        kind: LBrace,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<"}", rest:bytes>> -> #(
      Token(
        kind: RBrace,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<"[", rest:bytes>> -> #(
      Token(
        kind: LSquare,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<"]", rest:bytes>> -> #(
      Token(
        kind: RSquare,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    // ======= PUNCTUATION ========
    <<":", rest:bytes>> -> #(
      Token(
        kind: Colon,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<",", rest:bytes>> -> #(
      Token(
        kind: Comma,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<"=", rest:bytes>> -> #(
      Token(
        kind: Equal,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<".", rest:bytes>> -> #(
      Token(
        kind: Dot,
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    <<"->", rest:bytes>> -> #(
      Token(
        kind: RArrow,
        span: source.Span(start: cursor.position, end: cursor.position + 2),
      ),
      rest,
    )

    // ======= IDENTIFIERS ========
    <<"A", rest:bytes>>
    | <<"B", rest:bytes>>
    | <<"C", rest:bytes>>
    | <<"D", rest:bytes>>
    | <<"E", rest:bytes>>
    | <<"F", rest:bytes>>
    | <<"G", rest:bytes>>
    | <<"H", rest:bytes>>
    | <<"I", rest:bytes>>
    | <<"J", rest:bytes>>
    | <<"K", rest:bytes>>
    | <<"L", rest:bytes>>
    | <<"M", rest:bytes>>
    | <<"N", rest:bytes>>
    | <<"O", rest:bytes>>
    | <<"P", rest:bytes>>
    | <<"Q", rest:bytes>>
    | <<"R", rest:bytes>>
    | <<"S", rest:bytes>>
    | <<"T", rest:bytes>>
    | <<"U", rest:bytes>>
    | <<"V", rest:bytes>>
    | <<"W", rest:bytes>>
    | <<"X", rest:bytes>>
    | <<"Y", rest:bytes>>
    | <<"Z", rest:bytes>> -> lex_upper_identifier(rest, cursor.position, 1)

    <<"a", rest:bytes>>
    | <<"b", rest:bytes>>
    | <<"c", rest:bytes>>
    | <<"d", rest:bytes>>
    | <<"e", rest:bytes>>
    | <<"f", rest:bytes>>
    | <<"g", rest:bytes>>
    | <<"h", rest:bytes>>
    | <<"i", rest:bytes>>
    | <<"j", rest:bytes>>
    | <<"k", rest:bytes>>
    | <<"l", rest:bytes>>
    | <<"m", rest:bytes>>
    | <<"n", rest:bytes>>
    | <<"o", rest:bytes>>
    | <<"p", rest:bytes>>
    | <<"q", rest:bytes>>
    | <<"r", rest:bytes>>
    | <<"s", rest:bytes>>
    | <<"t", rest:bytes>>
    | <<"u", rest:bytes>>
    | <<"v", rest:bytes>>
    | <<"w", rest:bytes>>
    | <<"x", rest:bytes>>
    | <<"y", rest:bytes>>
    | <<"z", rest:bytes>> -> lex_lower_identifier(rest, cursor.position, 1)

    // ======= WHITESPACE =========
    <<" ", rest:bytes>>
    | <<"\n", rest:bytes>>
    | <<"\r", rest:bytes>>
    | <<"\t", rest:bytes>> -> lex_whitespace(rest, cursor.position, 1)

    // ========== ILLEGAL =========
    <<_char, rest:bytes>> -> #(
      Token(
        kind: Invalid(IllegalToken),
        span: source.Span(start: cursor.position, end: cursor.position + 1),
      ),
      rest,
    )

    // ============ EOF ===========
    _eof -> #(
      Token(
        kind: EOF,
        span: source.Span(start: cursor.position, end: cursor.position),
      ),
      <<>>,
    )
  }
}

fn lex_number(bytes: BitArray, kind: TokenKind, start: Int, size: Int) {
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
      lex_number(rest, Float, start, size + 1)
    }

    // ========= CLOSE =========
    next_bytes -> {
      #(
        Token(kind:, span: source.Span(start: start, end: start + size)),
        next_bytes,
      )
    }
  }
}

fn lex_string(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    // ========= CLOSE STRING =========
    <<"\"", rest:bytes>> -> {
      let end = start + size + 1

      #(Token(kind: String, span: source.Span(start: start, end: end)), rest)
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
    _unterminated_string_eof -> {
      #(
        Token(
          kind: Invalid(UnterminatedString),
          span: source.Span(start: start, end: start + size),
        ),
        <<>>,
      )
    }
  }
}

fn lex_escape_string(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    <<_char, rest:bytes>> -> {
      lex_string(rest, start, size + 2)
    }

    _unterminated_string -> {
      let end = start + size + 1

      #(
        Token(
          kind: Invalid(UnterminatedString),
          span: source.Span(start: start, end: end),
        ),
        bytes,
      )
    }
  }
}

fn lex_lower_identifier(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    <<"a", rest:bytes>>
    | <<"b", rest:bytes>>
    | <<"c", rest:bytes>>
    | <<"d", rest:bytes>>
    | <<"e", rest:bytes>>
    | <<"f", rest:bytes>>
    | <<"g", rest:bytes>>
    | <<"h", rest:bytes>>
    | <<"i", rest:bytes>>
    | <<"j", rest:bytes>>
    | <<"k", rest:bytes>>
    | <<"l", rest:bytes>>
    | <<"m", rest:bytes>>
    | <<"n", rest:bytes>>
    | <<"o", rest:bytes>>
    | <<"p", rest:bytes>>
    | <<"q", rest:bytes>>
    | <<"r", rest:bytes>>
    | <<"s", rest:bytes>>
    | <<"t", rest:bytes>>
    | <<"u", rest:bytes>>
    | <<"v", rest:bytes>>
    | <<"w", rest:bytes>>
    | <<"x", rest:bytes>>
    | <<"y", rest:bytes>>
    | <<"z", rest:bytes>>
    | <<"0", rest:bytes>>
    | <<"1", rest:bytes>>
    | <<"2", rest:bytes>>
    | <<"3", rest:bytes>>
    | <<"4", rest:bytes>>
    | <<"5", rest:bytes>>
    | <<"6", rest:bytes>>
    | <<"7", rest:bytes>>
    | <<"8", rest:bytes>>
    | <<"9", rest:bytes>>
    | <<"_", rest:bytes>> -> {
      lex_lower_identifier(rest, start, size + 1)
    }

    _rest -> {
      let end = start + size

      #(
        Token(kind: LowerIdentifier, span: source.Span(start: start, end: end)),
        bytes,
      )
    }
  }
}

fn lex_upper_identifier(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    <<"A", rest:bytes>>
    | <<"B", rest:bytes>>
    | <<"C", rest:bytes>>
    | <<"D", rest:bytes>>
    | <<"E", rest:bytes>>
    | <<"F", rest:bytes>>
    | <<"G", rest:bytes>>
    | <<"H", rest:bytes>>
    | <<"I", rest:bytes>>
    | <<"J", rest:bytes>>
    | <<"K", rest:bytes>>
    | <<"L", rest:bytes>>
    | <<"M", rest:bytes>>
    | <<"N", rest:bytes>>
    | <<"O", rest:bytes>>
    | <<"P", rest:bytes>>
    | <<"Q", rest:bytes>>
    | <<"R", rest:bytes>>
    | <<"S", rest:bytes>>
    | <<"T", rest:bytes>>
    | <<"U", rest:bytes>>
    | <<"V", rest:bytes>>
    | <<"W", rest:bytes>>
    | <<"X", rest:bytes>>
    | <<"Y", rest:bytes>>
    | <<"Z", rest:bytes>>
    | <<"a", rest:bytes>>
    | <<"b", rest:bytes>>
    | <<"c", rest:bytes>>
    | <<"d", rest:bytes>>
    | <<"e", rest:bytes>>
    | <<"f", rest:bytes>>
    | <<"g", rest:bytes>>
    | <<"h", rest:bytes>>
    | <<"i", rest:bytes>>
    | <<"j", rest:bytes>>
    | <<"k", rest:bytes>>
    | <<"l", rest:bytes>>
    | <<"m", rest:bytes>>
    | <<"n", rest:bytes>>
    | <<"o", rest:bytes>>
    | <<"p", rest:bytes>>
    | <<"q", rest:bytes>>
    | <<"r", rest:bytes>>
    | <<"s", rest:bytes>>
    | <<"t", rest:bytes>>
    | <<"u", rest:bytes>>
    | <<"v", rest:bytes>>
    | <<"w", rest:bytes>>
    | <<"x", rest:bytes>>
    | <<"y", rest:bytes>>
    | <<"z", rest:bytes>>
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
      lex_upper_identifier(rest, start, size + 1)
    }

    _rest -> {
      let end = start + size

      #(
        Token(kind: UpperIdentifier, span: source.Span(start: start, end: end)),
        bytes,
      )
    }
  }
}

fn lex_whitespace(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    // ========= CONTINUE =======
    <<" ", rest:bytes>>
    | <<"\t", rest:bytes>>
    | <<"\n", rest:bytes>>
    | <<"\r", rest:bytes>> -> lex_whitespace(rest, start, size + 1)

    // ========== STOP ==========
    _bytes -> #(
      Token(
        kind: Whitespace,
        span: source.Span(start: start, end: start + size),
      ),
      bytes,
    )
  }
}

fn lex_comment(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    // ========= NEW LINE =========
    <<"\r\n", _rest:bytes>> | <<"\n", _rest:bytes>> | <<"\r", _rest:bytes>> -> #(
      Token(kind: Comment, span: source.Span(start: start, end: start + size)),
      bytes,
    )

    // ========== COMMENT =========
    <<_char, rest:bytes>> -> lex_comment(rest, start, size + 1)

    // ============ EOF ===========
    _eof -> #(
      Token(kind: Comment, span: source.Span(start: start, end: start + size)),
      bytes,
    )
  }
}
