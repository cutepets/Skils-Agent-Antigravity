---
description: TDD workflow - Viết test trước, implement sau (Red → Green → Refactor)
---

# /tdd — Test-Driven Development Workflow

// turbo-all

## Bước 1: Xác định scope
Trước khi viết bất kỳ code nào, đọc skill `tdd-master-workflow` để nắm vững Red-Green-Refactor cycle.

Sau đó hỏi user (nếu chưa rõ):
- Function / service / route nào cần test?
- Unit test hay integration test?
- Backend (`apps/backend`) hay Frontend (`apps/frontend`)?

---

## Bước 2: Setup môi trường test (chỉ lần đầu)

### Backend (Vitest + Supertest)
```bash
cd apps/backend && npm install -D vitest @vitest/coverage-v8 supertest @types/supertest
```

Tạo `apps/backend/vitest.config.ts` nếu chưa có:
```typescript
import { defineConfig } from 'vitest/config'
export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: { reporter: ['text', 'html'], threshold: { lines: 80 } },
    include: ['src/**/*.test.ts', 'src/**/*.spec.ts'],
  },
})
```

### Frontend (Vitest + Testing Library - đã có Vite)
```bash
cd apps/frontend && npm install -D vitest @vitest/coverage-v8 @testing-library/react @testing-library/jest-dom jsdom
```

---

## Bước 3: 🔴 RED — Viết test thất bại trước

Tạo file test tại cùng folder với file cần test: `*.test.ts`

Quy tắc đặt tên:
```
should_[expected_behavior]_when_[condition]
```

Chạy để xác nhận test ĐỎ:
```bash
# Backend
cd apps/backend && npx vitest run --reporter=verbose

# Frontend
cd apps/frontend && npx vitest run --reporter=verbose
```

---

## Bước 4: 🟢 GREEN — Implement minimal code

- Chỉ viết đủ code để test pass
- Không over-engineer, không thêm tính năng chưa có test

Chạy lại test:
```bash
npx vitest run
```

---

## Bước 5: 🔵 REFACTOR — Làm sạch code

- Xóa duplication
- Cải thiện naming
- Đảm bảo test vẫn xanh sau refactor

---

## Bước 6: Coverage Report

```bash
# Backend
cd apps/backend && npx vitest run --coverage

# Frontend
cd apps/frontend && npx vitest run --coverage
```

Mục tiêu: **> 80% line coverage** trên business logic (services).

---

## Chú ý dự án Petshop

- Mock Prisma client: `vi.mock('@prisma/client')`
- Mock JWT middleware: `vi.mock('../middleware/auth')`
- Test priority: services > routes > utilities
- Đặt file test: `src/services/__tests__/` hoặc cạnh file gốc
