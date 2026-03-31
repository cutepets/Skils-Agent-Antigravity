---
description: Khi gặp build/TypeScript error, lint error, hoặc Vite proxy error. AI diagnose nhanh,
  fix minimal, verify — không chạy lại toàn bộ dev server.
---

# /build-fix — Fix Build Errors Nhanh

Dùng khi: TypeScript compile error, Vite build error, ESLint blocking, Prisma type error.

## Bước 1: Xác Định Loại Error

Phân loại error nhận được:

| Loại | Ví dụ | Approach |
|---|---|---|
| TypeScript type error | `TS2339: Property 'x' does not exist` | Fix type/interface |
| Import error | `Cannot find module './foo'` | Check file path/export |
| Prisma type error | `Type 'X' is not assignable to type 'Y'` | Regenerate + fix |
| Vite proxy error | `[vite] http proxy error` | Check backend running |
| ESLint error | `no-unused-vars` | Fix hoặc disable với comment |

## Bước 2: Diagnose — Không Đoán Mò

```bash
# TypeScript: Chỉ check file liên quan trước
npx tsc --noEmit --skipLibCheck 2>&1 | grep "error TS" | head -20

# Vite: Check backend có đang chạy không
curl -s http://localhost:3001/health

# Prisma: Regenerate types nếu schema thay đổi
cd apps/backend && npx prisma generate
```

Đọc error message đầy đủ. Tìm **root cause**, không chỉ symptom.

## Bước 3: Fix Strategy

### TypeScript Error
1. Đọc file lỗi tại line được chỉ định
2. Đọc interface/type liên quan
3. Fix minimal — không thay đổi logic

### Vite Proxy Error
```bash
# Check backend đang chạy chưa
curl http://localhost:3001/health
# Nếu không → backend down → không phải FE bug
```

### Prisma Type Error  
```bash
# Sau khi sửa schema.prisma
cd apps/backend && npx prisma generate && npx tsc --noEmit --skipLibCheck
```

### Missing Export/Import
```bash
# Tìm file export symbol
grep -r "export.*FunctionName\|export.*TypeName" apps/ --include="*.ts" --include="*.tsx"
```

## Bước 4: Verify Fix Nhỏ

```bash
# Chỉ check phần bị sửa — không full build
npx tsc --noEmit --skipLibCheck 2>&1 | grep "error TS" | wc -l
# Số = 0 → OK
```

## Bước 5: Report

```
## Build Fix Report

Error: [mô tả error]
Root Cause: [nguyên nhân thực sự]
Fix Applied: [thay đổi cụ thể — file:line]
Verify: [kết quả tsc check sau fix]
Side Effects: [có ảnh hưởng file nào khác không?]
```

## Anti-patterns — KHÔNG Làm

- ❌ Thêm `// @ts-ignore` để bỏ qua error
- ❌ Cast sang `as any` chỉ để qua lỗi
- ❌ Chạy lại `npm run dev` và hy vọng tự hết lỗi
- ❌ Fix symptom mà không hiểu root cause

---

> Gọi agent `typescript-reviewer` nếu cần review sâu hơn
> Dùng `/verify` sau khi fix nhiều errors cùng lúc
