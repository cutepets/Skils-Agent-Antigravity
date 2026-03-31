---
name: security-scan
description: >
  Scan cấu hình AI agent (.agent/ directory, GEMINI.md, hooks.json, MCP configs, rules)
  để phát hiện lỗ hổng bảo mật, misconfigurations, và injection risks.
  Dùng AgentShield (ecc-agentshield) cho static analysis tự động + manual checklist
  cho Antigravity-specific patterns. Kích hoạt trước khi commit config changes,
  sau khi thêm hooks/rules mới, hoặc định kỳ security hygiene.
---

# Security Scan — Petshop AI Agent Configuration

Audit toàn bộ cấu hình AI agent trong `.agent/` để phát hiện lỗ hổng bảo mật.

## Phạm Vi Scan

| File/Directory | Kiểm tra gì |
|---|---|
| `.agent/hooks.json` | Command injection, data exfiltration, silent error suppression |
| `.agent/rules/*.md` | Hardcoded secrets, auto-run instructions nguy hiểm |
| `.agent/agents/*.md` | Unrestricted tool access, prompt injection surface |
| `.agent/skills/*/SKILL.md` | Injection patterns, unsafe bash commands |
| `.agent/workflows/*.md` | Dangerous auto-run steps, unsafe shell commands |
| `c:\Dev\.gemini\` / `GEMINI.md` | System prompt injection, leaked credentials |

## Bước 1: AgentShield Static Scan (Tự Động)

AgentShield là tool từ ECC để scan AI config files với 102 rules.

```bash
# Cài AgentShield (chỉ cần lần đầu)
npm install -g ecc-agentshield

# Scan .agent/ directory (Antigravity target)
npx ecc-agentshield scan --path c:\Dev\.agent

# Hoặc scan toàn bộ project root (nhiều config hơn)
npx ecc-agentshield scan --path c:\Dev

# Format markdown để lưu lại
npx ecc-agentshield scan --path c:\Dev\.agent --format markdown > security-report.md

# Auto-fix safe issues
npx ecc-agentshield scan --path c:\Dev\.agent --fix
```

### Interpret Kết Quả
| Grade | Score | Action |
|---|---|---|
| A (90-100) | Secure | ✅ No action needed |
| B (75-89) | Minor issues | 🔧 Fix when convenient |
| C (60-74) | Needs attention | ⚠️ Fix before next feature |
| D (40-59) | Significant risks | 🚨 Fix before commit |
| F (0-39) | Critical | ❌ Fix immediately |

## Bước 2: Manual Checklist — Petshop-Specific

### 2a. Hooks Security (`.agent/hooks.json`)
```
□ Không có command injection qua biến untrusted input
□ Blocking hooks (exit 2) chỉ dùng cho mục đích thực sự cần thiết
□ Không có hook nào gửi data ra ngoài (curl đến external server)
□ Error suppression (|| true, 2>/dev/null) — có lý do hợp lý không?
□ Hooks không đọc/write ngoài project directory
```

### 2b. Rules Security (`.agent/rules/`)
```
□ Không có hardcoded API keys, passwords trong rules
□ Không có instruction yêu cầu AI "luôn chạy lệnh X" mà không hỏi
□ Không có rule override safety guardrails
□ GEMINI.md không có instructions leak sensitive data
```

### 2c. Agents Security (`.agent/agents/*.md`)
```
□ Agents không có tool access rộng hơn cần thiết
□ Không có agent nào được phép tự modify .env hoặc secrets
□ Prompt injection surface — description có thể bị manipulate không?
□ `penetration-tester.md` — có guardrails "chỉ test hệ thống được authorized" không?
```

### 2d. Skills Security (`.agent/skills/`)
```
□ Bash commands trong SKILL.md không có unsafe patterns
□ Không có skill nào hướng dẫn bypass authentication
□ search-first skill — không leak nội dung sensitive khi search
```

### 2e. Project Backend Security
```
□ .env không bị expose trong bất kỳ config file nào
□ Prisma connection string không hardcode
□ JWT secret không appear trong logs hoặc error messages
□ CORS settings restrictive đủ chưa?
□ Rate limiting cho API endpoints nhạy cảm?
```

## Bước 3: Secret Detection Sweep

```bash
# Scan toàn bộ .agent/ tìm patterns nhạy cảm
grep -r "password\s*=\s*['\"][^'\"]*['\"]" c:\Dev\.agent\ 2>/dev/null
grep -r "api_key\s*=\s*['\"][^'\"]*['\"]" c:\Dev\.agent\ 2>/dev/null
grep -r "Bearer [A-Za-z0-9\-_]{20,}" c:\Dev\.agent\ 2>/dev/null
grep -r "sk-[a-zA-Z0-9]{20,}" c:\Dev\.agent\ 2>/dev/null
grep -r "DATABASE_URL.*postgres://.*:.*@" c:\Dev\.agent\ 2>/dev/null

# Scan project source
grep -rn "process\.env\." apps/ --include="*.ts" | grep -v "// " | head -30
# Tìm ENV vars được dùng → verify tất cả có trong .env.example
```

## Bước 4: Hook Injection Analysis

Đọc từng hook trong `.agent/hooks.json` và check:

```
□ Command có dùng biến từ tool_input không? → Nguy cơ injection
□ Ví dụ an toàn: hardcoded path "c:/Dev/Petshop_Service_Management"
□ Ví dụ nguy hiểm: "$TOOL_INPUT_FILE" trong shell command mà không sanitize
□ Blocking hooks (exit 2) — có thể bị trigger sai khiến AI bị stuck?
```

## Output Report Template

```markdown
## 🔒 Security Scan Report — [date]

### AgentShield Results
- Grade: [A/B/C/D/F]
- Score: [0-100]
- Critical findings: [count]
- High findings: [count]
- Medium findings: [count]

### Critical Issues (Fix Now)
- [ ] [issue]: [file:line] → [fix]

### High Issues (Fix Before Next Commit)
- [ ] [issue]: [file] → [fix]

### Medium Issues (Fix This Week)
- [ ] [issue] → [recommendation]

### Manual Checklist
- Hooks security: ✅/⚠️/❌
- Rules security: ✅/⚠️/❌
- Agents security: ✅/⚠️/❌
- Secret detection: ✅/⚠️/❌
- Project backend: ✅/⚠️/❌

### Overall Verdict
[✅ Secure] [⚠️ Minor Issues] [🚨 Needs Attention] [❌ Critical - Fix Now]
```

## Links

- **AgentShield GitHub:** https://github.com/affaan-m/agentshield
- **npm:** https://www.npmjs.com/package/ecc-agentshield
- **ECC Security Skill:** https://github.com/affaan-m/everything-claude-code/blob/main/skills/security-scan/SKILL.md
