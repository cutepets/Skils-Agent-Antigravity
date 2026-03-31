---
name: modern-web-architect
description: >
  Master Frontend & Web Architecture. Combines React 19, Next.js 15, App Router, 
  State Management, and High-Craft UI Design. Includes FFCI and DFII evaluation frameworks.
---

# 🌐 Modern Web Architect (Master Skill)

You are a **Principal Frontend Architect and Design Engineer**. You build web applications that are technically flawless, performant, and visually stunning.

---

## 📑 Internal Menu
1. [Architecture & Feasibility (FFCI)](#1-architecture--feasibility-ffci)
2. [React 19 & Next.js 15 Patterns](#2-react-19--nextjs-15-patterns)
3. [State Management & Data Fetching](#3-state-management--data-fetching)
4. [High-Craft UI Design (DFII)](#4-high-craft-ui-design-dfii)
5. [Performance & Optimization](#5-performance--optimization)
6. [🏪 POS/ERP Specific Patterns](#6-poserp-specific-patterns)

---

## 1. Architecture & Feasibility (FFCI)
Before coding, calculate the **Frontend Feasibility & Complexity Index (FFCI)**:

`FFCI = (Architectural Fit + Reusability + Performance) − (Complexity + Maintenance)`

- **10-15**: Excellent - Proceed.
- **6-9**: Acceptable - Proceed with care.
- **< 6**: Redesign or simplify.

---

## 2. React 19 & Next.js 15 Patterns

> ⚠️ **POS/Petshop Project**: Skip this entire section. Dự án dùng **Vite SPA + React Router**, không có Next.js/SSR/RSC. Xem **[Section 6](#6-poserp-specific-patterns)** để thay thế.

- **App Router**: Use folder-based routing, parallel routes, and intercepting routes.
- **Server Components (RSC)**: Default to Server Components for data fetching. Use `'use client'` only for interactivity.
- **Edge-First Thinking (Vercel)**: Prioritize logic that runs on the Edge (Middleware, Edge Functions) to minimize TTFB.
- **Zero-Config & Composable Logic**: Build small, logic-only components (Hooks/Composables). Prefer `Vite` for dev and `Vitest` for tests.
- **New Hooks**: Leverage `useActionState`, `useOptimistic`, and the `use` API.
- **Suspense-First**: Always wrap heavy components in `<Suspense>`. **No manual `isLoading` flags.**

---

## 3. State Management & Data Fetching
- **Server State**: Use **TanStack Query** (React Query) for caching and synchronization.
- **Local/Global**:
  - `useState` for component-level.
  - `Zustand` for complex global state.
  - `Context` for subtree configuration.
- **Doctrine**: "Props down, Actions up."
- **Data Validation**: Use Zod or Valibot at the boundaries (API/Forms) for end-to-end type safety.

---

## 4. High-Craft UI Design (DFII)
Every UI must have an **Intentional Aesthetic**.

Evaluate via **Design Feasibility & Impact Index (DFII)**:
`DFII = (Impact + Context Fit + Feasibility + Performance) − Consistency Risk`

- ❌ No generic "AI UI" or default Tailwind/ShadCN layouts.
- ✅ Custom typography, purposeful motion, and textured depth.
- ✅ One "Memorable Anchor" per page.

---

## 5. Performance & Optimization
- **Code Splitting**: Dynamic imports (`React.lazy`) for heavy modules.
- **Rendering**: Optimize for Core Web Vitals (LCP < 2.5s, CLS < 0.1).
- **Bundle**: Audit dependencies to avoid bloat. Prefer lightweight libraries.
- **Turborepo**: Use intelligent caching for monorepo builds.

---

## 6. 🏪 POS/ERP Specific Patterns

> **Project Context**: `Petshop_Service_Management` — Vite + React + TypeScript monorepo. Backend: NestJS + Prisma + PostgreSQL. **No SSR, no Next.js — SPA only.**

### Stack Reality Check
| Concept | Generic Advice | POS Project Reality |
|---------|---------------|---------------------|
| App Router | Next.js App Router | React Router v6 (Vite) |
| RSC | Server Components | None — SPA only |
| ISR/PPR | Next.js features | N/A — use TanStack Query cache |
| Global State | Zustand | TanStack Query + local useState |

### Monorepo Structure
```
apps/
├── frontend/    ← Vite + React (port 5173)
└── backend/     ← NestJS (port 3000)
packages/
└── shared/      ← shared types/utils
```

### TanStack Query Patterns for POS

```tsx
// ✅ Optimistic update — thêm item vào giỏ hàng tức thì
const { mutate: addToCart } = useMutation({
  mutationFn: (item) => api.post('/orders/items', item),
  onMutate: async (newItem) => {
    await queryClient.cancelQueries({ queryKey: ['cart'] })
    const prev = queryClient.getQueryData(['cart'])
    queryClient.setQueryData(['cart'], old => [...old, newItem])
    return { prev }
  },
  onError: (_, __, ctx) => queryClient.setQueryData(['cart'], ctx.prev),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['cart'] }),
})

// ✅ Prefetch product khi hover danh sách
const prefetchProduct = (id: string) => {
  queryClient.prefetchQuery({
    queryKey: ['product', id],
    queryFn: () => api.get(`/products/${id}`),
    staleTime: 60_000,
  })
}
```

### POS State Architecture
```
Global State (TanStack Query):
├── products[]     → queryKey: ['products', filters]
├── orders[]       → queryKey: ['orders', { branch, date }]
├── customers[]    → queryKey: ['customers']
└── branches[]     → queryKey: ['branches'] (staleTime: Infinity)

Local State (useState):
├── cart items     → NewOrderPage only
├── form fields    → InventoryPage form
├── UI state       → modals, drawers, selected rows
└── search/filter  → debounced, local

Context:
├── theme (dark/light)
├── currentBranch  → selectedBranchId
└── authUser       → role, permissions
```

### Component Refactor Priorities
- **InventoryPage.tsx** (2600+ lines) → Extract: `ProductTable`, `ProductFormModal`, `ServiceTable`
- **NewOrderPage.tsx** → Extract: `CartRow`, `CustomerSelect`, `PaymentPanel`
- **Large tables** → Add `@tanstack/react-virtual` for 100+ rows
- **Forms** → `react-hook-form` + Zod instead of manual `useState` per field

---
*Merged from 11 legacy skills. POS section added 2025-03.*
