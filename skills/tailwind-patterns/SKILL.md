---
name: tailwind-patterns
description: Tailwind CSS v4 principles. CSS-first configuration, container queries, modern patterns, design token architecture.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Tailwind CSS Patterns (v4 - 2025)

> Modern utility-first CSS with CSS-native configuration.

---

## 1. Tailwind v4 Architecture

### What Changed from v3

| v3 (Legacy) | v4 (Current) |
|-------------|--------------|
| `tailwind.config.js` | CSS-based `@theme` directive |
| PostCSS plugin | Oxide engine (10x faster) |
| JIT mode | Native, always-on |
| Plugin system | CSS-native features |
| `@apply` directive | Still works, discouraged |

### v4 Core Concepts

| Concept | Description |
|---------|-------------|
| **CSS-first** | Configuration in CSS, not JavaScript |
| **Oxide Engine** | Rust-based compiler, much faster |
| **Native Nesting** | CSS nesting without PostCSS |
| **CSS Variables** | All tokens exposed as `--*` vars |

---

## 2. CSS-Based Configuration

### Theme Definition

```css
@theme {
  /* Colors - use semantic names */
  --color-primary: oklch(0.7 0.15 250);
  --color-surface: oklch(0.98 0 0);
  --color-surface-dark: oklch(0.15 0 0);
  
  /* Spacing scale */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}
```

---

## 3. Container Queries (v4 Native)

| Type | Responds To |
|------|-------------|
| **Breakpoint** (`md:`) | Viewport width |
| **Container** (`@container`) | Parent element width |

| Scenario | Use |
|----------|-----|
| Page-level layouts | Viewport breakpoints |
| Component-level responsive | Container queries |
| Reusable components | Container queries (context-independent) |

---

## 4. Responsive Design

| Prefix | Min Width | Target |
|--------|-----------|--------|
| (none) | 0px | Mobile-first base |
| `sm:` | 640px | Large phone / small tablet |
| `md:` | 768px | Tablet |
| `lg:` | 1024px | Laptop |
| `xl:` | 1280px | Desktop |
| `2xl:` | 1536px | Large desktop |

---

## 5. Dark Mode

| Method | Behavior | Use When |
|--------|----------|----------|
| `class` | `.dark` class toggles | Manual theme switcher |
| `media` | Follows system preference | No user control |
| `selector` | Custom selector (v4) | Complex theming |

---

## 6. Modern Color System

| Format | Advantage |
|--------|-----------|
| **OKLCH** | Perceptually uniform, better for design |
| **HSL** | Intuitive hue/saturation |
| **RGB** | Legacy compatibility |

| Layer | Example | Purpose |
|-------|---------|---------|
| **Primitive** | `--blue-500` | Raw color values |
| **Semantic** | `--color-primary` | Purpose-based naming |
| **Component** | `--button-bg` | Component-specific |

---

## 7. Anti-Patterns

| Don't | Do |
|-------|-----|
| Arbitrary values everywhere | Use design system scale |
| `!important` | Fix specificity properly |
| Inline `style=` | Use utilities |
| Duplicate long class lists | Extract component |
| Mix v3 config with v4 | Migrate fully to CSS-first |
| Use `@apply` heavily | Prefer components |

---

## 8. 🏪 POS Migration Guide (Tailwind v4 Path)

> **Current status**: Petshop project uses **Vanilla CSS + HSL CSS Variables** (no Tailwind). This section defines the migration path IF you decide to adopt Tailwind v4 in the future.

### Should You Migrate?

| Factor | Current (Vanilla CSS) | With Tailwind v4 |
|--------|-----------------------|------------------|
| Setup complexity | Low | Medium |
| Design token control | Full (HSL vars) | Full (OKLCH + @theme) |
| Dev speed | Medium | High |
| Bundle size | Small | Small (purged) |
| Dark mode | Manual CSS vars | `dark:` prefix |
| **Recommendation** | ✅ Keep as-is for now | Consider if team grows |

### Current CSS Variable Pattern (Preserve This in Migration)

```css
/* Current: index.css */
:root {
  --primary-500: hsl(213, 90%, 52%);
  --background: hsl(0, 0%, 100%);
  --foreground: hsl(222, 47%, 11%);
  --border: hsl(220, 13%, 91%);
}
.dark {
  --background: hsl(222, 47%, 8%);
  --foreground: hsl(210, 40%, 98%);
}

/* Migration to Tailwind v4 @theme: */
@theme {
  --color-primary: oklch(0.62 0.19 250);
  --color-background: oklch(1 0 0);    /* light */
  --color-foreground: oklch(0.2 0.03 264);
  --color-border: oklch(0.9 0.01 264);
}
```

### POS-Specific Component Patterns (When Using Tailwind)

```tsx
// Table row — POS inventory
<tr className="border-b border-border hover:bg-primary-50/50 transition-colors">
  <td className="px-3 py-2 text-sm font-medium">{product.name}</td>
  <td className="px-3 py-2 text-xs text-muted-foreground">{product.sku}</td>
  <td className="px-3 py-2 text-right tabular-nums">{formatCurrency(product.price)}</td>
</tr>

// Status badge — order status
const statusClass = {
  pending:   'bg-yellow-100 text-yellow-800',
  confirmed: 'bg-blue-100 text-blue-800',
  completed: 'bg-green-100 text-green-800',
  cancelled: 'bg-red-100 text-red-800',
}[order.status]

<span className={`inline-flex px-2 py-0.5 text-xs font-medium rounded-full ${statusClass}`}>
  {order.status}
</span>
```

### Migration Checklist (When Ready)
- [ ] Install Tailwind v4: `npm install tailwindcss @tailwindcss/vite`
- [ ] Add Vite plugin in `vite.config.ts`
- [ ] Map current HSL vars → OKLCH `@theme` tokens
- [ ] Replace `className="..."` strings with Tailwind utilities
- [ ] Remove old CSS classes from `index.css`
- [ ] Test dark mode with `dark:` prefix
- [ ] Audit bundle size (should decrease — purging removes unused styles)

---

> **Remember:** Tailwind v4 is CSS-first. Embrace CSS variables, container queries, and native features. **For Petshop: only migrate when there's a clear benefit — current CSS variable system works well.**
