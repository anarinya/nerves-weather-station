export const debounce = (ctx, callback, wait) => {
  let timeout;

  return (...args) => {
    if (timeout) clearTimeout(timeout);

    timeout = setTimeout(() => {
      callback.apply(ctx, args);
    }, wait)
  }
}