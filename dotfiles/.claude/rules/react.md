---
paths:
  - *.tsx
---

Functional components + hooks only. No class components.
No `any`; explicit prop interfaces; `unknown`+narrowing for external/untyped data.
List keys: stable unique IDs only, never array index.
No inline object/array/fn literals in JSX props of memoized children.
Semantic HTML first; ARIA only when native semantics are insufficient; no click-only divs.
`dangerouslySetInnerHTML` only with sanitized input.

**Hooks**
Never inside conditions or loops.
`useEffect`: external sync/subscriptions only — not data fetching, not derived state.
`useMemo`/`useCallback`: referential stability or measured bottleneck only; don't default-wrap everything.
Extract logic reused ≥2x into a custom hook.

**State**
Local: `useState`/`useReducer`. Complex global client state: Zustand or Redux Toolkit. Server/async data: TanStack Query or the framework's data layer — never manual `useEffect`+`useState` fetch.
Derive values inline or via `useMemo`; never mirror props or state into a separate `useState`.

**Next.js App Router** (skip if project uses Vite/CRA/TanStack Start)
Server Components by default. Add `"use client"` only at leaf nodes that need hooks, browser APIs, or event handlers — push it as far down the tree as possible.
Fetch in Server Components; pass data as props. Mutations go through server actions, not client-side fetch to API routes.
`loading.tsx` + `error.tsx` per route segment; `<Suspense>` for component-level async boundaries.

**Patterns**
`lazy()` + `<Suspense>` for routes and heavy components.
Composition via `children`/slots over prop drilling or conditional prop sprawl.
One component per file; co-locate its hooks, styles, and tests by feature, not by type.
