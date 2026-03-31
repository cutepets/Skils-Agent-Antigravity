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

## 🏪 POS/ERP Schema — Example Domain Model

> **Stack**: PostgreSQL + Prisma ORM (adapt for your ORM/DB)

### Domain Model Map (E-commerce/POS Example)
```
Product (1) ──── (∞) ProductVariant   ← name, SKU, barcode, price
Product (1) ──── (∞) ConversionUnit   ← unit conversion (box → piece)
Product (∞) ──── (∞) Branch           ← inventory per branch (Stock table)
Order (1) ──── (∞) OrderItem          ← ProductVariant + qty + price
Customer (1) ──── (∞) Order
Branch (1) ──── (∞) Order             ← orders per branch
Employee (∞) ──── (∞) Branch
```

### Prisma Migration Workflow
```bash
# 1. Edit schema.prisma
# 2. Create migration file (dry-run)
npx prisma migrate dev --name add_my_field --create-only

# 3. Review in prisma/migrations/
# 4. Apply
npx prisma migrate deploy

# 5. Regenerate client
npx prisma generate

# Seed data (adapt path to your project)
npx ts-node prisma/seed.ts
```

### Key Indexes — Common Patterns
```prisma
// Text search fields
@@index([name])
@@index([isActive])

// Lookup fields (SKU, barcode, slug)
@@index([sku])
@@index([barcode])
@@index([parentId])

// Inventory/stock
@@index([branchId, productVariantId])

// Order/transaction queries
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

### Common Prisma Patterns
```typescript
// Find by unique identifier (e.g., SKU or barcode scan)
const variant = await prisma.productVariant.findFirst({
  where: {
    OR: [{ sku: query }, { barcode: query }],
  },
  include: { product: true },
})

// Find with branch/location filter
const stock = await prisma.stock.findMany({
  where: { productVariantId: variantId },
  include: { branch: { select: { id: true, name: true } } },
})

// Fetch with full nested relations
const order = await prisma.order.findUnique({
  where: { id: orderId },
  include: {
    items: { include: { variant: { include: { product: true } } } },
    customer: true,
    branch: true,
  },
})
```

---
*Generalized 2026-03. Patterns applicable to any Prisma + PostgreSQL stack.*
