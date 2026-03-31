---
description: Chạy verification loop sau khi hoàn thành feature/fix. Kiểm tra TypeScript, API contracts,
  business logic integrity. Dùng sau mỗi thay đổi lớn để đảm bảo không regression.
---

# /verify — Verification Loop

Chạy verification loop cho thay đổi vừa thực hiện.

## Bước 1: TypeScript Check

```bash
# Frontend TypeScript
cd apps/frontend && npx tsc --noEmit --skipLibCheck 2>&1 | head -30 && cd ../..

# Backend TypeScript
cd apps/backend && npx tsc --noEmit --skipLibCheck 2>&1 | head -30 && cd ../..
```

Ghi nhận số lượng errors. Nếu có → list và classify (blocking/warning).

## Bước 2: API Contract Spot Check

Xác minh endpoints frontend đang gọi khớp với backend routes:
- Tìm API calls trong frontend source
- So sánh với backend route definitions
- Báo cáo nếu có mismatch

## Bước 3: Business Logic Check

Kiểm tra các flow critical của project:

1. **Core state machine:** Domain flow chính còn hoạt động đúng không?
2. **Key calculations:** Các tính toán quan trọng (balance, total, quota...) còn chính xác?
3. **File bị sửa:** Logic core có bị affect không?

## Bước 4: Server Health Check

```bash
# Thay port phù hợp với project
curl -s http://localhost:3000/health 2>/dev/null || echo "Backend not responding"
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 2>/dev/null
```

## Bước 5: Git Diff Review

```bash
git diff --stat HEAD
git diff HEAD | grep "^+" | grep -E "console\.log|TODO|FIXME|debugger" | head -10
```

Cảnh báo nếu có `console.log`, `TODO`, `debugger` trong staged changes.

## Output

Sau khi chạy xong, trình bày:

```
## Verification Report

### TypeScript
- Frontend: ✅ 0 errors / ❌ N errors
- Backend: ✅ 0 errors / ❌ N errors

### API Contracts
- Status: ✅ All matched / ⚠️ Issues: [list]

### Business Logic
- Order flow: ✅ OK / ❌ Issue detected
- Payment: ✅ OK / ❌ Issue detected

### Dev Server  
- Backend: ✅ Running / ❌ Down
- Frontend: ✅ Running / ❌ Down

### Verdict
✅ SAFE TO COMMIT — Pass tất cả bước
⚠️ COMMIT WITH CARE — [issues to note]
❌ DO NOT COMMIT — [blocking issues]
```

---

> Skill liên quan: `verification-loop` trong `.agent/skills/`
> Dùng sau mỗi: feature lớn, critical fix, schema migration, API changes
