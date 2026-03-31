---
description: Muốn tạo tính năng mới từ A-Z? Dùng cái này.
---

# /create — Tạo tính năng mới (TDD-first)

$ARGUMENTS

---

## Quy trình chuẩn (Petshop Project)

### Bước 1: Phân tích yêu cầu
- Hiểu rõ tính năng cần làm
- Xác định: Backend route mới? Frontend page mới? Hay cả 2?
- Xác định schema Prisma có cần thêm field/model không

### Bước 2: Backend (nếu có API mới)

**2a. Service + Test (TDD)**
1. Tạo `src/services/__tests__/<module>.service.test.ts`
2. Viết test RED trước (dùng `vi.hoisted` + `vi.mock('../../config/database'`)`)
3. Implement service tại `src/services/<module>.service.ts`
4. Chạy: `npm run test:run` → confirm GREEN
5. Refactor nếu cần

**2b. Route**
1. Tạo/cập nhật `src/routes/<module>.routes.ts`
2. Thêm JSDoc swagger cho mỗi endpoint:
   ```typescript
   /**
    * @swagger
    * /endpoint:
    *   get:
    *     tags: [Module]
    *     summary: Mô tả ngắn
    */
   ```
3. Đăng ký route trong `src/app.ts` nếu là route mới

**2c. Prisma Schema (nếu cần)**
1. Sửa `prisma/schema.prisma`
2. Chạy: `npx prisma migrate dev --name <tên_migration>`
3. Chạy: `npx prisma generate`

### Bước 3: Frontend (nếu có UI mới)

**3a. Page/Component**
- Tạo `src/pages/<Module>Page.tsx`
- Dùng `useQuery` (TanStack Query) để fetch data
- Dùng `useMutation` cho create/update/delete
- Responsive: đảm bảo layout hoạt động trên màn hình nhỏ (tablet/phone)
- Tham khảo `modern-web-architect` skill cho component pattern

**3b. API Service**
- Thêm methods vào `src/services/api.service.ts`

**3c. Route**
- Thêm route mới vào `src/App.tsx`

### Bước 4: Kiểm tra cuối

```bash
# Backend tests
cd apps/backend && npm run test:run

# Build check
cd apps/backend && npm run build
cd apps/frontend && npm run build
```

Swagger docs: `http://localhost:3001/api/docs`

---

## Patterns chuẩn trong dự án

| Aspect | Pattern |
|--------|---------|
| Auth | JWT Bearer — `authMiddleware` từ `middleware/auth.ts` |
| Query | TanStack Query `useQuery` / `useMutation` |
| State | Zustand cho global, `useState` cho local |
| Mock test | `vi.hoisted()` + `vi.mock('../../config/database.js')` |
| Định dạng tiền | `formatCurrency()` từ `lib/utils.ts` |
| Định dạng ngày | `formatDate()` / `formatDateTime()` từ `lib/utils.ts` |

---

## Ví dụ sử dụng

```
/create module nhập hàng (purchase order)
/create trang thống kê doanh thu theo tháng
/create API tìm kiếm sản phẩm nâng cao
```
