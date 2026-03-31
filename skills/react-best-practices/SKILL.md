---
name: react-best-practices
description: React và Next.js performance optimization guidelines từ Vercel Engineering. Dùng khi viết, review, hoặc refactor React/Vite/Next.js code. Kích hoạt khi làm việc với React components, data fetching, bundle optimization, hoặc performance improvements. Áp dụng cho cả Vite + React và Next.js.
license: MIT
metadata:
  author: vercel
  source: https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices
  version: "1.0.0"
---

Comprehensive performance optimization guide cho React applications, viết bởi Vercel Engineering. Gồm 67 rules chia thành 8 categories, ưu tiên theo impact để guide automated refactoring và code generation.

## When to Apply

- Viết mới React components / Vite pages
- Implement data fetching (client hoặc server-side)
- Review code for performance issues
- Refactor existing React code
- Optimize bundle size hoặc load times
- Review re-render patterns

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Eliminating Waterfalls | CRITICAL | `async-` |
| 2 | Bundle Size Optimization | CRITICAL | `bundle-` |
| 3 | Server-Side Performance | HIGH | `server-` |
| 4 | Client-Side Data Fetching | MEDIUM-HIGH | `client-` |
| 5 | Re-render Optimization | MEDIUM | `rerender-` |
| 6 | Rendering Performance | MEDIUM | `rendering-` |
| 7 | JavaScript Performance | LOW-MEDIUM | `js-` |
| 8 | Advanced Patterns | LOW | `advanced-` |

### 1. Eliminating Waterfalls (CRITICAL)
- `async-cheap-condition-before-await` — Check cheap sync conditions trước khi await
- `async-defer-await` — Move await vào branches nơi thực sự cần dùng
- `async-parallel` — Dùng `Promise.all()` cho independent operations
- `async-api-routes` — Start promises sớm, await trễ trong API routes
- `async-suspense-boundaries` — Dùng Suspense để stream content

### 2. Bundle Size Optimization (CRITICAL)
- `bundle-barrel-imports` — Import trực tiếp, tránh barrel files (`index.ts`)
- `bundle-dynamic-imports` — Dùng dynamic `import()` cho heavy components
- `bundle-defer-third-party` — Load analytics/logging sau khi hydration xong
- `bundle-conditional` — Load modules chỉ khi feature được activate
- `bundle-preload` — Preload on hover/focus cho perceived speed

### 3. Re-render Optimization (MEDIUM)
- `rerender-memo` — Extract expensive work vào memoized components
- `rerender-dependencies` — Dùng primitive dependencies trong effects
- `rerender-derived-state-no-effect` — Derive state during render, không dùng effects
- `rerender-functional-setstate` — Dùng functional setState cho stable callbacks
- `rerender-no-inline-components` — Không define components bên trong components
- `rerender-use-ref-transient-values` — Dùng refs cho transient frequent values

### 4. Client-Side Data Fetching (MEDIUM-HIGH)
- `client-swr-dedup` — Dùng SWR/TanStack Query để automatic request deduplication
- `client-event-listeners` — Deduplicate global event listeners
- `client-passive-event-listeners` — Dùng passive listeners cho scroll events

### 5. Rendering Performance (MEDIUM)
- `rendering-content-visibility` — Dùng content-visibility cho long lists
- `rendering-hoist-jsx` — Extract static JSX ra ngoài components
- `rendering-conditional-render` — Dùng ternary, không dùng `&&` cho conditionals có null risk
- `rendering-usetransition-loading` — Prefer useTransition cho loading state

### 6. JavaScript Performance (LOW-MEDIUM)
- `js-index-maps` — Build Map cho repeated lookups (O(1) vs O(n))
- `js-set-map-lookups` — Dùng Set/Map cho O(1) lookups
- `js-early-exit` — Return early từ functions
- `js-combine-iterations` — Combine multiple filter/map thành một loop
- `js-request-idle-callback` — Defer non-critical work đến browser idle time

### 7. Advanced Patterns (LOW)
- `advanced-use-latest` — useLatest cho stable callback refs

## Anti-Patterns cần tránh trong dự án này

```tsx
// ❌ BAD: Barrel import (makes bundle huge)
import { Button, Input, Modal } from '@components'

// ✅ GOOD: Direct import
import { Button } from '@components/Button'

// ❌ BAD: N+1 style sequential fetches
const user = await fetchUser(id)
const orders = await fetchOrders(user.id)

// ✅ GOOD: Parallel fetch
const [user, orders] = await Promise.all([fetchUser(id), fetchOrders(id)])

// ❌ BAD: Component defined inside component (re-created each render)
function Parent() {
  function Child() { return <div/> }
  return <Child />
}

// ✅ GOOD: Define outside
function Child() { return <div/> }
function Parent() { return <Child /> }
```

## Áp dụng với TanStack Query (stack hiện tại)

```tsx
// ❌ BAD: Waterfall queries
function OrderDetail({ orderId }) {
  const { data: order } = useQuery(...)           // waits
  const { data: customer } = useQuery(...)        // waits for order first
}

// ✅ GOOD: Parallel queries
function OrderDetail({ orderId }) {
  const [orderQuery, customerQuery] = useQueries({
    queries: [
      { queryKey: ['order', orderId] },
      { queryKey: ['customer', orderId] },  // fetch simultaneously
    ]
  })
}
```

## Compatibility Notes
- Rules áp dụng cho **Vite + React** (stack hiện tại)
- Các `server-*` rules áp dụng khi migrate sang Next.js App Router
- `react19-*` rules chỉ áp dụng nếu dùng React 19+
