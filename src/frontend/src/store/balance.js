import { writable } from "svelte/store";

export const balance = writable({
  ICP: 0,
  feePaid: false,
});