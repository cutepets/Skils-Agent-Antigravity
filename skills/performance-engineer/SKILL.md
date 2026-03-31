---
name: performance-engineer
description: >
  Expert performance engineer specializing in modern observability, 
  application optimization, and scalable system performance. Masters 
  OpenTelemetry, distributed tracing, load testing, multi-tier caching, 
  Core Web Vitals, and performance monitoring.
---

# ⚡ Performance Engineer Master Kit

You are a **Principal Performance Architect and Site Reliability Engineer**. Your mission is to eliminate bottlenecks, minimize latency, and ensure systems scale gracefully under load.

---

## 📑 Internal Menu
1. [Core Web Vitals & Frontend Speed](#1-core-web-vitals--frontend-speed)
2. [Backend & Database Optimization](#2-backend--database-optimization)
3. [Modern Observability (OpenTelemetry)](#3-modern-observability-opentelemetry)
4. [Load Testing & Stress Validation](#4-load-testing--stress-validation)
5. [Reliability (SLO/SLI) & Error Budgets](#5-reliability-slosli--error-budgets)
6. [🏪 POS/ERP Performance Patterns](#6-poserp-performance-patterns)

---

## 1. Core Web Vitals & Frontend Speed
- **LCP (Largest Contentful Paint)**: < 2.5s. Optimize images, remove render-blocking resources.
- **CLS (Cumulative Layout Shift)**: < 0.1. Set dimensions for media, avoid manual DOM jumps.
- **INP (Interaction to Next Paint)**: < 200ms. Break up long tasks, optimize event handlers.
- **Bundle Optimization**: 
  - Code splitting (Dynamic imports).
  - Tree-shaking (ESM imports).
  - Minification & Compression (Brotli/Gzip).

---

## 2. Backend & Database Optimization
- **Caching**: Multi-tier strategy (Browser → CDN → Edge → Application → Redis).
- **Queries**: Optimize N+1 issues, implement proper indexing, use Explain Plan.
- **Async Processing**: Offload heavy tasks to background workers (BullMQ, Sidekiq).
- **Resource Limits**: Tune CPU/Memory limits in Kubernetes (VPA/HPA).

---

## 3. Modern Observability (OpenTelemetry)
- **Tracing**: Implement distributed tracing across microservices to find path latency.
- **Metrics**: Standardize golden signals: Latency, Traffic, Errors, and Saturation.
- **Log Correlation**: Attach trace IDs to every log entry for unified debugging.

---

## 4. Load Testing & Stress Validation
- **Tools**: Use k6, JMeter, or Locust.
- **Types**: 
  - *Load Test*: Normal traffic levels.
  - *Stress Test*: Identify the breaking point.
  - *Soak Test*: Check for memory leaks over long periods.
- **Baselines**: Always compare results against a stable baseline.

---

## 5. Reliability (SLO/SLI) & Error Budgets
- **SLI (Indicator)**: What you measure (e.g., successful request %).
- **SLO (Objective)**: The target (e.g., 99.9% success rate).
- **Error Budget**: The allowed downtime/errors before deployments stop to focus on reliability.

---

## 6. 🏪 POS/ERP Performance Patterns

> **Project Context**: Petshop_Service_Management — Vite SPA + NestJS API. Main bottlenecks: InventoryPage (500+ products), NewOrderPage (real-time cart), large customer list.

### Priority Issues (Fix These First)

| Issue | Location | Impact | Fix |
|-------|----------|--------|-----|
| 500+ products in DOM | InventoryPage | High | Virtual scroll |
| Re-render on every cart update | NewOrderPage | Medium | `React.memo` + `useCallback` |
| Product search on every keystroke | InventoryPage | Medium | `useDebouncedValue` (300ms) |
| InventoryPage.tsx 2600 lines | All | High | Code split lazy load |
| API calls without cache | All pages | Medium | TanStack Query staleTime |

### Virtual Scrolling — InventoryPage

```bash
npm install @tanstack/react-virtual
```

```tsx
import { useVirtualizer } from '@tanstack/react-virtual'

function ProductTable({ products }: { products: Product[] }) {
  const parentRef = useRef<HTMLDivElement>(null)
  
  const virtualizer = useVirtualizer({
    count: products.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 52, // row height px
    overscan: 5,
  })

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <ProductRow
            key={virtualRow.index}
            product={products[virtualRow.index]}
            style={{ transform: `translateY(${virtualRow.start}px)`, position: 'absolute', width: '100%' }}
          />
        ))}
      </div>
    </div>
  )
}
```

### TanStack Query Cache Strategy

```tsx
// Cấu hình staleTime theo mức độ thay đổi
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,    // 30s mặc định
      gcTime: 5 * 60_000,   // 5 phút trong cache
    },
  },
})

// Branches thay đổi rất ít → cache lâu hơn
useQuery({
  queryKey: ['branches'],
  queryFn: fetchBranches,
  staleTime: Infinity,  // không refetch tự động
})

// Products inventory → fresher
useQuery({
  queryKey: ['products', filters],
  queryFn: () => fetchProducts(filters),
  staleTime: 60_000,  // 1 phút
})
```

### Debounce Search

```tsx
import { useDeferredValue } from 'react'

function SearchInput() {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)  // React 18+ built-in

  const results = useMemo(
    () => products.filter(p => p.name.includes(deferredQuery)),
    [deferredQuery, products]
  )
  // ...
}
```

### Code Splitting cho Large Pages

```tsx
// App.tsx — lazy load heavy pages
const InventoryPage = lazy(() => import('./pages/InventoryPage'))
const ReportsPage = lazy(() => import('./pages/ReportsPage'))

// Wrap với Suspense
<Suspense fallback={<PageSkeleton />}>
  <InventoryPage />
</Suspense>
```

### React.memo cho Cart Rows

```tsx
// CartRow re-renders khi bất kỳ item nào thay đổi → tối ưu với memo
const CartRow = React.memo(({ item, onQtyChange, onRemove }) => {
  return (
    <tr>
      <td>{item.name}</td>
      <td>
        <input value={item.qty} onChange={e => onQtyChange(item.id, +e.target.value)} />
      </td>
    </tr>
  )
}, (prev, next) => prev.item === next.item)  // custom comparison
```

### Lighthouse Audit
```bash
python .agent/skills/performance-engineer/scripts/lighthouse_check.py http://localhost:5173
```

---
*Merged from 7 legacy skills. POS section added 2025-03.*
