import { Empty, Ok, Error } from "../../gleam.mjs";

// NOTE: Gleam impliments a number-based access for their custom classes.
const ACCESS_KEY = 0;

export function run(next) {
  const result = next();
  return result instanceof Ok ? result[ACCESS_KEY] : result;
}

export async function startPlan(next) {
  const result = next();
  if (result instanceof Error) return result;

  const [initial, pendingBatches] = result[ACCESS_KEY];
  const batches =
    pendingBatches instanceof Empty
      ? []
      : [pendingBatches.head, ...toArray(pendingBatches.tail)];

  return batches.reduce(
    async (acc, batch) => {
      const resolved = await acc;
      return resolved instanceof Error ? resolved : batch(resolved[ACCESS_KEY]);
    },
    Promise.resolve(new Ok(initial)),
  );
}

export async function finishPlan(task, next) {
  const result = await task;
  return result instanceof Ok ? next(result[ACCESS_KEY]) : result;
}

export function startBatch(next) {
  return next();
}

export async function finishBatch(initial, task, merge) {
  const result = await task;
  if (result instanceof Error) return result;

  const steps = await Promise.all(result[ACCESS_KEY]);
  return steps.reduce((acc, step) => {
    if (acc instanceof Error) return acc;
    if (step instanceof Error) return step;
    return new Ok(merge(acc[ACCESS_KEY], step[ACCESS_KEY]));
  }, new Ok(initial));
}

export function startStep(next) {
  const result = next();
  return result instanceof Ok ? result[ACCESS_KEY] : result;
}

export async function finishStep(task, next) {
  return next(await task);
}

const toArray = (list) =>
  list instanceof Empty ? [] : [list.head, ...toArray(list.tail)];
