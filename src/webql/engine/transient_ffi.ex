defmodule TransientFfi do
  def run(next) do
    case next.() do
      {:ok, task} -> await(task)
      {:error, message} -> {:error, message}
    end
  end

  def start_plan(next) do
    async(fn ->
      case next.() do
        {:ok, {initial, batches}} ->
          Enum.reduce_while(batches, {:ok, initial}, fn batch, {:ok, memory} ->
            case await(batch.(memory)) do
              {:ok, _} = result -> {:cont, result}
              error -> {:halt, error}
            end
          end)

        error ->
          error
      end
    end)
  end

  def finish_plan(task, next) do
    async(fn ->
      case await(task) do
        {:ok, memory} -> next.(memory)
        {:error, message} -> {:error, message}
      end
    end)
  end

  def start_batch(next) do
    next.()
  end

  def finish_batch(initial, task, merge) do
    async(fn ->
      case await(task) do
        {:ok, steps} ->
          steps
          |> Enum.map(&await/1)
          |> Enum.reduce_while({:ok, initial}, fn step, {:ok, memory} ->
            case step do
              {:ok, step_memory} -> {:cont, {:ok, merge.(memory, step_memory)}}
              error -> {:halt, error}
            end
          end)

        {:error, message} ->
          {:error, message}
      end
    end)
  end

  def start_step(next) do
    async(fn ->
      case next.() do
        {:ok, task} -> await(task)
        {:error, message} -> {:error, message}
      end
    end)
  end

  def finish_step(task, next) do
    async(fn ->
      next.(await(task))
    end)
  end

  # PRIVATE FUNCTIONS
  # =================
  defp async(fun) do
    {:async,
     spawn(fn ->
       result =
         try do
           {:ok, fun.()}
         catch
           kind, reason -> {:error, kind, reason, __STACKTRACE__}
         end

       pending(result)
     end)}
  end

  defp await({:async, pid}) do
    ref = make_ref()
    monitor = Process.monitor(pid)

    send(pid, {self(), ref})

    receive do
      {^ref, {:ok, result}} ->
        Process.demonitor(monitor, [:flush])
        result

      {^ref, {:error, kind, reason, stacktrace}} ->
        Process.demonitor(monitor, [:flush])
        :erlang.raise(kind, reason, stacktrace)

      {:DOWN, ^monitor, :process, ^pid, reason} ->
        exit(reason)
    end
  end

  defp await(task), do: task

  defp pending(result) do
    receive do
      {caller, ref} ->
        send(caller, {ref, result})
        pending(result)
    end
  end
end
