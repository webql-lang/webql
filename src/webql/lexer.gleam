import gleam/bit_array
import gleam/list
import gleam/result
import webql/lexer/diagnostic
import webql/lexer/lex_comment
import webql/lexer/lex_lower_identifier
import webql/lexer/lex_number
import webql/lexer/lex_string
import webql/lexer/lex_upper_identifier
import webql/lexer/lex_whitespace
import webql/lexer/position
import webql/lexer/token

pub type LexerMode {
  Normal
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
    /// The current mode the lexer is parsing code in.
    mode: LexerMode,
    /// Whether the Lexer will crash if it recieves invalid tokens.
    strict: Bool,
    /// A option to determine if the lexer will tokenize comments.
    comments: Bool,
    /// A option to determine if the lexer will tokenize whitespace.
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
    mode: Normal,
    strict: True,
    comments: True,
    whitespace: True,
  )
}

/// Configures comments on an active lexer instance
pub fn comments(lexer: Lexer, enabled comments: Bool) {
  Lexer(..lexer, comments:)
}

/// Configures whitespace on an active lexer instance
pub fn whitespace(lexer: Lexer, enabled whitespace: Bool) {
  Lexer(..lexer, whitespace:)
}

/// Takes a lexer source and converts it to a list of tokens.
pub fn run(lexer: Lexer) -> Result(List(token.Token), diagnostic.Diagnostic) {
  let tokens = []

  case lex(lexer, tokens) {
    Ok(result) -> Ok(list.reverse(result))
    Error(message) -> Error(message)
  }
}

// PRIVATE FUNCTIONS
// =================
fn lex(
  lexer: Lexer,
  tokens: List(token.Token),
) -> Result(List(token.Token), diagnostic.Diagnostic) {
  use #(token, rest) <- result.try(case lexer.mode {
    Normal -> lex_normal_mode(lexer)
  })

  case token.kind {
    // ============ EOF ===========
    token.EOF -> Ok([token, ..tokens])

    // =========== SKIP ===========
    token.CommentSingle if !lexer.comments -> {
      let lexer =
        Lexer(..lexer, remaining_bytes: rest, position: token.span.end)

      lex(lexer, tokens)
    }

    token.Space if !lexer.whitespace -> {
      let lexer =
        Lexer(..lexer, remaining_bytes: rest, position: token.span.end)

      lex(lexer, tokens)
    }

    // =========== CONT ===========
    _continue -> {
      let lexer =
        Lexer(..lexer, remaining_bytes: rest, position: token.span.end)

      lex(lexer, [token, ..tokens])
    }
  }
}

fn lex_normal_mode(
  lexer: Lexer,
) -> Result(#(token.Token, BitArray), diagnostic.Diagnostic) {
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
    | <<"9", rest:bytes>> -> Ok(lex_number.lex(rest, lexer.position, 1))

    // ========== STRING ==========
    <<"\"", rest:bytes>> -> lex_string.lex(rest, lexer.position, 1)

    // ======== COMMENTS ==========
    <<"#", rest:bytes>> -> Ok(lex_comment.lex(rest, lexer.position, 1))

    // ======== GROUPINGS =========
    <<"(", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.LParen,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<")", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.RParen,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<"{", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.LBrace,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<"}", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.RBrace,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<"[", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.LSquare,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<"]", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.RSquare,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    // ======= PUNCTUATION ========
    <<":", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.Colon,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<",", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.Comma,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<"=", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.Equal,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<".", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.Dot,
          span: position.Span(start: lexer.position, end: lexer.position + 1),
        ),
        rest,
      ))

    <<"->", rest:bytes>> ->
      Ok(#(
        token.Token(
          kind: token.RArrow,
          span: position.Span(start: lexer.position, end: lexer.position + 2),
        ),
        rest,
      ))

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
    | <<"Z", rest:bytes>> ->
      Ok(lex_upper_identifier.lex(rest, lexer.position, 1))

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
    | <<"z", rest:bytes>> ->
      Ok(lex_lower_identifier.lex(rest, lexer.position, 1))

    // ======= WHITESPACE =========
    <<" ", rest:bytes>>
    | <<"\n", rest:bytes>>
    | <<"\r", rest:bytes>>
    | <<"\t", rest:bytes>> -> Ok(lex_whitespace.lex(rest, lexer.position, 1))

    // ========== SYMBOLS =========
    <<_char, _rest:bytes>> ->
      Error(diagnostic.Diagnostic(
        kind: diagnostic.IllegalToken,
        span: position.Span(start: lexer.position, end: lexer.position + 1),
      ))

    // ============ EOF ===========
    _eof ->
      Ok(
        #(
          token.Token(
            kind: token.EOF,
            span: position.Span(start: lexer.position, end: lexer.position),
          ),
          <<>>,
        ),
      )
  }
}
