import gleam/bit_array
import gleam/list
import gleam/result
import webql/compiler/lexer/diagnostic
import webql/compiler/lexer/lex_comment
import webql/compiler/lexer/lex_lower_identifier
import webql/compiler/lexer/lex_number
import webql/compiler/lexer/lex_string
import webql/compiler/lexer/lex_upper_identifier
import webql/compiler/lexer/lex_whitespace
import webql/compiler/lexer/token
import webql/compiler/source

pub type LexerMode {
  Halt
  Recover
}

pub opaque type Lexer {
  Lexer(
    /// The original source provided when instantiating the lexer. This remains unchanged throughout the lexing process.
    source: String,
    /// The original source converted to a `BitArray`.
    bytes: BitArray,
    /// The remaining source to process.
    remaining_bytes: BitArray,
    /// The current byte position from the start of the source.
    position: Int,
    /// A mode determining whether the compiler will halt or recover if it sees invalid tokens.
    mode: LexerMode,
    /// A option to determine if the lexer will lex_token comments. By default this is true.
    comments: Bool,
    /// A option to determine if the lexer will lex_token whitespace. By default this is true.
    whitespace: Bool,
  )
}

/// Creates a new lexer instance from a source.
pub fn new(source: String) -> Lexer {
  let bytes = bit_array.from_string(source)

  Lexer(
    source: source,
    remaining_bytes: bytes,
    bytes:,
    position: 0,
    mode: Halt,
    comments: True,
    whitespace: True,
  )
}

/// Takes a lexer source and converts it to a list of tokens.
pub fn lex(lexer: Lexer) -> Result(List(token.Token), diagnostic.Diagnostic) {
  let tokens = []

  case lex_source(lexer, tokens) {
    Ok(result) -> Ok(list.reverse(result))
    Error(message) -> Error(message)
  }
}

/// Configures comments on an active lexer instance
pub fn with_comments(lexer: Lexer, enabled comments: Bool) {
  Lexer(..lexer, comments:)
}

/// Configures whitespace on an active lexer instance
pub fn with_whitespace(lexer: Lexer, enabled whitespace: Bool) {
  Lexer(..lexer, whitespace:)
}

/// Configures stictness on an active lexer instance.
pub fn with_mode(lexer: Lexer, mode mode: LexerMode) {
  Lexer(..lexer, mode:)
}

// PRIVATE FUNCTIONS
// =================
fn lex_source(lexer: Lexer, tokens: List(token.Token)) {
  use #(token, rest) <- result.try(case lexer.mode {
    Recover -> Ok(lex_token(lexer))
    Halt -> lex_token_or_error(lexer)
  })

  let lexer = Lexer(..lexer, remaining_bytes: rest, position: token.span.end)

  case token.kind {
    // ============ EOF ===========
    token.EOF -> Ok([token, ..tokens])

    // =========== SKIP ===========
    token.CommentSingle if !lexer.comments -> lex_source(lexer, tokens)
    token.Space if !lexer.whitespace -> lex_source(lexer, tokens)

    // =========== CONT ===========
    _continue -> lex_source(lexer, [token, ..tokens])
  }
}

fn lex_token(lexer: Lexer) {
  case lexer.remaining_bytes {
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
    | <<"9", rest:bytes>> -> lex_number.lex(rest, lexer.position, 1)

    // ========== STRING ==========
    <<"\"", rest:bytes>> -> lex_string.lex(rest, lexer.position, 1)

    // ======== COMMENTS ==========
    <<"#", rest:bytes>> -> lex_comment.lex(rest, lexer.position, 1)

    // ======== GROUPINGS =========
    <<"(", rest:bytes>> -> #(
      token.Token(
        kind: token.LParen,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<")", rest:bytes>> -> #(
      token.Token(
        kind: token.RParen,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<"{", rest:bytes>> -> #(
      token.Token(
        kind: token.LBrace,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<"}", rest:bytes>> -> #(
      token.Token(
        kind: token.RBrace,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<"[", rest:bytes>> -> #(
      token.Token(
        kind: token.LSquare,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<"]", rest:bytes>> -> #(
      token.Token(
        kind: token.RSquare,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    // ======= PUNCTUATION ========
    <<":", rest:bytes>> -> #(
      token.Token(
        kind: token.Colon,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<",", rest:bytes>> -> #(
      token.Token(
        kind: token.Comma,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<"=", rest:bytes>> -> #(
      token.Token(
        kind: token.Equal,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<".", rest:bytes>> -> #(
      token.Token(
        kind: token.Dot,
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    <<"->", rest:bytes>> -> #(
      token.Token(
        kind: token.RArrow,
        span: source.Span(start: lexer.position, end: lexer.position + 2),
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
    | <<"Z", rest:bytes>> -> lex_upper_identifier.lex(rest, lexer.position, 1)

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
    | <<"z", rest:bytes>> -> lex_lower_identifier.lex(rest, lexer.position, 1)

    // ======= WHITESPACE =========
    <<" ", rest:bytes>>
    | <<"\n", rest:bytes>>
    | <<"\r", rest:bytes>>
    | <<"\t", rest:bytes>> -> lex_whitespace.lex(rest, lexer.position, 1)

    // ========== ILLEGAL =========
    <<_char, rest:bytes>> -> #(
      token.Token(
        kind: token.Diagnostic(diagnostic.IllegalToken),
        span: source.Span(start: lexer.position, end: lexer.position + 1),
      ),
      rest,
    )

    // ============ EOF ===========
    _eof -> #(
      token.Token(
        kind: token.EOF,
        span: source.Span(start: lexer.position, end: lexer.position),
      ),
      <<>>,
    )
  }
}

fn lex_token_or_error(lexer: Lexer) {
  case lex_token(lexer) {
    #(token.Token(kind: token.Diagnostic(kind: kind), span: span), _bytes) -> {
      Error(diagnostic.Diagnostic(kind:, span:))
    }

    token -> Ok(token)
  }
}
