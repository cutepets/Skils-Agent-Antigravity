---
description: Scan cấu hình AI agent và codebase để phát hiện lỗ hổng bảo mật,
  injection risks, misconfiguration. Dùng AgentShield + manual checklist cho Antigravity.
  Chạy trước khi commit config changes hoặc định kỳ security hygiene.
---

# /security-scan — AI Config & Code Security Audit

Scan toàn bộ AI agent configuration và project source cho Petshop Service Management.

## Quick Run

```bash
# Cài AgentShield (lần đầu)
npm install -g ecc-agentshield

# Scan .agent/ directory
npx ecc-agentshield scan --path c:\Dev\.agent

# Xuất report markdown
npx ecc-agentshield scan --path c:\Dev\.agent --format markdown

# Auto-fix safe issues
npx ecc-agentshield scan --path c:\Dev\.agent --fix
```

## Phạm Vi Scan Đầy Đủ

Đọc và kiểm tra **theo thứ tự**:

### 1. AI Config Files
```
c:\Dev\.agent\hooks.json          → Hook injection, data exfil
c:\Dev\.agent\rules\*.md          → Hardcoded secrets, unsafe instructions
c:\Dev\.agent\agents\*.md         → Tool access scope, prompt injection
c:\Dev\.agent\skills\*\SKILL.md   → Unsafe bash patterns
c:\Dev\.gemini\                   → Antigravity system config leaks
```

### 2. Project Security Sweep
```bash
# Secret detection trong source code
grep -rn "password\s*=" apps/ --include="*.ts" | grep -v "process.env" | grep -v "//"
grep -rn "Bearer " apps/ --include="*.ts" --include="*.tsx" | grep -v "process.env" | head -10

# .env không bị commit
git status | grep "\.env$"

# Dependencies với known vulnerabilities
cd apps/frontend && npm audit --audit-level=high
cd apps/backend && npm audit --audit-level=high
```

### 3. Backend API Security Check
```
□ CORS: chỉ allow localhost và production domain?
□ Rate limiting: có Helmet và rate-limit middleware?
□ JWT: secret từ env, expiry hợp lý?
□ Prisma: parameterized queries (không raw SQL tùy tiện)?
□ Upload: có validate file type/size không?
```

## Interpret & Fix

| Grade | Hành động |
|---|---|
| A-B | ✅ OK, commit bình thường |
| C | ⚠️ Ghi nhận, fix trong sprint này |
| D | 🚨 Fix trước khi merge/deploy |
| F | ❌ STOP — fix ngay lập tức |

Sau khi scan, dùng agent `security-auditor` để phân tích findings chi tiết và propose fixes.

## Khi Nào Chạy

- ✅ Sau khi sửa bất kỳ file trong `.agent/`
- ✅ Trước mỗi deploy lên server
- ✅ Định kỳ mỗi 2 tuần
- ✅ Sau khi thêm MCP server mới

---
> Skill chi tiết: `.agent/skills/security-scan/SKILL.md`
> Agent phân tích findings: `security-auditor`
