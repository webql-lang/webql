-module(basic_ffi).

-export([handle_run/1, handle_start_plan/1, handle_finish_plan/2, handle_start_batch/1,
         handle_finish_batch/3, handle_start_step/1, handle_finish_step/2]).

handle_run(Next) ->
  case Next() of
    {ok, Task} ->
      await(Task);
    Error ->
      Error
  end.

handle_start_plan(Next) ->
  async(fun() ->
           case Next() of
             {ok, {Initial, Batches}} ->
               lists:foldl(fun (Batch, {ok, Memory}) -> await(Batch(Memory));
                               (_Batch, Error) -> Error
                           end,
                           {ok, Initial},
                           Batches);
             Error -> Error
           end
        end).

handle_finish_plan(Task, Next) ->
  async(fun() ->
           case await(Task) of
             {ok, Memory} -> Next(Memory);
             Error -> Error
           end
        end).

handle_start_batch(Next) ->
  Next().

handle_finish_batch(Initial, Task, Merge) ->
  async(fun() ->
           case await(Task) of
             {ok, Steps} ->
               lists:foldl(fun ({ok, StepMemory}, {ok, Memory}) -> {ok, Merge(Memory, StepMemory)};
                               (Error, {ok, _Memory}) -> Error;
                               (_Step, Error) -> Error
                           end,
                           {ok, Initial},
                           lists:map(fun await/1, Steps));
             Error -> Error
           end
        end).

handle_start_step(Next) ->
  async(fun() ->
           case Next() of
             {ok, Task} -> await(Task);
             Error -> Error
           end
        end).

handle_finish_step(Task, Next) ->
  async(fun() -> Next(await(Task)) end).

%% PRIVATE FUNCTIONS
%% =================
async(Fun) ->
  {async,
   spawn(fun() ->
            Result =
              try
                {ok, Fun()}
              catch
                Kind:Reason:Stacktrace -> {error, Kind, Reason, Stacktrace}
              end,
            pending(Result)
         end)}.

await({async, Pid}) ->
  Ref = make_ref(),
  Monitor = erlang:monitor(process, Pid),
  Pid ! {self(), Ref},
  receive
    {Ref, {ok, Result}} ->
      erlang:demonitor(Monitor, [flush]),
      Result;
    {Ref, {error, Kind, Reason, Stacktrace}} ->
      erlang:demonitor(Monitor, [flush]),
      erlang:raise(Kind, Reason, Stacktrace);
    {'DOWN', Monitor, process, Pid, Reason} ->
      exit(Reason)
  end;
await(Task) ->
  Task.

pending(Result) ->
  receive
    {Caller, Ref} ->
      Caller ! {Ref, Result},
      pending(Result)
  end.
