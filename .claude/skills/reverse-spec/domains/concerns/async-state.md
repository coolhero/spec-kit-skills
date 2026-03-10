# Concern: async-state (reverse-spec)

> State management detection. Identifies reactive state patterns in the codebase.

## R1. Detection Signals
- State libraries: `zustand`, `redux`, `@reduxjs/toolkit`, `mobx`, `pinia`, `vuex`, `recoil`, `jotai`
- React context with `useReducer` pattern
- Store files: `store/`, `stores/`, `*Store.ts`, `*Slice.ts`
