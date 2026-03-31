---
name: frontend-design
description: Design thinking and decision-making for web UI. Use when designing components, layouts, color schemes, typography, or creating aesthetic interfaces. Teaches principles, not fixed values.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Frontend Design System

> **Philosophy:** Every pixel has purpose. Restraint is luxury. User psychology drives decisions.
> **Core Principle:** THINK, don't memorize. ASK, don't assume.

---

## 🎯 Selective Reading Rule (MANDATORY)

**Read REQUIRED files always, OPTIONAL only when needed:**

| File | Status | When to Read |
|------|--------|--------------|
| [ux-psychology.md](ux-psychology.md) | 🔴 **REQUIRED** | Always read first! |
| [color-system.md](color-system.md) | ⚪ Optional | Color/palette decisions |
| [typography-system.md](typography-system.md) | ⚪ Optional | Font selection/pairing |
| [visual-effects.md](visual-effects.md) | ⚪ Optional | Glassmorphism, shadows, gradients |
| [animation-guide.md](animation-guide.md) | ⚪ Optional | Animation needed |
| [motion-graphics.md](motion-graphics.md) | ⚪ Optional | Lottie, GSAP, 3D |
| [decision-trees.md](decision-trees.md) | ⚪ Optional | Context templates |

> 🔴 **ux-psychology.md = ALWAYS READ. Others = only if relevant.**

---

## 🔧 Runtime Scripts

**Execute these for audits (don't read, just run):**

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/ux_audit.py` | UX Psychology & Accessibility Audit | `python scripts/ux_audit.py <project_path>` |

---

## ⚠️ CRITICAL: ASK BEFORE ASSUMING (MANDATORY)

> **STOP! If the user's request is open-ended, DO NOT default to your favorites.**

### When User Prompt is Vague, ASK:

**Color not specified?** Ask:
> "What color palette do you prefer? (blue/green/orange/neutral/other?)"

**Style not specified?** Ask: 
> "What style are you going for? (minimal/bold/retro/futuristic/organic?)"

**Layout not specified?** Ask:
> "Do you have a layout preference? (single column/grid/asymmetric/full-width?)"

### ⛔ DEFAULT TENDENCIES TO AVOID (ANTI-SAFE HARBOR):

| AI Default Tendency | Why It's Bad | Think Instead |
|---------------------|--------------|---------------|
| **Bento Grids (Modern Cliché)** | Used in every AI design | Why does this content NEED a grid? |
| **Hero Split (Left/Right)** | Predictable & Boring | How about Massive Typography or Vertical Narrative? |
| **Mesh/Aurora Gradients** | The "new" lazy background | What's a radical color pairing? |
| **Glassmorphism** | AI's idea of "premium" | How about solid, high-contrast flat? |
| **Deep Cyan / Fintech Blue** | Safe harbor from purple ban | Why not Red, Black, or Neon Green? |
| **"Orchestrate / Empower"** | AI-generated copywriting | How would a human say this? |
| Dark background + neon glow | Overused, "AI look" | What does the BRAND actually need? |
| **Rounded everything** | Generic/Safe | Where can I use sharp, brutalist edges? |

> 🔴 **"Every 'safe' structure you choose brings you one step closer to a generic template. TAKE RISKS."**

---

## 🎛️ Design Dials (Configure Before Starting)

Before any design work, set these dials based on context. **Ask user if unclear.**

| Dial | Range | Default |
|------|-------|---------|
| **DESIGN_VARIANCE** | 1 = Symmetric/Safe → 10 = Asymmetric/Bold | 5 |
| **MOTION_INTENSITY** | 1 = Static → 10 = Cinematic | 4 |
| **VISUAL_DENSITY** | 1 = Airy/Sparse → 10 = Dense/Packed | 5 |

**Example — B2B/POS context (dense, professional):**
```
DESIGN_VARIANCE  = 3  (professional, consistent)
MOTION_INTENSITY = 2  (functional, non-distracting)
VISUAL_DENSITY   = 7  (data-dense, high information)
```

> When VARIANCE > 4: Force split-screen or asymmetric layouts. NEVER centered heroes.
> When DENSITY > 7: Replace generic cards with `border-t`, `divide-y`, or spacing.
> When INTENSITY > 5: Add infinite micro-animations (Pulse, Float, Shimmer).

---

## 1. Constraint Analysis (ALWAYS FIRST)

Before any design work, ANSWER THESE or ASK USER:

| Constraint | Question | Why It Matters |
|------------|----------|----------------|
| **Timeline** | How much time? | Determines complexity |
| **Content** | Ready or placeholder? | Affects layout flexibility |
| **Brand** | Existing guidelines? | May dictate colors/fonts |
| **Tech** | What stack? | Affects capabilities |
| **Audience** | Who exactly? | Drives all visual decisions |

### Audience → Design Approach

| Audience | Think About |
|----------|-------------|
| **Gen Z** | Bold, fast, mobile-first, authentic |
| **Millennials** | Clean, minimal, value-driven |
| **Gen X** | Familiar, trustworthy, clear |
| **Boomers** | Readable, high contrast, simple |
| **B2B** | Professional, data-focused, trust |
| **Luxury** | Restrained elegance, whitespace |

---

## 2. UX Psychology Principles

### Core Laws (Internalize These)

| Law | Principle | Application |
|-----|-----------|-------------|
| **Hick's Law** | More choices = slower decisions | Limit options, use progressive disclosure |
| **Fitts' Law** | Bigger + closer = easier to click | Size CTAs appropriately |
| **Miller's Law** | ~7 items in working memory | Chunk content into groups |
| **Von Restorff** | Different = memorable | Make CTAs visually distinct |
| **Serial Position** | First/last remembered most | Key info at start/end |

### Emotional Design Levels

```
VISCERAL (instant)  → First impression: colors, imagery, overall feel
BEHAVIORAL (use)    → Using it: speed, feedback, efficiency
REFLECTIVE (memory) → After: "I like what this says about me"
```

### Trust Building

- Security indicators on sensitive actions
- Social proof where relevant
- Clear contact/support access
- Consistent, professional design
- Transparent policies

---

## 3. Layout Principles

### Golden Ratio (φ = 1.618)

```
Use for proportional harmony:
├── Content : Sidebar = roughly 62% : 38%
├── Each heading size = previous × 1.618 (for dramatic scale)
├── Spacing can follow: sm → md → lg (each × 1.618)
```

### 8-Point Grid Concept

```
All spacing and sizing in multiples of 8:
├── Tight: 4px (half-step for micro)
├── Small: 8px
├── Medium: 16px
├── Large: 24px, 32px
├── XL: 48px, 64px, 80px
└── Adjust based on content density
```

### Key Sizing Principles

| Element | Consideration |
|---------|---------------|
| **Touch targets** | Minimum comfortable tap size |
| **Buttons** | Height based on importance hierarchy |
| **Inputs** | Match button height for alignment |
| **Cards** | Consistent padding, breathable |
| **Reading width** | 45-75 characters optimal |

---

## 4. Color Principles

### 60-30-10 Rule

```
60% → Primary/Background (calm, neutral base)
30% → Secondary (supporting areas)
10% → Accent (CTAs, highlights, attention)
```

### Color Psychology (For Decision Making)

| If You Need... | Consider Hues | Avoid |
|----------------|---------------|-------|
| Trust, calm | Blue family | Aggressive reds |
| Growth, nature | Green family | Industrial grays |
| Energy, urgency | Orange, red | Passive blues |
| Luxury, creativity | Deep Teal, Gold, Emerald | Cheap-feeling brights |
| Clean, minimal | Neutrals | Overwhelming color |

### Selection Process

1. **What's the industry?** (narrows options)
2. **What's the emotion?** (picks primary)
3. **Light or dark mode?** (sets foundation)
4. **ASK USER** if not specified

For detailed color theory: [color-system.md](color-system.md)

---

## 5. Typography Principles

### Scale Selection

| Content Type | Scale Ratio | Feel |
|--------------|-------------|------|
| Dense UI | 1.125-1.2 | Compact, efficient |
| General web | 1.25 | Balanced (most common) |
| Editorial | 1.333 | Readable, spacious |
| Hero/display | 1.5-1.618 | Dramatic impact |

### Pairing Concept

```
Contrast + Harmony:
├── DIFFERENT enough for hierarchy
├── SIMILAR enough for cohesion
└── Usually: display + neutral, or serif + sans
```

### Readability Rules

- **Line length**: 45-75 characters optimal
- **Line height**: 1.4-1.6 for body text
- **Contrast**: Check WCAG requirements
- **Size**: 16px+ for body on web

For detailed typography: [typography-system.md](typography-system.md)

---

## 6. Visual Effects Principles

### Glassmorphism (When Appropriate)

```
Key properties:
├── Semi-transparent background
├── Backdrop blur
├── Subtle border for definition
└── ⚠️ **WARNING:** Standard blue/white glassmorphism is a modern cliché. Use it radically or not at all.
```

### Shadow Hierarchy

```
Elevation concept:
├── Higher elements = larger shadows
├── Y-offset > X-offset (light from above)
├── Multiple layers = more realistic
└── Dark mode: may need glow instead
```

### Gradient Usage

```
Harmonious gradients:
├── Adjacent colors on wheel (analogous)
├── OR same hue, different lightness
├── Avoid harsh complementary pairs
├── 🚫 **NO Mesh/Aurora Gradients** (floating blobs)
└── VARY from project to project radically
```

For complete effects guide: [visual-effects.md](visual-effects.md)

---

## 7. Animation Principles

### 🎯 Tool Selection Matrix (Use This First)

| Need | Tool | Why |
|------|------|-----|
| UI enter / exit / layout | **Framer Motion** — `AnimatePresence`, `layoutId`, springs | Best for React state-driven UI |
| Scroll storytelling (pin, scrub) | **GSAP + ScrollTrigger** — frame-accurate control | Best for scroll-linked sequences |
| Looping icons/illustrations | **Lottie** — lazy-load (~50KB) | JSON-based, smooth loops |
| 3D / WebGL | **Three.js / R3F** — isolated `<Canvas>` | GPU-accelerated 3D |
| Hover / focus states | **CSS only** — zero JS cost | No runtime overhead |
| Native scroll-driven | **CSS** — `animation-timeline: scroll()` | No library needed |

**Conflict Rules (MANDATORY):**
- NEVER mix GSAP + Framer Motion in same component
- R3F MUST live in isolated Canvas wrapper with its own `"use client"` boundary
- ALWAYS lazy-load Lottie, GSAP, Three.js

### Intensity Scale

| MOTION_INTENSITY | Techniques |
|------------|------------|
| 1–2 Subtle | CSS transitions only, 150–300ms |
| 3–4 Smooth | CSS keyframes + Framer animate, stagger ≤ 3 items |
| 5–6 Fluid | `whileInView`, magnetic hover, parallax tilt |
| 7–8 Cinematic | GSAP ScrollTrigger, pinned sections, horizontal hijack |
| 9–10 Immersive | Full scroll sequences, Three.js particles, WebGL shaders |

### Timing Concept

```
Duration based on:
├── Distance (further = longer)
├── Size (larger = slower)
├── Importance (critical = clear)
└── Context (urgent = fast, luxury = slow)
```

### Easing Selection

| Action | Easing | Config |
|--------|--------|--------|
| Entering | Ease-out | `cubic-bezier(0.16, 1, 0.3, 1)` |
| Leaving | Ease-in | `cubic-bezier(0.7, 0, 0.84, 0)` |
| Emphasis | Ease-in-out | Smooth, deliberate |
| Playful | Bounce/Spring | `stiffness: 100, damping: 10` |

**Spring Presets (Framer Motion):**
| Feel | Config |
|------|--------|
| Snappy | `stiffness: 300, damping: 30` |
| Smooth | `stiffness: 150, damping: 20` |
| Bouncy | `stiffness: 100, damping: 10` |

### ⚡ GPU-Only Rule (CRITICAL)

**ONLY animate these properties (GPU-accelerated):**
`transform`, `opacity`, `filter`, `clip-path`

**NEVER animate** (causes layout reflow):
`width`, `height`, `top`, `left`, `margin`, `padding`, `font-size`
> Instead: use `transform: scale()` or `clip-path` for size effects

### Performance Rules

- Perpetual animations MUST be in `React.memo` leaf components
- `will-change: transform` ONLY during animation, remove after
- Every `useEffect` with GSAP/observers MUST `return () => ctx.revert()`
- Respect `prefers-reduced-motion`
- Disable parallax/3D on touch devices (`pointer: coarse`)

For animation patterns: [animation-guide.md](animation-guide.md), for advanced: [motion-graphics.md](motion-graphics.md)

---

## 8. "Wow Factor" Checklist

### Premium Indicators

- [ ] Generous whitespace (luxury = breathing room)
- [ ] Subtle depth and dimension
- [ ] Smooth, purposeful animations
- [ ] Attention to detail (alignment, consistency)
- [ ] Cohesive visual rhythm
- [ ] Custom elements (not all defaults)

### Trust Builders

- [ ] Security cues where appropriate
- [ ] Social proof / testimonials
- [ ] Clear value proposition
- [ ] Professional imagery
- [ ] Consistent design language

### Emotional Triggers

- [ ] Hero that evokes intended emotion
- [ ] Human elements (faces, stories)
- [ ] Progress/achievement indicators
- [ ] Moments of delight

---

## 9. Anti-Patterns (What NOT to Do)

### ❌ Lazy Design Indicators

- Default system fonts without consideration
- Stock imagery that doesn't match
- Inconsistent spacing
- Too many competing colors
- Walls of text without hierarchy
- Inaccessible contrast

### ❌ AI Tendency Patterns (AVOID!)

- **Same colors every project**
- **Dark + neon as default**
- **Purple/violet everything (PURPLE BAN ✅)**
- **Bento grids for simple landing pages**
- **Mesh Gradients & Glow Effects**
- **Same layout structure / Vercel clone**
- **Not asking user preferences**

### ❌ Dark Patterns (Unethical)

- Hidden costs
- Fake urgency
- Forced actions
- Deceptive UI
- Confirmshaming

---

## 10. Decision Process Summary

```
For EVERY design task:

1. CONSTRAINTS
   └── What's the timeline, brand, tech, audience?
   └── If unclear → ASK

2. CONTENT
   └── What content exists?
   └── What's the hierarchy?

3. STYLE DIRECTION
   └── What's appropriate for context?
   └── If unclear → ASK (don't default!)

4. EXECUTION
   └── Apply principles above
   └── Check against anti-patterns

5. REVIEW
   └── "Does this serve the user?"
   └── "Is this different from my defaults?"
   └── "Would I be proud of this?"
```

---

## Reference Files

For deeper guidance on specific areas:

- [color-system.md](color-system.md) - Color theory and selection process
- [typography-system.md](typography-system.md) - Font pairing and scale decisions
- [visual-effects.md](visual-effects.md) - Effects principles and techniques
- [animation-guide.md](animation-guide.md) - Motion design principles
- [motion-graphics.md](motion-graphics.md) - Advanced: Lottie, GSAP, SVG, 3D, Particles
- [decision-trees.md](decision-trees.md) - Context-specific templates
- [ux-psychology.md](ux-psychology.md) - User psychology deep dive

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| **frontend-design** (this) | Before coding - Learn design principles (color, typography, UX psychology) |
| **[web-design-guidelines](../web-design-guidelines/SKILL.md)** | After coding - Audit for accessibility, performance, and best practices |

## Post-Design Workflow

After implementing your design, run the audit:

```
1. DESIGN   → Read frontend-design principles ← YOU ARE HERE
2. CODE     → Implement the design
3. AUDIT    → Run web-design-guidelines review
4. FIX      → Address findings from audit
```

> **Next Step:** After coding, use `web-design-guidelines` skill to audit your implementation for accessibility, focus states, animations, and performance issues.

---

## 🏪 B2B/POS Design Context

> Apply these **on top of** the general principles above. POS is B2B software — different from consumer apps.

### Audience Profile
| Factor | Value |
|--------|-------|
| **User** | Staff (cashier, warehouse, manager) — uses it 8h/day |
| **Usage Pattern** | Repetitive, speed-optimized, keyboard-heavy |
| **Device** | Desktop/laptop (1280px+), occasionally tablet |
| **Lighting** | Indoor, consistent lighting |

→ **Design Direction**: Professional, efficient, high information density, fast interactions. **NOT** consumer-app aesthetics.

### Color System Guidance
```css
/* Recommend HSL CSS variables for maintainable theming */
--primary-500: hsl(213, 90%, 52%)    /* Brand primary */
--primary-600: hsl(213, 90%, 44%)    /* Hover state */
--background: hsl(0, 0%, 100%)       /* Light bg */
--background-secondary: hsl(220, 14%, 96%)
--foreground: hsl(222, 47%, 11%)     /* Body text */
--foreground-muted: hsl(215, 25%, 45%) /* Secondary text */
--border: hsl(220, 13%, 91%)
--success: hsl(142, 70%, 45%)
--warning: hsl(38, 92%, 50%)
--destructive: hsl(0, 84%, 60%)
```

### POS-Specific UI Decisions

**Tables (Inventory, Orders):**
- Row height: 48-52px (compact but clickable)
- Alternating row colors: subtle (opacity 0.03 only)
- Hover: clear highlight, NOT bold
- Sort indicators: visible always
- Sticky header + footer pagination

**Forms:**
- Modal overlay — NOT inline (prevents clipping)
- Label above input (not floating — faster scanning)
- Tab key navigation between fields
- Auto-focus first field on open
- Disabled submit until required fields filled

**Search & Filter:**
- Search: debounce 300ms, disable browser autocomplete
- Filter chips: always visible above table
- Clear all filters: 1 click

**Status Badges:**
```
pending   → yellow-100/800
confirmed → blue-100/800
completed → green-100/800
cancelled → red-100/800
```

**Number Formatting:**
- Use locale-aware formatting appropriate to project region

### Common Page Layout Patterns

| Page Type | Layout | Key Area |
|-----------|---------|----------|
| **POS/Checkout** | Left (products) / Right (cart) ~60/40 | Cart always visible |
| **Inventory** | Full width table + filter sidebar | Table is center |
| **Master/Detail** | List panel (40%) + Detail panel (60%) | Detail updates on select |
| **Dashboard** | Stats cards top + Charts bottom | KPIs prominent |

### Animation Guidelines for B2B/POS
- Modal open/close: `duration-200`, `ease-out` — fast, no fancy effects
- Dropdown: `duration-150` — instant feel
- Row hover: `duration-100`
- Toast notifications: `duration-300` slide in, `duration-200` slide out
- **AVOID** bounce, flip, rotation — professional context

### Accessibility for Staff UIs
- All interactive elements: keyboard navigable
- Focus ring: visible (never hidden)
- Icon buttons: `title` or `aria-label`
- Error messages: inline, use both icon AND color (not color-only)

---

> **Remember:** Design is THINKING, not copying. Every project deserves fresh consideration based on its unique context and users. **Avoid the Modern SaaS Safe Harbor!**

