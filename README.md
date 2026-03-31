# 🤖 Antigravity Agent Bundle

> A production-grade AI agent configuration bundle for Antigravity IDE.
> Developed through real-world use on production projects.

---

## 📦 What's Inside

| Folder | Count | Description |
|--------|-------|-------------|
| `agents/` | 22 | Specialized AI agents (orchestrator, debugger, frontend, backend, mobile, etc.) |
| `skills/` | 19 | Deep skill modules (TDD, UI/UX, database migration, deployment, etc.) |
| `rules/` | 19 | Auto-triggered coding standards (API, naming, monitoring, security, etc.) |
| `workflows/` | 28 | Slash-command workflows (`/create`, `/debug`, `/orchestrate`, etc.) |
| `hooks.json` | 4 | AI-triggered hooks (TypeScript check, console.log detection, DB guard) |
| `.shared/` | 17 | Shared knowledge modules (design system, infra blueprints, etc.) |

---

## 🚀 Quick Install

### Windows (PowerShell)
```powershell
# In your new project root:
.\install.ps1
```

### Manual
```powershell
# Copy the entire .agent/ folder into your project
Copy-Item -Path "path/to/bundle/.agent" -Destination "your-project/.agent" -Recurse

# Then customize:
# 1. Rename GEMINI.template.md → GEMINI.md  (fill in project identity)
# 2. Rename START_HERE.template.md → START_HERE.md  (fill in tech stack)
# 3. Create .agent/context/ with your project knowledge files
```

---

## 📐 Architecture

```
Your Project/
├── .agent/                     ← This bundle (generic)
│   ├── GEMINI.md               ← Agent identity & config (customize!)
│   ├── START_HERE.md           ← Quick reference (customize!)
│   ├── hooks.json              ← AI-triggered hooks
│   ├── agents/                 ← 22 specialized agents
│   ├── skills/                 ← 19 skill modules
│   ├── rules/                  ← 19 auto-triggered rules
│   ├── workflows/              ← 28 slash-command workflows
│   └── .shared/                ← 17 shared knowledge modules
│
└── .agent/context/             ← YOUR project knowledge (NOT in this repo)
    ├── api-conventions.md      ← Your API patterns (use project-context-template skill)
    ├── db-schema.md            ← Your DB schema quickref
    └── frontend-patterns.md   ← Your frontend conventions
```

---

## ⚡ Key Features

### 🌊 Wave-Based Orchestration
Complex tasks are broken into controlled waves — the AI presents a plan, waits for approval, then executes wave by wave with reports after each wave.

```
/orchestrate Build me a full authentication system
```

### 🪝 AI-Triggered Hooks
- **TypeScript check**: Auto-runs `tsc --noEmit` after every `.ts/.tsx` edit
- **console.log guard**: Warns when `console.log` is added to production files
- **DB protection**: Blocks dangerous commands like `DROP TABLE` or `prisma migrate reset --force`
- **Secrets warning**: Alerts when AI reads `.env` files

### 📜 Smart Rules
Rules auto-activate based on file type — no manual loading needed:
- Open `*.tsx` → `frontend.md` + `ui-components.md` + `naming-conventions.md` activate
- Open `*.controller.ts` → `api-conventions.md` activates
- Open `*.service.ts` → `monitoring.md` activates

### 🧩 Skills Library
19 deep skills including:
- `tdd-master-workflow` — Red-Green-Refactor TDD cycle
- `verification-loop` — Post-change regression prevention
- `search-first` — Read codebase BEFORE writing code
- `ui-ux-pro-max` — 50 styles, 21 palettes, premium design system
- `database-migration` — Zero-downtime DB migration patterns

---

## 🛠️ Slash Commands

| Command | Purpose |
|---------|---------|
| `/create` | Create new feature (full-stack) |
| `/plan` | Plan before coding |
| `/orchestrate` | Wave-based multi-agent execution |
| `/debug` | Systematic debugging |
| `/audit` | Pre-delivery quality check |
| `/verify` | Post-change regression check |
| `/tdd` | Test-driven development cycle |
| `/deploy` | Production deployment |
| `/check-connections` | FE↔BE connectivity check |
| `/ui-ux-pro-max` | Premium UI design |
| `/security` | Security audit |
| `/status` | Project dashboard |

---

## 📋 Available Agents

| Agent | Role |
|-------|------|
| `orchestrator` | Master coordinator — wave-based multi-agent |
| `debugger` | Root cause analysis & systematic debugging |
| `frontend-specialist` | React, Next.js, CSS, UI components |
| `backend-specialist` | API, Node.js, Express, services |
| `database-architect` | Schema design, migrations, optimization |
| `devops-engineer` | CI/CD, Docker, deployment, infra |
| `mobile-developer` | React Native, Flutter, Expo |
| `security-auditor` | Vulnerabilities, auth, OWASP |
| `penetration-tester` | Active security testing |
| `test-engineer` | TDD, unit/E2E tests, coverage |
| `performance-optimizer` | Profiling, Lighthouse, bottlenecks |
| `quality-inspector` | Pre-deploy gate — verifies everything |
| `codebase-expert` | Impact analysis, refactoring, legacy code |
| `typescript-reviewer` | TypeScript type safety review |
| `database-reviewer` | Query review, N+1 detection |
| `project-planner` | Task breakdown, milestones |
| `product-owner` | Requirements, user stories |
| `explorer-agent` | Codebase discovery & research |
| `documentation-writer` | README, API docs, changelogs |
| `seo-specialist` | SEO, meta tags, analytics |
| `game-developer` | Unity, Godot, Phaser |
| `mobile-developer` | React Native, Flutter |

---

## 📝 Setup for New Project

```powershell
# 1. Install bundle
Copy-Item ".agent" "your-project/.agent" -Recurse

# 2. Configure agent identity
Copy-Item "your-project/.agent/GEMINI.template.md" "your-project/.agent/GEMINI.md"
# Edit GEMINI.md: set project name, focus area, language protocol

# 3. Set up quick reference
Copy-Item "your-project/.agent/START_HERE.template.md" "your-project/START_HERE.md"
# Edit START_HERE.md: add your tech stack and patterns

# 4. Create project context (use /skill project-context-template)
mkdir "your-project/.agent/context"
# Create 3 context files: api-conventions.md, db-schema.md, frontend-patterns.md

# 5. Create ERRORS.md for error logging
New-Item "your-project/ERRORS.md" -ItemType File
```

---

## 🤝 Contributing

This bundle grew from real production use. PRs welcome for:
- New agent specializations
- Additional skill modules
- Improved workflow templates
- Bug fixes in rules

---

## 📜 License

MIT — Use freely in personal and commercial projects.
