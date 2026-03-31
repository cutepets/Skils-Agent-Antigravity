# 🤖 Antigravity Agent Bundle

> A production-grade AI agent configuration bundle for **Antigravity IDE**.
> Battle-tested through real-world projects. Drop into any new project and start coding immediately.

![Version](https://img.shields.io/badge/version-v1.5.1-orange)
![AgentShield Grade A](https://img.shields.io/badge/AgentShield-Grade%20A%20(96%2F100)-brightgreen)
![Agents](https://img.shields.io/badge/Agents-22-blue)
![Skills](https://img.shields.io/badge/Skills-25-blue)
![Workflows](https://img.shields.io/badge/Workflows-28-blue)
![Rules](https://img.shields.io/badge/Rules-19-blue)

> 📋 [CHANGELOG](./CHANGELOG.md) — xem lịch sử cập nhật

---

## 🔒 Security Score (AgentShield)

Verified with [`ecc-agentshield`](https://www.npmjs.com/package/ecc-agentshield):

| Category | Score |
|----------|-------|
| 🔑 Secrets | 100/100 |
| 🔐 Permissions | 100/100 |
| 🪝 Hooks | 100/100 |
| 🔌 MCP Servers | 100/100 |
| 🤖 Agents | 80/100 |
| **Overall Grade** | **A (96/100)** |

> Run your own scan: `npx -y ecc-agentshield scan --path .agent --format markdown`

---

## 📦 What's Inside

| Component | Count | Description |
|-----------|-------|-------------|
| 🤖 Agents | **22** | Specialized AI personas for every task |
| 🧩 Skills | **25** | Deep, reusable knowledge modules |
| ⚡ Workflows | **28** | Slash-command workflows (`/create`, `/debug`, etc.) |
| 📜 Rules | **19** | Auto-triggered coding standards |
| 🪝 Hooks | **4** | AI-triggered safety hooks |
| 📚 Shared | **17** | Shared knowledge modules |

---

## 🤖 Agents (22)

| Agent | Role |
|-------|------|
| `orchestrator` | Master coordinator — Wave-based multi-agent execution with approval gates |
| `debugger` | Systematic root cause analysis & bug hunting |
| `frontend-specialist` | React, Next.js, CSS, UI components, animations |
| `backend-specialist` | Node.js, Express, REST API, services |
| `database-architect` | Schema design, Prisma/SQL, migrations, optimization |
| `database-reviewer` | Query review, N+1 detection, migration safety (model: haiku) |
| `typescript-reviewer` | TypeScript type safety, React patterns review (model: haiku) |
| `devops-engineer` | CI/CD, Docker, Kubernetes, deployment pipelines |
| `mobile-developer` | React Native, Flutter, Expo, mobile patterns |
| `game-developer` | Unity, Godot, Phaser.js game development |
| `security-auditor` | OWASP, auth review, vulnerability scanning |
| `penetration-tester` | Active security testing (authorized systems only) |
| `performance-optimizer` | Profiling, Lighthouse, bottleneck analysis |
| `test-engineer` | Unit tests, E2E, coverage strategy |
| `codebase-expert` | Impact analysis, refactoring, legacy code archaeology |
| `explorer-agent` | Codebase discovery, research, unfamiliar repo navigation |
| `quality-inspector` | Pre-deploy gate — verifies all checklist items |
| `project-planner` | Task breakdown, milestones, estimation |
| `product-owner` | Requirements, user stories, acceptance criteria |
| `product-manager` | Roadmap, prioritization, stakeholder communication |
| `documentation-writer` | README, API docs, changelogs, ADRs |
| `seo-specialist` | SEO, meta tags, Core Web Vitals, analytics |

---

## 🧩 Skills (25)

Skills are organized by **domain**. Each skill folder contains `SKILL.md` + `config.json` (metadata for auto-detection).

> **Find quickly:** `workflow` → safety nets | `backend` → server & DB | `frontend` → UI & data | `devops` → infra | `design` → visual | `setup` → project init

---

### 🔄 Workflow & Safety (Core — always relevant)

| Skill | Priority | Purpose |
|-------|----------|---------|
| `search-first` | ⭐⭐⭐⭐⭐ 10 | Read codebase BEFORE writing code — prevents AI guessing |
| `verification-loop` | ⭐⭐⭐⭐⭐ 9 | Post-change regression prevention, systematic checks |
| `tdd-master-workflow` | ⭐⭐⭐⭐ 8 | Red-Green-Refactor TDD cycle, test architecture design |
| `security-scan` | ⭐⭐⭐⭐ 8 | AgentShield scan + manual checklist for AI agent configs |

---

### 🖧 Backend (NestJS · Prisma · PostgreSQL)

| Skill | Priority | Purpose |
|-------|----------|---------|
| `nestjs-clean-arch` | ⭐⭐⭐⭐ 8 | Modules, controllers, DTOs, guards, interceptors, Prisma integration |
| `prisma-orm` | ⭐⭐⭐⭐ 8 | Schema design, migration workflow, N+1 prevention, transactions |
| `fastify-patterns` | ⭐⭐⭐⭐ 8 | Fastify v5 plugins, hooks, decorators, high-performance Node.js APIs |
| `moleculer-patterns` | ⭐⭐⭐ 7 | Microservices patterns: Circuit Breaker, Event-driven, Service Broker, Fault Tolerance |
| `medusa-commerce` | ⭐⭐⭐ 7 | Medusa.js modular commerce, durable workflows, headless architecture |
| `database-migration` | ⭐⭐⭐ 7 | Zero-downtime migrations, rollback strategies, schema safety |
| `api-documenter` | ⭐⭐⭐ 6 | OpenAPI 3.1, Swagger UI, SDK generation, developer portal |
| `full-stack-scaffold` | ⭐⭐⭐ 6 | Project scaffolding for Node.js, Python, Rust, Mobile |

> **Adding a backend skill?** Place here, `"tags": ["backend", ...]` in config.json

---

### 🎨 Frontend (React · Vite · TanStack)

| Skill | Priority | Purpose |
|-------|----------|---------|
| `modern-web-architect` | ⭐⭐⭐⭐ 8 | React 19, Next.js 15, App Router, state management patterns |
| `tanstack-query-patterns` | ⭐⭐⭐⭐ 8 | QueryKey conventions, mutations, optimistic updates, cache |
| `connection-health-check` | ⭐⭐⭐ 6 | FE↔BE connectivity diagnosis before/after danger file edits |
| `tailwind-patterns` | ⭐⭐⭐ 5 | Tailwind CSS v4, CSS-first config, container queries |
| `mobile-design` | ⭐⭐⭐ 5 | iOS/Android patterns, touch targets, platform conventions |
| `i18n-localization` | ⭐⭐ 4 | Internationalization, locale files, RTL support |

> **Adding a frontend skill?** Place here, `"tags": ["frontend", ...]` in config.json

---

### 🎭 Design & UX

| Skill | Priority | Purpose |
|-------|----------|---------|
| `ui-ux-pro-max` | ⭐⭐⭐⭐ 7 | 50 UI styles, 21 palettes, 50 font pairings, premium design |
| `frontend-design` | ⭐⭐⭐⭐ 7 | Design thinking, color theory, typography, UX psychology |
| `v0-prompt-engineer` | ⭐⭐⭐ 5 | Use v0.dev as brainstorm tool before handing off to agent |

> **Adding a design skill?** Place here, `"tags": ["design", ...]` in config.json

---

### ☁️ DevOps & Reliability

| Skill | Priority | Purpose |
|-------|----------|---------|
| `deployment-engineer` | ⭐⭐⭐⭐ 7 | CI/CD pipelines, Docker, Kubernetes, GitOps, progressive delivery |
| `performance-engineer` | ⭐⭐⭐⭐ 7 | OpenTelemetry, load testing, Core Web Vitals, multi-tier caching |
| `incident-responder` | ⭐⭐⭐ 6 | SRE incident command, blameless post-mortems, error budget |

> **Adding a devops skill?** Place here, `"tags": ["devops", ...]` in config.json

---

### 🚀 Project Setup & Onboarding

| Skill | Priority | Purpose |
|-------|----------|---------|
| `project-context-template` | ⭐⭐ 4 | Bootstrap `.agent/context/` for new projects |

> **Adding a setup skill?** Place here, `"tags": ["setup", ...]` in config.json

---

## ⚡ Workflows / Slash Commands (28)

| Command | Purpose |
|---------|---------|
| `/create` | Create new feature from A-Z (full-stack) |
| `/plan` | Plan before coding — design & breakdown |
| `/enhance` | Small UI/logic improvements |
| `/orchestrate` | **Wave-based** multi-agent execution with approval gates |
| `/debug` | Systematic bug hunting with log analysis |
| `/build-fix` | Fix TypeScript/lint/build errors fast |
| `/test` | Write automated tests |
| `/tdd` | Test-Driven Development cycle (Red→Green→Refactor) |
| `/verify` | Post-change regression check |
| `/audit` | Pre-delivery comprehensive quality check |
| `/code-review` | AI-powered code review |
| `/deploy` | Production deployment pipeline |
| `/monitor` | Set up monitoring & alerting |
| `/security` | Security vulnerability scan |
| `/security-scan` | AgentShield + manual security checklist |
| `/check-connections` | FE↔BE connectivity diagnosis |
| `/api-docs` | Generate/update OpenAPI documentation |
| `/document` | Auto-generate documentation |
| `/update-docs` | Sync docs after feature changes |
| `/release-version` | Version bump & changelog update |
| `/status` | Project dashboard & progress report |
| `/brainstorm` | AI-powered idea generation |
| `/onboard` | New team member setup guide |
| `/seo` | SEO optimization workflow |
| `/ui-ux-pro-max` | Premium UI design session |
| `/preview` | Launch local preview server |
| `/log-error` | Log error to ERRORS.md |
| `/update` | Check & update Antigravity IDE version |

---

## 📜 Rules (19) — Auto-triggered

Rules activate automatically based on which file you open:

| Rule | Trigger | Purpose |
|------|---------|---------|
| `GEMINI.md` | Always | Core PDCA loop, Decision Gate, Security guardrails |
| `api-conventions.md` | `*.routes.ts`, `*.service.ts` | REST patterns, response shapes, Prisma usage |
| `naming-conventions.md` | `*.ts`, `*.tsx` | Variable, function, file naming standards |
| `frontend.md` | `*.tsx`, `*.css` | Component patterns, responsive design, animations |
| `ui-components.md` | `*.tsx` | CSS variables, design tokens, component checklist |
| `ui-patterns.md` | `*.tsx` | Layout patterns, accessibility, interaction design |
| `backend.md` | `*.ts` (backend) | API design, error handling, middleware patterns |
| `monitoring.md` | `*.service.ts` | Logging, metrics, observability patterns |
| `business.md` | `*.ts` | DDD, money handling, RBAC patterns |
| `security.md` | Always | No hardcode secrets, XSS, SQL injection prevention |
| `file-safety.md` | Always | UTF-8 enforcement, line ending safety, backup before script |
| `git-workflow.md` | Branch/commit | Conventional commits, branch strategy, merge rules |
| `error-logging.md` | Always | Log to ERRORS.md on failure |
| `debug.md` | Bug fix tasks | Systematic debugging protocol |
| `architecture-review.md` | Config files | ADR check before architectural changes |
| `compliance.md` | Data models | GDPR, data retention, privacy rules |
| `malware-protection.md` | Always | AI config security, prompt injection prevention |
| `docs-update.md` | Feature complete | Remind to update docs after changes |
| `system-update.md` | Update requests | Antigravity IDE update workflow |

---

## 🪝 AI-Triggered Hooks (hooks.json)

Hooks fire automatically when the AI performs certain actions:

| Hook | Trigger | Action |
|------|---------|--------|
| **TypeScript Check** | Edit `*.ts` / `*.tsx` | Runs `tsc --noEmit` — catches type errors instantly |
| **console.log Guard** | Write `console.log` | Warns before adding debug logs to production files |
| **DB Protection** | Run dangerous commands | Blocks `DROP TABLE`, `migrate reset --force` without explicit confirm |
| **Secrets Warning** | Read `.env` | Alerts when AI reads sensitive environment files |

---

## 🚀 Quick Install

> **Repo structure note:** This repo root **is** the `.agent/` bundle. When you clone it, copy the entire repo folder into your project as `.agent/`.

### Option 1: Clone and copy (manual)
```powershell
# Windows
git clone https://github.com/cutepets/Skils-Agent-Antigravity.git agent-bundle
Copy-Item agent-bundle your-project\.agent -Recurse
```
```bash
# Linux / macOS
git clone https://github.com/cutepets/Skils-Agent-Antigravity.git agent-bundle
cp -r agent-bundle your-project/.agent
```

### Option 2: Run installer
```powershell
# Windows (PowerShell)
git clone https://github.com/cutepets/Skils-Agent-Antigravity.git agent-bundle
cd agent-bundle
.\install.ps1 -ProjectPath "C:\path\to\your-project"
```
```bash
# Linux / macOS (bash)
git clone https://github.com/cutepets/Skils-Agent-Antigravity.git agent-bundle
cd agent-bundle
chmod +x install.sh && ./install.sh /path/to/your-project
```

### After installing — 3 setup steps:

```powershell
# Step 1: Set agent identity
Copy-Item .agent\GEMINI.template.md .agent\GEMINI.md
# Edit GEMINI.md: set your project name & focus area

# Step 2: Set quick reference
Copy-Item .agent\START_HERE.template.md START_HERE.md
# Edit START_HERE.md: add your tech stack & patterns

# Step 3: Create project knowledge (use /skill project-context-template)
mkdir .agent\context
# Create 3 files: api-conventions.md, db-schema.md, frontend-patterns.md
```

---

## 🏗️ Architecture: 2-Layer Pattern

```
Your Project/
├── .agent/                     ← This bundle (generic, from GitHub)
│   ├── GEMINI.md               ← Agent identity (customize per project)
│   ├── hooks.json              ← AI-triggered safety hooks
│   ├── agents/                 ← 22 specialized agents
│   ├── skills/                 ← 24 skill modules
│   ├── rules/                  ← 19 auto-triggered rules
│   ├── workflows/              ← 28 slash-command workflows
│   └── .shared/                ← 17 shared knowledge modules
│
└── .agent/context/             ← YOUR project knowledge (NOT in this repo)
    ├── api-conventions.md      ← Your API patterns
    ├── db-schema.md            ← Your DB schema quickref
    └── frontend-patterns.md   ← Your frontend conventions
```

> **Key principle**: This bundle is generic. Project-specific knowledge lives in `.agent/context/` — not committed to this repo.

---

## ⚡ Key Features

### 🌊 Wave-Based Orchestration
Break complex tasks into controlled waves — AI presents plan, waits for approval, executes wave-by-wave:
```
/orchestrate Build a complete authentication system with JWT + refresh tokens
```

### 🔍 Search-First Protocol
Before writing ANY code, AI reads and understands the existing codebase:
- Reads `.agent/context/` files for project patterns
- Checks existing implementations before creating new ones
- Prevents duplicate code and pattern violations

### 🔄 Verification Loop
After every significant change, automatically checks:
- TypeScript compiles without errors
- API contracts unchanged
- Business logic integrity maintained
- No regression introduced

### 🧠 Smart Rules Activation
Rules load automatically based on file context — no manual loading:
- Open `*.tsx` → frontend + UI rules activate
- Open `*.service.ts` → backend + monitoring rules activate
- Every session → security + file-safety rules active

---

## 📝 Creating Project Context

Use the built-in `project-context-template` skill to scaffold your context files:

```
/skill project-context-template
```

This creates 3 files under `.agent/context/`:
- `api-conventions.md` — your REST patterns, response shapes, auth middleware
- `db-schema.md` — entity relationships, enum values, key constraints
- `frontend-patterns.md` — CSS system, component patterns, env variables

---

## 🔌 Portability & Known Trade-offs

### What's Antigravity-specific (locked)

| Component | Locked to | Notes |
|-----------|-----------|-------|
| `hooks.json` | Antigravity IDE hook system | Not portable — would need rewrite for other IDEs |
| Rule auto-triggers (`trigger: *.tsx`) | Antigravity rule loading | Pattern varies per IDE |
| `/skill`, `/workflow` slash commands | Antigravity command palette | |

### What's fully portable (generic markdown)

| Component | Portable? | Notes |
|-----------|-----------|-------|
| `skills/*/SKILL.md` | ✅ Yes | Plain markdown — any AI can read it |
| `agents/*.md` | ✅ Yes | Frontmatter varies per IDE, body is portable |
| `workflows/*.md` | ✅ Yes | Step-by-step instructions, IDE-agnostic |
| `skills/*/config.json` | ✅ Yes | Metadata for discovery |
| `CHANGELOG.md` | ✅ Yes | |

> **Summary:** SKILL.md knowledge is 100% portable. If you switch IDEs, only `hooks.json` and trigger patterns need rewriting. Plan 2–4 hours for migration.

---

## ⚡ Context Window Best Practices

With 24 skills + 19 rules + 28 workflows, context can grow large. Follow these practices:

### ✅ Do
- Let rules auto-trigger naturally — Antigravity only loads rules that **match** the current file, not all rules
- Use `/skill [name]` explicitly only when needed — don't chain multiple skills per session
- Keep `.agent/context/` files concise (< 200 lines each) — they load on every relevant session
- Use `search-first` at the START of a session, not repeatedly

### ❌ Avoid
- Manually loading many skills in one prompt (`/skill A + /skill B + /skill C`)
- Putting large data dumps in `.agent/context/` files (DB dumps, full API specs)
- Running long orchestration chains without intermediate approval checkpoints

### Priority guide (from config.json)
```
Priority 10-9 (Core)       → Always relevant, keep loaded: search-first, verification-loop
Priority 8    (Important)  → Load when domain matches: nestjs, prisma, tanstack, tdd
Priority 7-6  (Useful)     → Load on demand via /skill command
Priority 5-4  (Specialty)  → Load only when specifically needed
```

---

## 🤝 Contributing

This bundle grew from real production use. PRs welcome for:
- New agent specializations
- Additional skill modules
- Improved workflow templates
- Bug fixes in rules

When adding a skill:
1. Create `skills/[name]/SKILL.md` + `config.json`
2. Add to correct domain group in README Skills section
3. Update `CHANGELOG.md` with new minor version
4. Update Skills badge count in README

---

## 📜 License

MIT — Use freely in personal and commercial projects.

---

*Built with Antigravity IDE · Security verified by [AgentShield](https://www.npmjs.com/package/ecc-agentshield)*
