---
description: Task quá chua? Gọi cả hội đồng chuyên gia vào làm. (Wave-based execution - dừng kiểm tra sau mỗi làn sóng)
---

# Multi-Agent Orchestration

You are now in **ORCHESTRATION MODE**. Your task: coordinate specialized agents to solve this complex problem.

## Task to Orchestrate
$ARGUMENTS

---

## 🌊 WAVE-BASED EXECUTION PROTOCOL (CỐT LÕI)

Orchestration không chạy hỗn loạn — nó chạy theo **từng làn sóng (Waves)** có kiểm soát.

```
WAVE 0 (Planning)   → Tạo Wave Plan → ⏸️ CHỜ DUYỆT
WAVE 1 (Foundation) → Chạy → ⏸️ BÁO CÁO → CHỜ "OK"
WAVE 2 (Core)       → Chạy → ⏸️ BÁO CÁO → CHỜ "OK"
WAVE N (Polish)     → Chạy → ⏸️ BÁO CÁO CUỐI
```

> 🔴 **NGUYÊN TẮC BẤT BIẾN:**
> 1. **Trình bày Wave Plan TRƯỚC** — KHÔNG bắt đầu code ngay.
> 2. **Dừng sau mỗi Wave** — Báo cáo kết quả và hỏi "Tiếp tục Wave N+1?".
> 3. **Wave thất bại → DỪNG HẲN** — Không bao giờ âm thầm chuyển sang Wave tiếp theo.
> 4. **Người dùng có thể từ chối bất kỳ Wave nào** — Agent phải chấp nhận và điều chỉnh.

---

## PHASE 0: TẠO WAVE PLAN (BẮT BUỘC ĐẦU TIÊN)

### Bước 1: Phân tích task domains

```
□ Security     → security-auditor, penetration-tester
□ Backend/API  → backend-specialist
□ Frontend/UI  → frontend-specialist
□ Database     → database-architect
□ Testing      → test-engineer
□ DevOps       → devops-engineer
□ Performance  → performance-optimizer
□ Planning     → project-planner
```

### Bước 2: Thiết kế Waves theo dependencies

- Agents **song song** (parallel): không phụ thuộc nhau → cùng Wave
- Agents **tuần tự** (sequential): B cần output của A → khác Wave  
- **Tối thiểu 3 agents, tối thiểu 2 waves** cho orchestration thực sự

### Bước 3: Trình bày Wave Plan

```
📋 WAVE PLAN cho: [Mô tả task ngắn]

┌─────────────────────────────────────────────────┐
│  🌊 WAVE 0 — Foundation (Nền tảng)              │
│  Agents: database-architect, security-auditor   │
│  Mục tiêu: Schema DB + Security baseline        │
│  Song song: ✅ Có thể chạy cùng lúc             │
├─────────────────────────────────────────────────┤
│  🌊 WAVE 1 — Core (Lõi)                         │
│  Agents: backend-specialist, frontend-specialist│
│  Phụ thuộc: Schema từ Wave 0                    │
│  Song song: ✅ Có thể chạy cùng lúc             │
├─────────────────────────────────────────────────┤
│  🌊 WAVE 2 — Polish (Hoàn thiện)                │
│  Agents: test-engineer, devops-engineer         │
│  Phụ thuộc: Code từ Wave 1                      │
│  Song song: ✅ Có thể chạy cùng lúc             │
└─────────────────────────────────────────────────┘

Tổng: X agents, Y waves.

⏸️ Anh có muốn điều chỉnh Wave Plan này không?
→ Gõ "OK" để bắt đầu Wave 0, hoặc cho em biết cần thay đổi gì.
```

> ⏸️ **DỪNG Ở ĐÂY. Đợi người dùng xác nhận trước khi tiếp tục.**

---

## PHASE 1: THỰC THI TỪNG WAVE

### Template báo cáo sau mỗi Wave:

```
✅ WAVE [N] HOÀN THÀNH

Agents đã chạy:
| Agent | Công việc | Kết quả |
|-------|-----------|---------|
| database-architect | Thiết kế schema | ✅ Done |

Deliverables:
- ✅ [File/Artifact đã tạo/sửa]
- ✅ [Quyết định quan trọng đã chốt]

⚠️ Vấn đề phát sinh (nếu có): [Mô tả + Đề xuất]

──────────────────────────────────────
⏸️ Tiếp theo: WAVE [N+1] — [Tên + Agents]
→ Gõ "OK" để tiếp tục, hoặc cho em biết nếu cần điều chỉnh.
```

### Nếu Wave thất bại:

```
❌ WAVE [N] THẤT BẠI

Nguyên nhân: [Mô tả lỗi cụ thể]
Agent/File bị lỗi: [Tên]

Phương án xử lý:
A) [Thử lại cách khác]
B) [Bỏ qua, xử lý thủ công]
C) [Thay agent khác]

⏸️ Em DỪNG LẠI và đợi anh chỉ thị. Không tự tiếp tục.
```

---

## 🔴 Minimum Agent Requirement

> ⚠️ **ORCHESTRATION = TỐI THIỂU 3 AGENTS KHÁC NHAU**
> Dùng ít hơn 3 agents = Delegation, không phải Orchestration.

### Agent Selection Matrix

| Task Type | REQUIRED Agents (minimum) |
|-----------|---------------------------|
| **Web App** | frontend-specialist, backend-specialist, test-engineer |
| **API** | backend-specialist, security-auditor, test-engineer |
| **UI/Design** | frontend-specialist, seo-specialist, performance-optimizer |
| **Database** | database-architect, backend-specialist, security-auditor |
| **Full Stack** | project-planner, frontend-specialist, backend-specialist, devops-engineer |
| **Debug** | debugger, explorer-agent, test-engineer |
| **Security** | security-auditor, penetration-tester, devops-engineer |

---

## Available Agents (17 total)

| Agent | Domain | Use When |
|-------|--------|----------|
| `project-planner` | Planning | Task breakdown, PLAN.md |
| `explorer-agent` | Discovery | Khám phá codebase |
| `frontend-specialist` | UI/UX | React, Vite, CSS, HTML |
| `backend-specialist` | Server | API, Node.js, Express |
| `database-architect` | Data | SQL, Prisma, Schema |
| `security-auditor` | Security | Vulnerabilities, Auth |
| `penetration-tester` | Security | Active testing |
| `test-engineer` | Testing | Unit, E2E, Coverage |
| `devops-engineer` | Ops | CI/CD, Docker, Deploy |
| `mobile-developer` | Mobile | React Native, Flutter |
| `performance-optimizer` | Speed | Lighthouse, Profiling |
| `seo-specialist` | SEO | Meta, Schema, Rankings |
| `documentation-writer` | Docs | README, API docs |
| `debugger` | Debug | Error analysis |
| `game-developer` | Games | Unity, Godot |
| `orchestrator` | Meta | Coordination |

---

## Context Passing to Sub-agents (BẮT BUỘC)

Khi gọi bất kỳ sub-agent nào PHẢI bao gồm:

```
CONTEXT:
- Original request: [Yêu cầu gốc]
- Wave Plan: [Tóm tắt các Wave]
- Previous wave output: [Những gì đã làm trước đó]
- Key decisions: [Các quyết định kỹ thuật đã chốt]

TASK: [Mô tả rõ ràng công việc wave này]
```

> ⚠️ Gọi sub-agent thiếu context = sub-agent sẽ đưa ra giả định sai!

---

## Kiểm tra ADR (Kiến trúc)

Trước Wave nào ảnh hưởng kiến trúc, đọc file ADR của project:
```
docs/technical/DECISIONS.md
# hoặc tùy project: docs/ADR.md, ARCHITECTURE.md, etc.
```
Đảm bảo không mâu thuẫn với ADR đang Active.

---

## Output Format — Báo cáo Cuối

```markdown
## 🎼 Orchestration Report

### Task
[Tóm tắt yêu cầu gốc]

### Wave Summary
| Wave | Agents | Trạng thái |
|------|--------|-----------|
| Wave 0 | DB + Security | ✅ Done |
| Wave 1 | Backend + Frontend | ✅ Done |
| Wave 2 | Test + DevOps | ✅ Done |

### Agents đã dùng (≥ 3)
| # | Agent | Công việc | Kết quả |
|---|-------|-----------|---------|
| 1 | ... | ... | ✅ |

### Deliverables
- [ ] [Feature/File tạo]
- [ ] Tests passing
- [ ] Docs updated

### ADR Conflicts
- Không có / [Mô tả nếu có]

### Summary
[Đoạn tóm tắt tổng thể]
```

---

## 🔴 EXIT GATE

Trước khi hoàn thành, xác nhận:

1. ✅ **Wave Plan** đã được người dùng duyệt trước khi chạy
2. ✅ **Mỗi Wave** có báo cáo kết quả sau khi hoàn thành
3. ✅ **Agent Count** ≥ 3
4. ✅ **ADRs** đã được kiểm tra với mọi Wave ảnh hưởng kiến trúc
5. ✅ **Không Wave nào thất bại** (hoặc đã được người dùng xử lý)

> Nếu bất kỳ check nào fail → KHÔNG đánh dấu orchestration hoàn thành.

---

**Bắt đầu bằng cách phân tích task và trình bày Wave Plan cho người dùng duyệt.**
