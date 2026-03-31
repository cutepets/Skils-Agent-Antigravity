---
name: prisma-orm
description: >
  Prisma ORM best practices — schema design conventions, migration workflow,
  query optimization, N+1 prevention, transactions, seeding patterns.
  For PostgreSQL + NestJS stack.
---

# 🗃️ Prisma ORM Best Practices

You are a **Prisma Expert**. You write efficient, safe, and maintainable database queries.

---

## 📑 Internal Menu
1. [Schema Design Conventions](#1-schema-design-conventions)
2. [Migration Workflow](#2-migration-workflow)
3. [Query Patterns](#3-query-patterns)
4. [N+1 Prevention](#4-n1-prevention)
5. [Transactions](#5-transactions)
6. [Performance Optimization](#6-performance-optimization)
7. [Seeding Patterns](#7-seeding-patterns)
8. [Type Safety](#8-type-safety)

---

## 1. Schema Design Conventions

```prisma
model Order {
  id          String      @id @default(cuid())  // ✅ cuid() for URL-safe IDs
  status      OrderStatus @default(PENDING)
  total       Decimal     @db.Decimal(10, 2)    // ✅ Decimal for money, NOT Float
  note        String?                            // ✅ Optional with ?
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  
  // Relations
  customerId  String
  customer    Customer    @relation(fields: [customerId], references: [id])
  items       OrderItem[]

  // Indexes — ALWAYS add for frequent query fields
  @@index([customerId, createdAt])
  @@index([status, createdAt])
}

enum OrderStatus {
  PENDING
  CONFIRMED
  COMPLETED
  CANCELLED
}
```

**Schema Rules:**
- ✅ Use `cuid()` for IDs (URL-safe, sortable)
- ✅ Use `Decimal` for money — NEVER `Float` (floating point errors)
- ✅ Always `createdAt` + `updatedAt` on every model
- ✅ Explicit `@@index` on all frequently queried fields
- ❌ No `@default(autoincrement())` for distributed systems

---

## 2. Migration Workflow

```bash
# 1. Edit schema.prisma
# 2. Create migration (dry run first — review SQL before applying)
npx prisma migrate dev --name add_order_status --create-only

# 3. Review generated SQL in prisma/migrations/
# 4. Apply
npx prisma migrate dev --name add_order_status

# Production deploy
npx prisma migrate deploy

# Regenerate client after schema change
npx prisma generate

# Reset DB in dev (DANGER — wipes data)
npx prisma migrate reset
```

**Migration Safety Checklist:**
- [ ] Thêm column mới: always add `@default(value)` → non-breaking
- [ ] Rename: create new → copy data → drop old (3 separate migrations)
- [ ] Delete column: mark deprecated 1 release → delete next release
- [ ] Add index on large table: manual `CREATE INDEX CONCURRENTLY` to avoid table lock

---

## 3. Query Patterns

### Find with pagination
```typescript
async findMany(query: { page?: number; limit?: number; status?: string }) {
  const { page = 1, limit = 20, status } = query

  const [data, total] = await this.prisma.$transaction([
    this.prisma.order.findMany({
      where: { ...(status && { status }) },
      include: { customer: { select: { id: true, name: true } } },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    this.prisma.order.count({ where: { ...(status && { status }) } }),
  ])

  return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
}
```

### Upsert (create or update)
```typescript
await this.prisma.stock.upsert({
  where: { branchId_variantId: { branchId, variantId } },
  create: { branchId, variantId, quantity: delta },
  update: { quantity: { increment: delta } },
})
```

### Soft delete pattern
```typescript
// Schema: add deletedAt DateTime?
// Query: always filter
await this.prisma.product.findMany({
  where: { deletedAt: null, isActive: true },
})

// Soft delete
await this.prisma.product.update({
  where: { id },
  data: { deletedAt: new Date() },
})
```

### Select only needed fields (performance)
```typescript
// ❌ Avoid — fetches ALL fields including large ones
const user = await prisma.user.findUnique({ where: { id } })

// ✅ Select only what you need
const user = await prisma.user.findUnique({
  where: { id },
  select: { id: true, name: true, email: true },
})
```

---

## 4. N+1 Prevention

```typescript
// ❌ N+1 — 1 query for orders + N queries for each customer
const orders = await prisma.order.findMany()
for (const order of orders) {
  order.customer = await prisma.customer.findUnique({ where: { id: order.customerId } })
}

// ✅ Eager load — 1 query via JOIN
const orders = await prisma.order.findMany({
  include: {
    customer: { select: { id: true, name: true, phone: true } },
    items: {
      include: {
        variant: { select: { id: true, name: true, sku: true } }
      }
    },
  },
})
```

**Detection pattern:**
```typescript
// Enable Prisma query logging to spot N+1
const prisma = new PrismaClient({
  log: ['query'],  // log all queries in dev
})
// Watch for repeated queries with different IDs in logs
```

---

## 5. Transactions

```typescript
// Interactive transaction — full rollback on error
const result = await this.prisma.$transaction(async (tx) => {
  const order = await tx.order.create({ data: orderData })

  // Deduct stock
  for (const item of orderData.items) {
    await tx.stock.update({
      where: { branchId_variantId: { branchId, variantId: item.variantId } },
      data: { quantity: { decrement: item.qty } },
    })
  }

  // Create payment record
  await tx.payment.create({
    data: { orderId: order.id, amount: order.total, method: 'CASH' }
  })

  return order
})
```

**When to use transactions:**
- Multiple related writes (order + items + payment)
- Read-then-write operations (check stock, then deduct)
- Any operation that must be atomic

---

## 6. Performance Optimization

### Index Strategy
```prisma
// Composite index for common filter + sort
@@index([branchId, status, createdAt])

// Unique constraint (= unique index)
@@unique([branchId, variantId])

// Full-text search (PostgreSQL)
@@index([name(ops: raw("gin_trgm_ops"))], type: Gin)
```

### Query Optimization
```typescript
// ✅ Use findFirst instead of findMany + [0]
const latest = await prisma.order.findFirst({
  where: { customerId },
  orderBy: { createdAt: 'desc' },
})

// ✅ Count without fetching data
const total = await prisma.order.count({ where: { status: 'PENDING' } })

// ✅ Batch operations
await prisma.orderItem.createMany({ data: items })

// ✅ Use $queryRaw for complex analytics queries
const stats = await prisma.$queryRaw`
  SELECT DATE(created_at) as date, COUNT(*) as count
  FROM orders
  WHERE created_at >= NOW() - INTERVAL '30 days'
  GROUP BY DATE(created_at)
  ORDER BY date
`
```

---

## 7. Seeding Patterns

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()

async function seed() {
  console.log('🌱 Seeding...')

  // ✅ Use upsert to make seed idempotent (safe to re-run)
  const admin = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      name: 'Admin',
      role: 'ADMIN',
    },
  })

  console.log('✅ Seeded:', admin.email)
}

seed()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

```json
// package.json — run with: npx prisma db seed
{
  "prisma": {
    "seed": "ts-node --compiler-options {\"module\":\"CommonJS\"} prisma/seed.ts"
  }
}
```

---

## 8. Type Safety

```typescript
// Use Prisma-generated types
import { Order, Prisma } from '@prisma/client'

// Type for order with relations
type OrderWithItems = Prisma.OrderGetPayload<{
  include: { items: { include: { variant: true } } }
}>

// Type-safe where clause
const where: Prisma.OrderWhereInput = {
  status: { in: ['PENDING', 'CONFIRMED'] },
  createdAt: { gte: startDate },
}

// Return type from service
async findOne(id: string): Promise<Order | null> {
  return this.prisma.order.findUnique({ where: { id } })
}
```

---

## Quick Reference Cheatsheet

| Task | Pattern |
|------|---------|
| Create | `prisma.model.create({ data: dto })` |
| Read one | `prisma.model.findUnique({ where: { id } })` |
| Read many | `prisma.model.findMany({ where, orderBy, skip, take })` |
| Update | `prisma.model.update({ where: { id }, data: dto })` |
| Upsert | `prisma.model.upsert({ where, create, update })` |
| Delete | `prisma.model.delete({ where: { id } })` |
| Soft delete | `update({ data: { deletedAt: new Date() } })` |
| Count | `prisma.model.count({ where })` |
| Transaction | `prisma.$transaction(async (tx) => { ... })` |
| Raw SQL | `prisma.$queryRaw\`SELECT ...\`` |

---

*Stack: Prisma 5+ · PostgreSQL · TypeScript*
