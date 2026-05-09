-module(transient_ffi).

-export([batches/2, steps/3, resolve/2, inline/2, complete/2]).

batches(Initial, Batches) ->
  pending(fun() -> run_batches({ok, Initial}, Batches) end).

steps(Initial, Steps, Merge) ->
  pending(fun() ->
             Results = run_steps(Steps),
             merge_steps(Results, Initial, Merge)
          end).

resolve(Resolution, Next) ->
  pending(fun() -> Next(resolve_to_result(Resolution)) end).

inline(Resolution, Next) ->
  then_ok(Resolution, Next).

complete(Resolution, Next) ->
  then_ok(Resolution, Next).

pending(Work) ->
  {pending,
   fun(Done) ->
      _ = erlang:spawn(fun() -> Done(Work()) end),
      nil
   end}.

then_ok(Resolution, Next) ->
  pending(fun() ->
             case resolve_to_result(Resolution) of
               {ok, Value} -> Next(Value);
               {error, _} = Error -> Error
             end
          end).

run_batches(Result, []) ->
  Result;
run_batches({error, _} = Error, _Batches) ->
  Error;
run_batches({ok, Memory}, [Batch | Rest]) ->
  run_batches(resolve_to_result(Batch(Memory)), Rest).

run_steps(Steps) ->
  Parent = self(),
  Refs =
    lists:map(fun(Step) ->
                 Ref = make_ref(),
                 _ = erlang:spawn(fun() -> Parent ! {Ref, resolve_to_result(Step)} end),
                 Ref
              end,
              Steps),
  lists:map(fun await_ref/1, Refs).

await_ref(Ref) ->
  receive
    {Ref, Result} ->
      Result
  end.

merge_steps([], Memory, _Merge) ->
  {ok, Memory};
merge_steps([{error, _} = Error | _], _Memory, _Merge) ->
  Error;
merge_steps([{ok, StepMemory} | Rest], Memory, Merge) ->
  merge_steps(Rest, Merge(Memory, StepMemory), Merge).

resolve_to_result({done, Result}) ->
  Result;
resolve_to_result({pending, Perform}) ->
  Parent = self(),
  Ref = make_ref(),
  Perform(fun(Result) ->
             Parent ! {Ref, Result},
             nil
          end),
  receive
    {Ref, Result} ->
      Result
  end.
