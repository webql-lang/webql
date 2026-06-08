-module(webql@compiler).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler.gleam").
-export([new/1, compile/2]).
-export_type([compiler/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque compiler() :: {compiler, webql@compiler@environment:environment()}.

-file("src/webql/compiler.gleam", 93).
-spec load_returns(
    webql@compiler@environment:environment(),
    binary(),
    list(webql@introspection:output())
) -> webql@compiler@environment:environment().
load_returns(Environment, Operation, Outputs) ->
    gleam@list:fold(
        Outputs,
        Environment,
        fun(Environment@1, Output) ->
            {output, Name, Port} = Output,
            Environment@2 = webql@compiler@environment:add_port(
                Environment@1,
                Port
            ),
            Operation@1 = webql@compiler@environment:get_operation(
                Environment@2,
                Operation
            ),
            Port@1 = webql@compiler@environment:get_port(Environment@2, Port),
            case {Operation@1, Port@1} of
                {{ok, Operation@2}, {ok, Port@2}} ->
                    webql@compiler@environment:add_output(
                        Environment@2,
                        Operation@2,
                        {Name, Port@2}
                    );

                {_, _} ->
                    Environment@2
            end
        end
    ).

-file("src/webql/compiler.gleam", 73).
-spec load_parameters(
    webql@compiler@environment:environment(),
    binary(),
    list(webql@introspection:input())
) -> webql@compiler@environment:environment().
load_parameters(Environment, Operation, Inputs) ->
    gleam@list:fold(
        Inputs,
        Environment,
        fun(Environment@1, Input) ->
            {input, Name, Port} = Input,
            Environment@2 = webql@compiler@environment:add_port(
                Environment@1,
                Port
            ),
            Operation@1 = webql@compiler@environment:get_operation(
                Environment@2,
                Operation
            ),
            Port@1 = webql@compiler@environment:get_port(Environment@2, Port),
            case {Operation@1, Port@1} of
                {{ok, Operation@2}, {ok, Port@2}} ->
                    webql@compiler@environment:add_input(
                        Environment@2,
                        Operation@2,
                        {Name, Port@2}
                    );

                {_, _} ->
                    Environment@2
            end
        end
    ).

-file("src/webql/compiler.gleam", 61).
-spec load_operation(
    webql@compiler@environment:environment(),
    webql@introspection:operation()
) -> webql@compiler@environment:environment().
load_operation(Environment, Operation) ->
    {operation, Name, Inputs, Outputs} = Operation,
    _pipe = Environment,
    _pipe@1 = webql@compiler@environment:add_operation(_pipe, Name),
    _pipe@2 = load_parameters(_pipe@1, Name, Inputs),
    load_returns(_pipe@2, Name, Outputs).

-file("src/webql/compiler.gleam", 19).
?DOC(" Creates a compiler instance with resolver context.\n").
-spec new(webql@introspection:schema()) -> compiler().
new(Schema) ->
    {schema, Operations, Ports} = Schema,
    Environment = gleam@list:fold(
        Operations,
        webql@compiler@environment:add_ports(
            webql@compiler@environment:new(),
            Ports
        ),
        fun load_operation/2
    ),
    {compiler, Environment}.

-file("src/webql/compiler.gleam", 153).
-spec compile_typecheck(
    webql@compiler@typechecker:typechecker(),
    webql@compiler@context:context()
) -> {ok, webql@compiler@resolver@hir:document()} |
    {error, webql@compiler@diagnostic:diagnostic()}.
compile_typecheck(Typechecker, Context) ->
    case webql@compiler@typechecker:resolve(Typechecker, Context) of
        {ok, Document} ->
            {ok, Document};

        {error, Error} ->
            {error,
                {diagnostic,
                    {typechecker_diagnostic, erlang:element(2, Error)},
                    erlang:element(3, Error)}}
    end.

-file("src/webql/compiler.gleam", 137).
-spec compile_resolve(
    compiler(),
    webql@compiler@context:context(),
    webql@compiler@resolver:resolver()
) -> {ok,
        {webql@compiler@resolver@hir:document(),
            webql@compiler@context:context()}} |
    {error, webql@compiler@diagnostic:diagnostic()}.
compile_resolve(Compiler, Context, Resolver) ->
    case webql@compiler@resolver:resolve(
        Resolver,
        erlang:element(2, Compiler),
        Context
    ) of
        {ok, Document} ->
            {ok, Document};

        {error, Error} ->
            {error,
                {diagnostic,
                    {resolver_diagnostic, erlang:element(2, Error)},
                    erlang:element(3, Error)}}
    end.

-file("src/webql/compiler.gleam", 125).
-spec compile_parse(webql@compiler@parser:parser()) -> {ok,
        webql@compiler@parser@ast:document()} |
    {error, webql@compiler@diagnostic:diagnostic()}.
compile_parse(Parser) ->
    case webql@compiler@parser:parse(Parser) of
        {ok, Document} ->
            {ok, Document};

        {error, Error} ->
            {error,
                {diagnostic,
                    {parser_diagnostic, erlang:element(2, Error)},
                    erlang:element(3, Error)}}
    end.

-file("src/webql/compiler.gleam", 113).
-spec compile_lex(webql@compiler@lexer:lexer()) -> {ok,
        list(webql@compiler@lexer@token:token())} |
    {error, webql@compiler@diagnostic:diagnostic()}.
compile_lex(Lexer) ->
    case webql@compiler@lexer:lex(Lexer) of
        {ok, Tokens} ->
            {ok, Tokens};

        {error, Error} ->
            {error,
                {diagnostic,
                    {lexer_diagnostic, erlang:element(2, Error)},
                    erlang:element(3, Error)}}
    end.

-file("src/webql/compiler.gleam", 33).
?DOC(" Compiles a text source into a finalized document.\n").
-spec compile(compiler(), binary()) -> {ok, webql@graph:graph()} |
    {error, webql@compiler@diagnostic:diagnostic()}.
compile(Compiler, Source) ->
    Context = webql@compiler@context:new(),
    Lexer = webql@compiler@lexer:new(Source),
    gleam@result:'try'(
        compile_lex(Lexer),
        fun(Tokens) ->
            Parser = webql@compiler@parser:new(Source, Tokens),
            gleam@result:'try'(
                compile_parse(Parser),
                fun(Document) ->
                    Resolver = webql@compiler@resolver:new(Document),
                    gleam@result:'try'(
                        compile_resolve(Compiler, Context, Resolver),
                        fun(_use0) ->
                            {Document@1, Context@1} = _use0,
                            Typechecker = webql@compiler@typechecker:new(
                                Document@1
                            ),
                            gleam@result:'try'(
                                compile_typecheck(Typechecker, Context@1),
                                fun(Document@2) ->
                                    Lowerer = webql@compiler@lowerer:new(
                                        Document@2
                                    ),
                                    {ok, webql@compiler@lowerer:lower(Lowerer)}
                                end
                            )
                        end
                    )
                end
            )
        end
    ).
