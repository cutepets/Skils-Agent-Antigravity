---
description: Tạo và duy trì tài liệu API theo chuẩn OpenAPI 3.1 với Swagger UI
---

# /api-docs — API Documentation Workflow

// turbo-all

## Bước 1: Đọc skill
Đọc skill `api-documenter` để nắm chuẩn OpenAPI 3.1 và best practices.

---

## Bước 2: Cài đặt (chỉ lần đầu)

```bash
cd apps/backend && npm install swagger-ui-express @types/swagger-ui-express swagger-jsdoc @types/swagger-jsdoc
```

---

## Bước 3: Tạo OpenAPI config

Tạo `apps/backend/src/config/swagger.ts`:
```typescript
import swaggerJsdoc from 'swagger-jsdoc'

export const swaggerSpec = swaggerJsdoc({
  definition: {
    openapi: '3.1.0',
    info: {
      title: 'Petshop Service Management API',
      version: '1.0.0',
      description: 'API quản lý petshop - khách hàng, thú cưng, đơn hàng, spa, hotel',
    },
    servers: [{ url: 'http://localhost:3001/api', description: 'Development' }],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' }
      }
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ['./src/routes/*.ts'],
})
```

---

## Bước 4: Mount Swagger vào app

Trong `apps/backend/src/app.ts`, thêm:
```typescript
import swaggerUi from 'swagger-ui-express'
import { swaggerSpec } from './config/swagger'

app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Petshop API Docs',
}))
```

Truy cập tại: `http://localhost:3001/api/docs`

---

## Bước 5: Viết JSDoc cho từng route

Format chuẩn trên mỗi route handler:
```typescript
/**
 * @swagger
 * /customers:
 *   get:
 *     tags: [Customers]
 *     summary: Danh sách khách hàng
 *     parameters:
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *         description: Tìm kiếm theo tên/SĐT
 *     responses:
 *       200:
 *         description: Thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Customer'
 */
router.get('/', ...)
```

---

## Bước 6: Priority routes cần docs ngay

Theo thứ tự quan trọng:
1. `/auth` — Login, refresh token
2. `/customers` — CRUD + export/import
3. `/orders` — Tạo đơn, cập nhật thanh toán
4. `/pets` — CRUD thú cưng
5. `/grooming` — Đặt lịch spa
6. `/hotel` — Đặt phòng

---

## Bước 7: Validate spec

```bash
cd apps/backend && python .agent/skills/api-documenter/scripts/openapi_validator.py src/config/swagger.ts
```

Mục tiêu: 0 validation errors, tất cả endpoints có description + response schema.
