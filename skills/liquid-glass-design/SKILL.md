---
name: liquid-glass-design
description: >
  Glassmorphism design system cho web (React + CSS/TailwindCSS). Inspired by
  Apple iOS 26 Liquid Glass — blur, transparency, reflection effects cho premium
  UI. Dùng cho /ui-ux-pro-max workflow và bất kỳ khi nào cần premium glass UI.
---

# Liquid Glass Design — Web Implementation

Implement Apple-inspired Liquid Glass effects cho React web apps với CSS backdrop-filter,
glassmorphism patterns, và smooth transitions.

## Core Physics của Liquid Glass

```
Blur    → backdrop-filter: blur(Xpx)     — blurs content behind element
Tint    → background: rgba(r,g,b,0.1-0.3) — subtle color overlay
Border  → 1-2px rgba(255,255,255,0.2)   — light edge highlight
Shadow  → subtle box-shadow for depth
Refract → ::before pseudo với gradient   — light refraction effect
```

## CSS Design Tokens

```css
/* Liquid Glass CSS Variables */
:root {
  /* Glass surfaces */
  --glass-bg:              rgba(255, 255, 255, 0.08);
  --glass-bg-hover:        rgba(255, 255, 255, 0.14);
  --glass-bg-active:       rgba(255, 255, 255, 0.20);
  --glass-bg-prominent:    rgba(255, 255, 255, 0.18);

  /* Blur intensity */
  --glass-blur-sm:         blur(8px);
  --glass-blur-md:         blur(16px);
  --glass-blur-lg:         blur(24px);
  --glass-blur-xl:         blur(40px);

  /* Borders */
  --glass-border:          1px solid rgba(255, 255, 255, 0.18);
  --glass-border-prominent: 1px solid rgba(255, 255, 255, 0.30);

  /* Shadows */
  --glass-shadow-sm:       0 2px 8px rgba(0, 0, 0, 0.15);
  --glass-shadow-md:       0 8px 32px rgba(0, 0, 0, 0.20);
  --glass-shadow-lg:       0 16px 60px rgba(0, 0, 0, 0.25);

  /* Corner radius */
  --glass-radius-sm:       12px;
  --glass-radius-md:       20px;
  --glass-radius-lg:       28px;
  --glass-radius-pill:     100px;
}
```

## Core Glass Mixins (TailwindCSS + Custom CSS)

### 1. Base Glass Card

```css
.glass-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur-md);
  -webkit-backdrop-filter: var(--glass-blur-md);
  border: var(--glass-border);
  border-radius: var(--glass-radius-md);
  box-shadow: var(--glass-shadow-md);
  position: relative;
  overflow: hidden;
}

/* Subtle light refraction on top */
.glass-card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    135deg,
    rgba(255, 255, 255, 0.12) 0%,
    transparent 50%,
    rgba(255, 255, 255, 0.04) 100%
  );
  pointer-events: none;
}
```

### 2. Interactive Glass Button

```css
.glass-button {
  background: rgba(255, 255, 255, 0.10);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.20);
  border-radius: 100px; /* pill */
  padding: 10px 20px;
  color: white;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1); /* spring */
  position: relative;
  overflow: hidden;
}

.glass-button:hover {
  background: rgba(255, 255, 255, 0.18);
  border-color: rgba(255, 255, 255, 0.35);
  transform: translateY(-1px) scale(1.02);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
}

.glass-button:active {
  transform: translateY(0) scale(0.97);
  background: rgba(255, 255, 255, 0.08);
}
```

### 3. Prominent Glass (Tinted)

```css
.glass-prominent {
  background: rgba(99, 102, 241, 0.25); /* tinted với primary color */
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(99, 102, 241, 0.40);
  border-radius: var(--glass-radius-md);
  box-shadow:
    0 0 0 1px rgba(99, 102, 241, 0.20) inset,
    0 8px 32px rgba(99, 102, 241, 0.20);
}
```

## React Component Patterns

### GlassCard Component

```tsx
// components/ui/GlassCard.tsx
import { forwardRef } from 'react';
import { cn } from '@/lib/utils';

interface GlassCardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'prominent' | 'subtle';
  blur?: 'sm' | 'md' | 'lg' | 'xl';
  interactive?: boolean;
}

const blurMap = {
  sm: 'backdrop-blur-sm',   // 4px
  md: 'backdrop-blur-md',   // 12px
  lg: 'backdrop-blur-lg',   // 16px
  xl: 'backdrop-blur-xl',   // 24px
};

const GlassCard = forwardRef<HTMLDivElement, GlassCardProps>(
  ({ className, variant = 'default', blur = 'md', interactive = false, children, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          // Base glass
          'relative overflow-hidden rounded-2xl',
          blurMap[blur],
          'border border-white/[0.15]',
          'shadow-[0_8px_32px_rgba(0,0,0,0.20)]',

          // Variants
          variant === 'default' && 'bg-white/[0.08]',
          variant === 'prominent' && 'bg-white/[0.18] border-white/[0.30]',
          variant === 'subtle' && 'bg-white/[0.04]',

          // Interactive
          interactive && [
            'cursor-pointer',
            'transition-all duration-200',
            'hover:bg-white/[0.14] hover:border-white/[0.25]',
            'hover:shadow-[0_12px_40px_rgba(0,0,0,0.25)]',
            'hover:-translate-y-0.5',
            'active:translate-y-0 active:bg-white/[0.06]',
          ],

          className,
        )}
        {...props}
      >
        {/* Light refraction */}
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0 bg-gradient-to-br from-white/[0.10] via-transparent to-white/[0.03]"
        />
        {children}
      </div>
    );
  }
);

GlassCard.displayName = 'GlassCard';
export { GlassCard };
```

### GlassButton Component

```tsx
// components/ui/GlassButton.tsx
import { ButtonHTMLAttributes, forwardRef } from 'react';
import { cn } from '@/lib/utils';

interface GlassButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'prominent' | 'ghost';
}

const GlassButton = forwardRef<HTMLButtonElement, GlassButtonProps>(
  ({ className, variant = 'default', children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          // Base — pill shape
          'relative overflow-hidden rounded-full px-5 py-2.5',
          'text-sm font-medium text-white',
          'backdrop-blur-md',
          'border border-white/[0.18]',
          'transition-all duration-200',
          'active:scale-[0.97]',
          'disabled:opacity-50 disabled:cursor-not-allowed',

          // Spring scale on hover using custom cubic-bezier
          '[transition-timing-function:cubic-bezier(0.34,1.56,0.64,1)]',

          // Variants
          variant === 'default' && [
            'bg-white/[0.10]',
            'hover:bg-white/[0.18] hover:border-white/[0.30]',
            'hover:-translate-y-px hover:scale-[1.02]',
            'hover:shadow-[0_8px_24px_rgba(0,0,0,0.25)]',
          ],
          variant === 'prominent' && [
            'bg-indigo-500/[0.30] border-indigo-400/[0.40]',
            'hover:bg-indigo-500/[0.45]',
            'shadow-[0_0_20px_rgba(99,102,241,0.25)]',
          ],
          variant === 'ghost' && [
            'bg-transparent border-transparent',
            'hover:bg-white/[0.08]',
          ],

          className,
        )}
        {...props}
      >
        {/* Shine effect */}
        <span
          aria-hidden
          className="pointer-events-none absolute inset-0 rounded-full bg-gradient-to-b from-white/[0.15] to-transparent"
        />
        <span className="relative z-10">{children}</span>
      </button>
    );
  }
);

GlassButton.displayName = 'GlassButton';
export { GlassButton };
```

### GlassNavbar

```tsx
// components/layout/GlassNavbar.tsx
export function GlassNavbar({ children }: { children: React.ReactNode }) {
  return (
    <nav className={cn(
      'sticky top-0 z-50',
      'mx-4 mt-3',                    // floating with margin
      'rounded-2xl',
      'bg-black/[0.40] backdrop-blur-xl',
      'border border-white/[0.12]',
      'shadow-[0_4px_24px_rgba(0,0,0,0.35)]',
      'px-6 py-3',
      'flex items-center justify-between',
    )}>
      {children}
    </nav>
  );
}
```

## Morphing & Transitions

```css
/* Smooth glass morph between states */
.glass-morph {
  transition:
    background-color 0.3s ease,
    backdrop-filter 0.3s ease,
    border-color 0.3s ease,
    box-shadow 0.3s ease,
    transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}

/* Ripple on active — glass variant */
.glass-button::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: radial-gradient(circle at center, rgba(255,255,255,0.25), transparent 60%);
  opacity: 0;
  transform: scale(0.8);
  transition: opacity 0.3s, transform 0.4s;
}

.glass-button:active::after {
  opacity: 1;
  transform: scale(1.5);
  transition: opacity 0s, transform 0s;
}
```

## Dark/Light Mode Adaptation

```css
/* Light mode — darker glass */
@media (prefers-color-scheme: light) {
  :root {
    --glass-bg: rgba(0, 0, 0, 0.06);
    --glass-bg-hover: rgba(0, 0, 0, 0.10);
    --glass-border: 1px solid rgba(0, 0, 0, 0.10);
  }
}
```

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| `backdrop-blur` via Tailwind | Cleaner than custom CSS, responsive |
| Pill shape (`rounded-full`) | Apple-like — feels more premium |
| `::before` refraction layer | Mimics real glass light interaction |
| Spring easing (`cubic-bezier(0.34,1.56,0.64,1)`) | Alive, not robotic |
| `overflow: hidden` on container | Clips refraction/shine properly |
| Separation of content z-index | `relative z-10` keeps content above effects |

## Anti-Patterns

- ❌ `opacity` để tạo glass — mờ cả content bên trong
- ❌ Quá nhiều blur layers chồng nhau — performance hit
- ❌ Glass trên glass mà không có dark background phía sau — invisible
- ❌ Quên `-webkit-backdrop-filter` — Safari không support `backdrop-filter` alone
- ❌ `transition` không có `will-change` cho heavy blur animations

## When to Use

- Premium dashboards, hero sections, modal dialogs
- Navigation bars (floating pill style)
- Action buttons và CTAs
- Cards với content phía sau là gradient/image
- Bất kỳ context nào cần UI cảm giác premium và hiện đại

## Performance Notes

- `backdrop-filter: blur()` là **GPU-intensive** — dùng `will-change: transform` cho animated elements
- Limit tối đa 3-4 glass layers visible cùng lúc
- Trên mobile: giảm blur xuống `blur(8px)` để smooth
- Test trên Safari — cần prefix `-webkit-backdrop-filter`
