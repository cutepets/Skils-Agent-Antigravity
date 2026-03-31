---
name: context-budget
description: >
  Audit context window consumption của agent framework. Dùng khi: output quality
  đang giảm, thêm nhiều skills/agents gần đây, muốn biết còn bao nhiêu context
  headroom. Phân tích agents + skills + rules + MCP servers, tìm bloat và suggest
  optimizations. Kích hoạt với /context-budget command.
---

# Context Budget — Agent Framework Auditor

Phân tích token overhead của toàn bộ agent setup. Surface actionable optimizations
để giải phóng context space.

## Token Estimation Formula

```
Prose content:  words × 1.3 tokens
Code content:   characters / 4 tokens
File weight:    (prose_words × 1.3) + (code_chars / 4)
```

## Phase 1: Inventory

### Agents (`agents/*.md`)

```bash
# Count lines mỗi agent file
Get-ChildItem .agent/agents/*.md | ForEach-Object {
  [PSCustomObject]@{
    Name = $_.Name
    Lines = (Get-Content $_).Count
    KB = [math]::Round($_.Length/1024, 1)
  }
} | Sort-Object -Desc Lines | Format-Table
```

**Flags:**
- > 200 dòng → "heavy agent" (loads full into Task tool context)
- description frontmatter > 30 words → "bloated description"
- model: opus → expensive, chỉ dùng khi thực sự cần

### Skills (`skills/*/SKILL.md`)

```bash
Get-ChildItem .agent/skills -Recurse -Filter SKILL.md | ForEach-Object {
  [PSCustomObject]@{
    Skill = $_.Directory.Name
    Lines = (Get-Content $_).Count
    KB = [math]::Round($_.Length/1024, 1)
  }
} | Sort-Object -Desc Lines | Format-Table
```

**Flags:**
- > 400 dòng → review xem có thể trim không
- Duplicate content với agent khác → redundant

### Rules (`rules/**/*.md`, `GEMINI.md`)

**Flags:**
- > 100 dòng/file → xem có outdated content không
- Combined > 300 dòng → cần prune

### MCP Servers

**Estimate:** ~500 tokens per tool schema

**Flags:**
- > 10 MCP servers → quá nhiều
- MCP server chỉ wrap CLI tools (git, npm, gh) → thay bằng run_command
- Server với > 20 tools → rất tốn context

## Phase 2: Classify

| Bucket | Tiêu chí | Action |
|--------|----------|--------|
| **Always needed** | Referenced trong GEMINI.md, backs active command, daily use | Giữ |
| **Sometimes needed** | Domain-specific, không reference thường xuyên | Load on-demand |
| **Rarely needed** | Không có command reference, content trùng lặp | Remove hoặc lazy-load |

## Phase 3: Detect Problems

### Problem Patterns

1. **Bloated agent descriptions**
   - Description > 30 words loads vào MỌI Task tool invocation
   - Fix: trim xuống 20-25 words, keep chỉ trigger conditions

2. **Heavy agents**
   - File > 200 dòng inflate Task tool context
   - Fix: extract ví dụ code vào separate examples/, giữ agent file lean

3. **Redundant skills vs agents**
   - Agent đã cover content → skill là duplicate
   - Fix: agent reference skill, không duplicate content

4. **MCP over-subscription**
   - Mỗi MCP tool schema ~500 tokens
   - 30-tool server = ~15,000 tokens overhead — nhiều hơn tất cả skills cộng lại
   - Fix: giảm số MCP servers, remove servers có thể thay bằng run_command

5. **GEMINI.md bloat**
   - Outdated sections, verbose explanations
   - Instructions nên nằm trong rules, không phải GEMINI.md
   - Fix: prune thường xuyên

## Phase 4: Report Format

```
Context Budget Report — [project name]
═══════════════════════════════════════
Model: Claude Sonnet 4.x (200K window)
Framework: Antigravity

Component Breakdown:
┌──────────────────┬───────┬───────────┐
│ Component        │ Count │ Est Tokens│
├──────────────────┼───────┼───────────┤
│ Agents           │ N     │ ~X,XXX    │
│ Skills           │ N     │ ~X,XXX    │
│ Rules            │ N     │ ~X,XXX    │
│ GEMINI.md        │ 1     │ ~X,XXX    │
│ MCP tools        │ N     │ ~XX,XXX   │
└──────────────────┴───────┴───────────┘
Total overhead:     ~XX,XXX tokens (XX% của 200K)
Available:          ~XXX,XXX tokens (XX%)

⚠️ Issues Found (N):

Heavy agents (> 200 dòng):
  - [name].md: XXX dòng → trim examples, save ~X,XXX tokens

Bloated descriptions:
  - [name].md: description = "XX words" → trim xuống < 25 words

MCP servers:
  - [server-name]: XX tools → X,XXX tokens

Top 3 Optimizations:
1. [action] → save ~X,XXX tokens
2. [action] → save ~X,XXX tokens
3. [action] → save ~X,XXX tokens

Potential savings: ~XX,XXX tokens (XX% reduction)
```

## Quick Limits (Antigravity Stack)

| Component | Healthy | Warning | Critical |
|-----------|---------|---------|----------|
| Agents (lines/file) | < 150 | 150-250 | > 250 |
| Skills (lines/file) | < 300 | 300-500 | > 500 |
| Rules per file | < 80 | 80-120 | > 120 |
| Active MCP servers | < 8 | 8-12 | > 12 |
| GEMINI.md | < 150 | 150-250 | > 250 |

## Best Practices

- **MCP là đòn bẩy lớn nhất**: Mỗi tool ~500 tokens; 1 server 30 tools = 15K tokens
- **Agent descriptions load luôn**: Kể cả agent không được gọi — trim ruthlessly
- **Audit sau mỗi lần add**: Chạy ngay sau khi thêm agent/skill/MCP mới
- **Model mapping**: Không dùng `opus` nếu `sonnet` đủ — đắt và chậm hơn
- **Lazy skills**: Skills không dùng hàng ngày → move sang separate repo, load khi cần

## Triggerwords

Chạy skill này khi bất kỳ ai nói:
- "/context-budget"
- "context đang nhiều quá"
- "output chậm/kém hơn"
- "check token usage"
- "agent framework nặng"
- "cần trim context"
