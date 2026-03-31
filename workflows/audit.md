---
description: Sắp bàn giao khách? Kiểm tra lại toàn diện cho chắc.
---

# /audit - Comprehensive Quality Check

$ARGUMENTS

---

## Task
This command runs a full audit of the project to ensure enterprise quality.
**All sections below are mandatory. A failed gate = STOP and fix before delivering.**

---

## ⚙️ Phase 1: Automated Checks

```bash
# 1. Security scan
npm audit
# 2. Lint check
npx eslint src --ext .ts,.tsx
# 3. Type check
npx tsc --noEmit
# 4. Build check (must succeed with 0 errors)
npm run build
```

---

## 🎨 Phase 2: Frontend Quality Gates

### Visual & Layout
- [ ] `min-h-[100dvh]` used (NOT `h-screen`)
- [ ] No horizontal scroll on mobile (375px)
- [ ] Consistent max-width across all pages
- [ ] Floating navbars have proper top/side spacing
- [ ] Content not hidden behind fixed navbars

### Icons & Media
- [ ] No emojis used as UI icons (use Lucide/Heroicons SVG)
- [ ] All images have `alt` text
- [ ] **No placeholder URLs** — grep for: `unsplash`, `picsum`, `placeholder`, `placehold`, `via.placeholder`
  ```bash
  grep -r "unsplash\|picsum\|placeholder\.com\|placehold\.co" src/
  ```
- [ ] All media assets exist as local files in project

### Interaction & UX
- [ ] All clickable elements have `cursor-pointer`
- [ ] Hover states provide clear visual feedback
- [ ] Transitions are smooth (150–300ms range)
- [ ] Focus states visible for keyboard navigation
- [ ] Loading states handled (skeleton/spinner, NOT blank screen)
- [ ] Empty states handled (NOT blank/broken UI)
- [ ] Error states handled with user-friendly messages

### Light/Dark Mode (if applicable)
- [ ] Light mode text contrast ≥ 4.5:1
- [ ] Glass/transparent elements visible in light mode
- [ ] Borders visible in both modes

---

## 🎬 Phase 3: Animation / Motion Gates

- [ ] Animation tool used correctly per purpose:
  - UI enter/exit → Framer Motion
  - Scroll storytelling → GSAP + ScrollTrigger
  - Hover/focus → CSS only (no JS)
- [ ] GSAP and Framer Motion NOT mixed in same component
- [ ] All `useEffect` with GSAP/observers have `return () => ctx.revert()`
- [ ] `prefers-reduced-motion` respected
- [ ] Perpetual animations in `React.memo` leaf components
- [ ] Only GPU properties animated: `transform`, `opacity`, `filter`, `clip-path`
- [ ] ❌ NOT animating: `width`, `height`, `top`, `left`, `margin`, `padding`
- [ ] Heavy animation libraries (GSAP, Three.js, Lottie) are lazy-loaded

---

## 🔧 Phase 4: Backend Quality Gates

- [ ] No secrets hardcoded in source code
  ```bash
  grep -r "password\|secret\|api_key\|token" src/ --include="*.ts" | grep -v ".env\|test\|example"
  ```
- [ ] `.env` is in `.gitignore` — check `.env.example` exists
- [ ] All endpoints have input validation (Zod / class-validator)
- [ ] Global error handler returns consistent JSON format
- [ ] No `console.log` in production code (use structured logger)
  ```bash
  grep -r "console\.log" src/
  ```
- [ ] N+1 queries avoided (check Prisma `include` patterns)
- [ ] Background jobs are idempotent
- [ ] Health check endpoint exists and responds: `GET /health`
- [ ] DB migrations exist for all schema changes

---

## ♿ Phase 5: Accessibility (a11y)

- [ ] All form inputs have associated `<label>`
- [ ] All icon-only buttons have `aria-label` or `title`
- [ ] Color is NOT the only visual indicator of state
- [ ] Error messages include icon + text (not just red color)
- [ ] Tab/keyboard navigation works for all interactive elements

---

## 🛍️ Phase 6: POS/Petshop-Specific Gates

- [ ] Currency formatted correctly: `123.456 ₫` (dấu chấm, không phải phẩy)
- [ ] Tables have sticky header + pagination footer
- [ ] Search inputs have `autoComplete="off"`
- [ ] Modal forms: auto-focus first field on open
- [ ] Status badges use correct color mapping (pending/confirmed/completed/cancelled)
- [ ] API calls include auth token in headers

---

## 📄 Phase 7: Report

Generate `AUDIT_REPORT.md` at project root with:
- Date + auditor (agent name)
- Total issues found (Critical / Warning / Info)
- Per-gate results (✅ Pass / ❌ Fail / ⚠️ Warning)
- For each failure: file path + line number + fix suggestion
- Summary verdict: **PASS** (0 critical) or **FAIL** (fix required)

---

## Usage
```
/audit          # Run all checks
/audit security # Phase 1 + 4 only
/audit frontend # Phase 2 + 3 + 5 only
/audit pos      # Phase 6 (Petshop-specific) only
```
