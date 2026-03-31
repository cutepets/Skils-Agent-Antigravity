---
name: database-migration
description: >
  MASTER DB: Zero-Downtime, Schema Design (3NF), SQL/NoSQL, Data Sync, 
  Rollback strategies. Use for DB changes, migrations, and performance tuning.
---

# 🗄️ Database Migration Master Skill

You are a **Senior Database Administrator and Schema Architect**. You ensure data integrity, performance, and availability.

---

## 🛠️ Execution Protocol

1. **Dry Run**: Always simulate the migration before execution.
   ```bash
   npx prisma migrate dev --name <name> --create-only
   # Review generated SQL in prisma/migrations/
   ```
2. **Plan Zero-Downtime**: Design the transition strategy.
3. **Execute & Observe**: Run migration and monitor DB health.
4. **Rollback Ready**: Know the undo steps before starting.

---

## 🏪 POS/ERP Schema — Petshop Project

> **Stack**: PostgreSQL + Prisma ORM + NestJS backend

### Domain Model Map
```
Product (1) ──── (∞) ProductVariant   ← tên phiên bản, SKU, barcode, giá
Product (1) ──── (∞) ConversionUnit   ← quy đổi đơn vị (hộp → viên)
Product (∞) ──── (∞) Branch           ← tồn kho theo chi nhánh (Stock table)
Order (1) ──── (∞) OrderItem          ← ProductVariant + qty + price
Customer (1) ──── (∞) Pet             ← thú cưng của khách
Customer (1) ──── (∞) Order
Branch (1) ──── (∞) Order             ← đơn theo chi nhánh
PurchaseReceipt (1) ──── (∞) ReceiptItem
Employee (∞) ──── (∞) Branch
```

### Prisma Migration Workflow
```bash
# 1. Sửa schema.prisma
# 2. Tạo migration file (dry-run)
npx prisma migrate dev --name add_stock_table --create-only

# 3. Review file trong prisma/migrations/
# 4. Apply
npx prisma migrate deploy

# 5. Regenerate client
npx prisma generate

# Seed data
cd apps/backend
npx ts-node scripts/seed-products.ts
npx ts-node scripts/seed-customers.ts
```

### Key Indexes — Cần có
```prisma
// Product search
@@index([name])
@@index([isActive])

// ProductVariant lookup (POS tìm kiếm)
@@index([sku])
@@index([barcode])
@@index([productId])

// Stock
@@index([branchId, productVariantId])

// Order queries
@@index([customerId, createdAt])
@@index([branchId, status, createdAt])
```

### N+1 Query Prevention
```typescript
// ❌ BAD: Gọi variants riêng trong loop
const products = await prisma.product.findMany()
for (const p of products) {
  p.variants = await prisma.productVariant.findMany({ where: { productId: p.id } })
}

// ✅ GOOD: Eager load một lần
const products = await prisma.product.findMany({
  include: {
    variants: true,
    conversions: true,
    stock: { include: { branch: { select: { id: true, name: true } } } },
  },
  where: { isActive: true },
  orderBy: { name: 'asc' },
})
```

### Safe Migration Checklist
- [ ] Thêm column mới với `DEFAULT` value (không breaking)
- [ ] Rename: tạo column mới → copy data → xóa cũ (3 bước tách riêng)
- [ ] Xóa column: deprecate 1 release → xóa release sau
- [ ] Thêm index lớn: dùng `CREATE INDEX CONCURRENTLY` để không lock table
- [ ] Seed data: script riêng, chạy sau migrate

### Common Prisma Patterns for POS
```typescript
// Tìm sản phẩm theo SKU hoặc barcode (POS scan)
const variant = await prisma.productVariant.findFirst({
  where: {
    OR: [{ sku: query }, { barcode: query }],
  },
  include: { product: true },
})

// Tồn kho theo chi nhánh
const stock = await prisma.stock.findMany({
  where: { productVariantId: variantId },
  include: { branch: { select: { id: true, name: true } } },
})

// Đơn hàng với đầy đủ thông tin
const order = await prisma.order.findUnique({
  where: { id: orderId },
  include: {
    items: { include: { variant: { include: { product: true } } } },
    customer: { include: { pets: true } },
    branch: true,
  },
})
```

---
*Updated 2025-03 with Petshop POS/ERP context.*
