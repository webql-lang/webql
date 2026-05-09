import { Error as GleamError, Ok } from "../../../../gleam.mjs";
import { Done, Pending } from "../../../resolution.mjs";

function toPromise(resolution) {
  if (resolution instanceof Done) {
    return Promise.resolve(resolution[0]);
  }

  if (resolution instanceof Pending) {
    return new Promise((resolve) => {
      resolution[0](resolve);
    });
  }

  return Promise.resolve(resolution);
}

function fromPromise(promise) {
  return new Pending((done) => {
    promise.then(done);
  });
}

function thenOk(resolution, next) {
  return fromPromise(
    toPromise(resolution).then((result) => {
      if (result instanceof Ok) {
        return next(result[0]);
      }

      return result;
    }),
  );
}

export function batches(initial, batches, interpret) {
  let promise = Promise.resolve(new Ok(initial));

  for (const batch of batches) {
    promise = promise.then((result) => {
      if (result instanceof Ok) {
        return toPromise(interpret(result[0], batch));
      }

      return result;
    });
  }

  return fromPromise(promise);
}

export function steps(initial, steps, merge) {
  return fromPromise(
    Promise.all(steps.toArray().map(toPromise)).then((results) => {
      let memory = initial;

      for (const result of results) {
        if (result instanceof GleamError) {
          return result;
        }

        memory = merge(memory, result[0]);
      }

      return new Ok(memory);
    }),
  );
}

export function resolve(resolution, next) {
  return fromPromise(toPromise(resolution).then(next));
}

export function inline(resolution, next) {
  return thenOk(resolution, next);
}

export function complete(resolution, next) {
  return thenOk(resolution, next);
}
