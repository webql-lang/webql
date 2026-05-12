-module(transient_ffi).

-export([run/1, start_plan/1, finish_plan/2, start_batch/1, finish_batch/3, start_step/1,
         finish_step/2]).

run(Next) ->
  case Next() of
    {ok, Task} ->
      await(Task);
    Error ->
      Error
  end.

start_plan(Next) ->
  async(fun() ->
           case Next() of
             {ok, {Initial, Batches}} -> run_batches({ok, Initial}, Batches);
             Error -> Error
           end
        end).

finish_plan(Task, Next) ->
  async(fun() ->
           case await(Task) of
             {ok, Memory} -> Next(Memory);
             Error -> Error
           end
        end).

start_batch(Next) ->
  Next().

finish_batch(Initial, Task, Merge) ->
  case Task of
    {ok, Steps} ->
      run_steps(Initial, Steps, Merge);
    Error ->
      Error
  end.

start_step(Next) ->
  async(fun() ->
           case Next() of
             {ok, Task} -> await(Task);
             Error -> Error
           end
        end).

finish_step(Task, Next) ->
  async(fun() -> Next(await(Task)) end).

run_batches({error, _} = Error, _Batches) ->
  Error;
run_batches({ok, Memory}, []) ->
  {ok, Memory};
run_batches({ok, Memory}, [Batch | Rest]) ->
  run_batches(await(Batch(Memory)), Rest).

run_steps(Memory, [], _Merge) ->
  {ok, Memory};
run_steps(Memory, [Step | Rest], Merge) ->
  case await(Step) of
    {ok, StepMemory} ->
      run_steps(Merge(Memory, StepMemory), Rest, Merge);
    Error ->
      Error
  end.

async(Fun) ->
  Pid = spawn(fun() -> wait_for_await(Fun()) end),
  {async, Pid}.

await({async, Pid}) ->
  Ref = make_ref(),
  Monitor = monitor(process, Pid),
  Pid ! {await, self(), Ref},
  receive
    {Ref, Result} ->
      demonitor(Monitor, [flush]),
      Result;
    {'DOWN', Monitor, process, Pid, Reason} ->
      exit(Reason)
  end;
await(Task) ->
  Task.

wait_for_await(Result) ->
  receive
    {await, Pid, Ref} ->
      Pid ! {Ref, Result}
  end.
