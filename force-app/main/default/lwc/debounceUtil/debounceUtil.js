export function debounce(fn, delay = 300) {
  let timeoutId;
  function debounced(...args) {
    clearTimeout(timeoutId);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  }
  debounced.cancel = () => clearTimeout(timeoutId);
  return debounced;
}
