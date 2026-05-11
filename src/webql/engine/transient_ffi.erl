-module(transient_ffi).

-export([
    run/1,
    start_plan/1,
    finish_plan/2,
    start_batch/1,
    finish_batch/3,
    start_step/1,
    finish_step/2
]).

run(Next) ->
    case Next() of
        {ok, Task} -> Task;
        Error -> Error
    end.

start_plan(Next) ->
    case Next() of
        {ok, {Initial, Batches}} -> run_batches({ok, Initial}, Batches);
        Error -> Error
    end.

finish_plan(Task, Next) ->
    case Task of
        {ok, Memory} -> Next(Memory);
        Error -> Error
    end.

start_batch(Next) ->
    Next().

finish_batch(Initial, Task, Merge) ->
    case Task of
        {ok, Steps} -> run_steps(Initial, Steps, Merge);
        Error -> Error
    end.

start_step(Next) ->
    case Next() of
        {ok, Task} -> Task;
        Error -> Error
    end.

finish_step(Task, Next) ->
    Next(Task).

run_batches({error, _} = Error, _Batches) ->
    Error;
run_batches({ok, Memory}, []) ->
    {ok, Memory};
run_batches({ok, Memory}, [Batch | Rest]) ->
    run_batches(Batch(Memory), Rest).

run_steps(Memory, [], _Merge) ->
    {ok, Memory};
run_steps(Memory, [Step | Rest], Merge) ->
    case Step of
        {ok, StepMemory} -> run_steps(Merge(Memory, StepMemory), Rest, Merge);
        Error -> Error
    end.
