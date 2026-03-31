---
name: autonomous-loops
description: >
  Patterns cho autonomous AI agent loops — từ sequential pipelines đơn giản đến
  multi-agent DAG systems. Dùng khi: setup workflow tự động không cần human
  intervention, chạy batch processing, continuous improvement loops, hoặc parallel
  agent execution với merge coordination.
---

# Autonomous Loops — Agentic Workflow Patterns

> Adapted from ECC v1.9.0. Credit: @disler, @AnandChowdhary, @enitrat

Patterns để chạy AI agents autonomously trong loops — từ script đơn giản đến
RFC-driven multi-agent pipelines.

## Loop Pattern Spectrum

| Pattern | Độ phức tạp | Phù hợp nhất |
|---------|------------|--------------|
| [Sequential Pipeline](#1-sequential-pipeline) | Thấp | Daily dev steps, scripted workflows |
| [De-Sloppify Pass](#2-de-sloppify-pass) | Add-on | Cleanup sau mỗi implement step |
| [Continuous PR Loop](#3-continuous-pr-loop) | Trung bình | Multi-day iterative projects |
| [Infinite Agentic Loop](#4-infinite-agentic-loop) | Trung bình | Parallel content/code generation |
| [RFC-Driven DAG](#5-rfc-driven-dag) | Cao | Large features, parallel work units |

---

## 1. Sequential Pipeline

Pattern đơn giản nhất. Chia workflow thành chuỗi non-interactive steps.

```bash
#!/usr/bin/env bash
# feature-pipeline.sh

set -e  # dừng ngay khi có error

# Dùng CLAUDE_SESSION hoặc tương đương để pass state giữa steps

# Step 1: Research — read-only, tìm hiểu codebase
claude -p "Đọc spec trong docs/feature-spec.md và codebase liên quan.
Viết implementation plan vào docs/impl-plan.md. KHÔNG sửa code."

# Step 2: Implement với TDD
claude -p "Đọc docs/impl-plan.md. Implement theo plan.
Viết tests trước (TDD). Commit từng bước nhỏ."

# Step 3: De-sloppify (cleanup riêng)
claude -p "Review tất cả changes trong working tree.
Xóa: console.log thừa, commented code, tests kiểm tra framework behavior.
Giữ: business logic tests. Run test suite sau khi clean."

# Step 4: Verify
claude -p "Run: npm run typecheck && npm run lint && npm test.
Sửa tất cả failures. KHÔNG thêm features mới."

# Step 5: Commit
claude -p "Tạo conventional commit cho changes. Format: 'feat(scope): description'"
```

### Key Design Principles

1. **Mỗi step = fresh context** — Không có context bleed giữa các `claude -p` calls
2. **Order matters** — Mỗi step build trên filesystem state của step trước
3. **`set -e`** — Pipeline dừng ngay khi có failure
4. **Negative instructions nguy hiểm** — Không dùng "đừng làm X" → thêm cleanup step riêng (xem #2)

### Variations

```bash
# Route tasks theo complexity
claude -p --model haiku "Fix typo trong README.md"           # nhanh
claude -p --model sonnet "Implement search feature với TDD"  # standard
claude -p --model opus "Review security architecture"        # deep reasoning

# Pass context qua file thay vì prompt dài
echo "Focus: auth module, rate limiting" > .task-context.md
claude -p "Đọc .task-context.md để biết priorities. Làm theo thứ tự."
rm .task-context.md

# Tool restrictions per step
claude -p --allowedTools "Read,Grep,Glob" \
  "Audit codebase tìm security vulnerabilities. KHÔNG sửa."

claude -p --allowedTools "Read,Write,Edit,Bash" \
  "Implement fixes từ security-audit.md"
```

---

## 2. De-Sloppify Pass

**Add-on cho mọi loop.** Thêm cleanup step sau mỗi implement step.

### Vấn đề khi dùng "Negative Instructions"
Khi nói "đừng viết type tests" trong implement prompt:
- Model trở nên dè dặt với MỌI tests
- Bỏ qua legitimate edge case tests
- Quality suy giảm không đoán được

### Giải pháp: Separate Cleanup Pass

```bash
# Step A: Implement (để nó thorough)
claude -p "Implement authentication với full TDD. Thorough với tests."

# Step B: De-sloppify (context riêng, focused)
claude -p "Review tất cả changes trong working tree. Xóa:
- Tests kiểm tra TypeScript/framework behavior thay vì business logic
- Redundant type checks mà type system đã đảm bảo
- Overly defensive error handling cho impossible states
- console.log statements
- Commented-out code blocks
- Duplicate logic

Giữ: tất cả business logic tests.
Run test suite sau cleanup để đảm bảo không break gì."
```

> **Key insight**: Hai specialized agents > một constrained agent.

---

## 3. Continuous PR Loop

Phù hợp với multi-day projects. Mỗi iteration tạo PR, chờ CI, merge.

### Core Loop

```
1. Tạo branch (feature/iteration-N)
2. Run claude -p với task
3. (Tùy chọn) De-sloppify pass
4. Commit + Push
5. Tạo PR
6. Chờ CI checks
7. CI fail? → Auto-fix pass
8. Merge (squash)
9. Return to main → repeat
```

### Context Bridge quan trọng: SHARED_TASK_NOTES.md

Mỗi `claude -p` bắt đầu fresh. Dùng file để bridge context giữa iterations:

```markdown
<!-- SHARED_TASK_NOTES.md -->
## Progress
- [x] Thêm tests cho auth module (iteration 1)
- [x] Fix edge case trong token refresh (iteration 2)
- [ ] Còn lại: rate limiting tests, error boundary tests

## Next Steps
- Focus vào rate limiting module tiếp theo
- Mock setup trong tests/helpers.ts có thể reuse

## Discoveries
- Prisma connection pool cần config riêng cho test env
- JWT secret phải read từ env, không hardcode
```

Claude đọc file này ở đầu mỗi iteration và update cuối iteration.

### Completion Signal

```bash
# Agent báo "xong" bằng magic phrase
claude -p "Fix all bugs. Khi hoàn thành tất cả, output:
TASK_COMPLETE_SIGNAL"

# Script detect signal để dừng loop
if output contains "TASK_COMPLETE_SIGNAL" for 2 consecutive iterations:
    break loop
```

### Stop Conditions (luôn cần ít nhất 1)

```bash
MAX_RUNS=10          # Dừng sau N iterations
MAX_COST=5.00        # Dừng khi tốn $X
MAX_DURATION=2h      # Dừng sau thời gian
COMPLETION_SIGNAL    # Agent tự báo xong
```

---

## 4. Infinite Agentic Loop

Orchestrator + Sub-agents song song, driven by specification file.

### Architecture: Two-Prompt System

```
ORCHESTRATOR                    SUB-AGENTS (N parallel)
┌──────────────────┐           ┌────────────────────┐
│ Đọc spec file    │           │ Nhận full context  │
│ Scan output dir  │ deploys   │ Đọc iteration số   │
│ Plan iterations  │──────────▶│ Follow spec chính  │
│ Assign direction │  N agents │ Generate output    │
│ Manage waves     │           │ Save vào output dir│
└──────────────────┘           └────────────────────┘
```

### Pattern

```markdown
<!-- .agent/commands/generate-variants.md -->
Parse arguments: spec_file, output_dir, count (number hoặc "infinite")

PHASE 1: Đọc và hiểu spec file sâu.
PHASE 2: List output_dir, tìm iteration cao nhất. Start từ N+1.
PHASE 3: Plan creative directions — mỗi agent KHÁC approach/theme.
PHASE 4: Deploy sub-agents song song (Task tool). Mỗi agent nhận:
  - Full spec text
  - Snapshot output dir hiện tại
  - Iteration number cụ thể
  - Creative direction riêng
PHASE 5 (infinite mode): Waves 3-5 agents cho đến khi context thấp.
```

### Batching Strategy

| Count | Strategy |
|-------|----------|
| 1-5 | Tất cả agents cùng lúc |
| 6-20 | Batches 5 agents |
| Infinite | Waves 3-5, progressive sophistication |

**Key insight**: Orchestrator **assigns** creative direction — không để agents tự differentiate. Prevents duplicate output.

---

## 5. RFC-Driven DAG

Pattern phức tạp nhất. Cho large features với nhiều work units.

### Khi nào dùng

| Signal | RFC-DAG | Pattern đơn giản hơn |
|--------|---------|---------------------|
| Multiple interdependent work units | ✅ | ❌ |
| Parallel implementation cần thiết | ✅ | ❌ |
| Merge conflicts likely | ✅ | ❌ |
| Single-file change | ❌ | ✅ Sequential |
| Multi-day project lớn | ✅ | Có thể |

### Architecture

```
RFC/PRD Document
      │
      ▼ DECOMPOSITION
  Chia thành work units với dependency DAG
      │
      ▼ EXECUTION PER DAG LAYER
  Layer 0: [unit-a, unit-b]  ← parallel (no deps)
  Layer 1: [unit-c]          ← depends on unit-a
  Layer 2: [unit-d, unit-e]  ← depend on unit-c

  Mỗi unit: Research → Plan → Implement → Test → Review
      │
      ▼ MERGE QUEUE
  Rebase → Run tests → Land hoặc Evict (retry với context)
```

### Work Unit Definition

```typescript
interface WorkUnit {
  id: string;              // "auth-middleware"
  name: string;            // "Authentication Middleware"
  description: string;
  deps: string[];          // ["user-model"] — dependencies
  acceptance: string[];    // Concrete success criteria
  tier: "trivial" | "small" | "medium" | "large";
}
```

### Complexity Tiers → Pipeline Depth

| Tier | Pipeline |
|------|---------|
| **trivial** | implement → test |
| **small** | implement → test → code-review |
| **medium** | research → plan → implement → test → review |
| **large** | research → plan → implement → test → dual-review → fix → final-review |

### Author-Bias Elimination

> **Critical**: Reviewer KHÔNG ĐƯỢC là người viết code đó.

Mỗi stage = separate context window = separate agent process.
Stage review nhận output từ stage implement — không có shared context.

---

## Decision Matrix

```
Task là single focused change?
├─ Yes → Sequential Pipeline
└─ No → Có written spec/RFC?
         ├─ Yes → Cần parallel implementation?
         │        ├─ Yes → RFC-Driven DAG
         │        └─ No → Continuous PR Loop
         └─ No → Cần nhiều variations cùng spec?
                  ├─ Yes → Infinite Agentic Loop
                  └─ No → Sequential Pipeline + De-Sloppify
```

## Anti-Patterns — Không Làm

| Anti-pattern | Tại sao sai | Fix |
|-------------|------------|-----|
| Infinite loop không có exit condition | Tốn tiền vô hạn | Luôn có max-runs/max-cost/signal |
| Không bridge context giữa iterations | Mỗi step bắt đầu từ đầu | Dùng SHARED_TASK_NOTES.md |
| Retry cùng failure không thêm context | Fail lại | Capture error, feed vào next attempt |
| Negative instructions thay vì cleanup | Quality suy giảm | Thêm separate cleanup step |
| Tất cả agents trong 1 context window | Reviewer = author | Separate context per stage |
| Parallel agents edit cùng file | Merge conflicts | Sequential landing hoặc worktrees |

## Combining Patterns

**Phổ biến nhất**: Sequential Pipeline + De-Sloppify

```bash
for feature in "${features[@]}"; do
  claude -p "Implement $feature với TDD."
  claude -p "Cleanup pass: remove slop, run tests."
  claude -p "Run build + lint + tests. Fix failures."
  claude -p "Commit: feat: add $feature"
done
```

**Mạnh hơn**: Continuous Loop + Verification Gate

```bash
continuous-loop \
  --implement-prompt "..." \
  --review-prompt "Run npm test && npm run lint. Fix failures." \
  --gate-skill "verification-loop" \
  --max-runs 10
```

## Petshop-Specific Use Cases

- **Batch import sản phẩm**: Sequential pipeline với validation step
- **Auto-generate test data**: Infinite loop với spec file
- **Refactor large file** (NewOrderPage 2000 dòng): RFC-DAG với work units per section
- **CI fix loop**: Continuous PR loop với `--ci-retry-max 3`
