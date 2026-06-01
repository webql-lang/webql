-module(webql@compiler@source).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/source.gleam").
-export([cover/2, slice/2]).
-export_type([span/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type span() :: {span, integer(), integer()}.

-file("src/webql/compiler/source.gleam", 10).
?DOC(
    " Grabs the start of `a` and the end of `b` to cover the entire relative\n"
    " span of characters.\n"
).
-spec cover(span(), span()) -> span().
cover(A, B) ->
    {span, erlang:element(2, A), erlang:element(3, B)}.

-file("src/webql/compiler/source.gleam", 15).
?DOC(" Relative to a span value slices the source.\n").
-spec slice(binary(), span()) -> binary().
slice(Source, Span) ->
    gleam@string:slice(
        Source,
        erlang:element(2, Span),
        erlang:element(3, Span) - erlang:element(2, Span)
    ).
