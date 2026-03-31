# 📋 CHANGELOG — Antigravity Agent Bundle

Toàn bộ lịch sử thay đổi của bundle theo chuẩn [Semantic Versioning](https://semver.org/):
- **MAJOR** (x.0.0): Breaking changes — cấu trúc thay đổi lớn
- **MINOR** (x.y.0): Tính năng mới — thêm skills, agents, workflows
- **PATCH** (x.y.z): Fix nhỏ — sửa typo, cập nhật nội dung skill

---

## [v1.4.0] — 2026-03-31

### 🔧 Fixes (addressing 5 flagged risks)

**#1 Vendor lock-in documentation:**
- README: thêm section "Portability & Known Trade-offs" — bảng rõ ràng phần nào locked vs portable
- Result: người dùng biết scope của dependency trước khi adopt

**#2 Context window best practices:**
- README: thêm section "Context Window Best Practices" với do/don't và priority guide
- GEMINI.md model config: document alias `MODEL_SMART` / `MODEL_FAST`

**#3 Agent-to-agent communication clarity:**
- `orchestrator.md`: thêm disclaimer rõ ràng — "sequential prompting, not true parallel execution"
- Align expectation với thực tế ngành (LangGraph, CrewAI, AutoGen đều sequential)

**#4 Model hardcode fix:**
- `GEMINI.md`: thêm Model Configuration table với aliases `MODEL_SMART`/`MODEL_FAST`
- `database-reviewer.md` + `typescript-reviewer.md`: annotate `model: haiku` với comment trỏ về GEMINI.md
- Từ nay chỉ cần update 1 file (GEMINI.md) khi model name đổi

**#5 Cross-platform installer:**
- Tạo `install.sh` (bash) cho Linux/macOS — feature-parity với `install.ps1`
- README: ghi rõ cả 2 installer options

---

## [v1.3.0] — 2026-03-31

### 📖 Docs
- **README restructure:** Skills section tổ chức theo 6 domain groups (Workflow, Backend, Frontend, Design, DevOps, Setup)
- Thêm priority indicator (⭐ scale) cho từng skill
- Thêm quick-find navigation bar và "Adding a skill?" tip mỗi section
- README giờ là "living document" — rõ ràng nơi thêm skill mới

---

## [v1.2.0] — 2026-03-31

### ✨ New Skills (3)
- `nestjs-clean-arch` — Modules, controllers, DTOs, guards, interceptors, Prisma integration pattern
- `prisma-orm` — Schema conventions, migration workflow, N+1 prevention, transactions, seeding
- `tanstack-query-patterns` — QueryKey factory, mutations, optimistic updates, cache invalidation, pagination

### 🧩 Skills Metadata (19 config.json files)
- Mỗi skill folder giờ có `config.json` với: `name`, `description`, `tags`, `trigger_keywords`, `priority`
- Agent có thể auto-detect skill phù hợp theo context mà không cần user nhớ tên skill

### 📖 Docs
- README Skills table thêm cột Tags
- Skills count badge: 19 → 22

---

## [v1.1.0] — 2026-03-31

### 🔧 Generalization (Phase 1)
Xoá toàn bộ project-specific references (Petshop Service Management) khỏi bundle để phù hợp với mọi project:

**Skills cleaned:**
- `search-first` — Xoá grep patterns hardcode, thay bằng generic examples
- `verification-loop` — Generalize title + business logic checks (POS → generic state machine)
- `v0-prompt-engineer` — Thay example prompt Petshop bằng `[Project Name]` placeholder
- `frontend-design` — "Petshop Color System" → generic B2B/POS design guidance
- `modern-web-architect` — Xoá `Petshop_Service_Management` hardcode và specific file paths
- `database-migration` — Generic domain model thay vì Petshop schema

**Workflows cleaned:**
- `audit.md` — Phase 6 từ "POS/Petshop-Specific" → "Project-Specific Gates" (customizable)
- `verify.md` — Business logic checks generic, hardcoded ports generic

---

## [v1.0.0] — 2026-03-31

### 🎉 Initial Release
First public release của Antigravity Agent Bundle.

**Bao gồm:**
- 🤖 **22 Agents** — Orchestrator, Debugger, Frontend/Backend/DB specialists, Security, DevOps...
- 🧩 **19 Skills** — TDD, Verification, Search-First, UI/UX, Frontend Design, Modern Web Arch...
- ⚡ **28 Workflows** — `/create`, `/debug`, `/deploy`, `/audit`, `/orchestrate`...
- 📜 **19 Rules** — GEMINI.md, security, file-safety, git-workflow, frontend, backend...
- 🪝 **4 Hooks** — TypeScript check, console.log guard, DB protection, secrets warning
- 🔒 **Security Grade A (96/100)** — Verified by AgentShield

---

## Cách đọc version

Khi anh thấy badge `v1.3.0` trong README:
- **1** = Major version (cấu trúc bundle)
- **3** = Số lần thêm tính năng/skills mới kể từ v1.0
- **0** = Số lần patch/fix nhỏ trong minor version hiện tại

Để cập nhật lên version mới nhất:
```powershell
cd your-project/.agent
git pull origin main

# Hoặc nếu dùng installer:
.\.agent\install.ps1 -ProjectPath "." -Update
```
