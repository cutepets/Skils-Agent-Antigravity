# 🚀 [YOUR PROJECT NAME] — AI Agent Hub

> **Read this first.** All rules, patterns, and workflows are linked from here.
> Copy from `START_HERE.template.md` → rename to `START_HERE.md` → fill in your project details.

---

## ⚡ Quick Start

| I want to... | Command |
|-------------|---------|
| Create a new feature | `/create` |
| Plan before coding | `/plan` |
| Complex multi-agent task | `/orchestrate` (Wave-based) |
| Code review | `/code-review <file>` |
| Fix a bug | `/debug` |
| Design UI | `/ui-ux-pro-max` |
| Check FE↔BE connection | `/check-connections` |
| View project status | `/status` |

---

## 🏗️ Tech Stack

```
Backend:   [e.g., Express + TypeScript + Prisma (SQLite dev / PostgreSQL prod)]
Frontend:  [e.g., React 18 + Vite + TypeScript + Tailwind CSS]
State:     [e.g., TanStack Query + Zustand]
Auth:      [e.g., JWT access + refresh token]
Realtime:  [e.g., Socket.io]
```

---

## 📐 Standard Patterns — MUST FOLLOW

**Backend route:**
```typescript
router.get('/', async (req, res, next) => {
  try { res.json({ success: true, data: await service(req.query) }); }
  catch (err) { next(err); }
});
```

**Frontend query:**
```typescript
const { data } = useQuery({
  queryKey: ['key', filters],
  queryFn: () => api.get('/endpoint', { params: filters }).then(r => r.data),
});
```

---

## 📋 Active Rules

| File | Trigger | Content |
|------|---------|---------|
| `rules/GEMINI.md` | Always | PDCA, Decision Gate |
| `rules/frontend.md` | *.tsx *.css | UI standards |
| `rules/backend.md` | *.ts *.sql | API, DB, DevOps |
| `rules/business.md` | *.ts | DDD, Money, RBAC |
| `rules/security.md` | Always | No hardcode, XSS, SQL injection |
| `rules/error-logging.md` | Always | Log to ERRORS.md |
| `rules/file-safety.md` | Always | UTF-8, no broken line endings |

---

## 🔗 Important Resources

- **`.agent/context/api-conventions.md`** — Your project's API patterns
- **`.agent/context/db-schema.md`** — Quick DB schema reference
- **`.agent/context/frontend-patterns.md`** — Frontend patterns & conventions
- **`PROJECT_CONTEXT.md`** — Business rules, domain knowledge (create this!)
- **`ERRORS.md`** — Error log — read before debugging

---

> **Note for AI**: When facing connection issues, always read `.agent/context/` files first.
> Project context files are the source of truth for project-specific patterns.
