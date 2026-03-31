---
name: postgres-best-practices
description: PostgreSQL performance optimization và best practices từ Supabase Engineering, adapted cho Prisma ORM. Dùng khi viết, review, hoặc optimize Postgres queries, schema designs, hoặc database configurations. Kích hoạt khi làm việc với database performance, indexing, schema design, hoặc query optimization.
license: MIT
metadata:
  author: supabase (adapted)
  source: https://github.com/supabase/agent-skills/tree/main/skills/supabase-postgres-best-practices
  version: "1.1.0"
---

# PostgreSQL Best Practices

Comprehensive performance optimization guide cho PostgreSQL + Prisma, maintained based on Supabase best practices. Gồm rules chia thành 8 categories, ưu tiên theo impact để guide automated query optimization và schema design.

## When to Apply

- Viết SQL queries hoặc design schemas
- Implement indexes hoặc query optimization
- Review database performance issues
- Configuring connection pooling
- Optimizing Prisma queries

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Query Performance | CRITICAL | `query-` |
| 2 | Connection Management | CRITICAL | `conn-` |
| 3 | Security | CRITICAL | `security-` |
| 4 | Schema Design | HIGH | `schema-` |
| 5 | Concurrency & Locking | MEDIUM-HIGH | `lock-` |
| 6 | Data Access Patterns | MEDIUM | `data-` |
| 7 | Monitoring & Diagnostics | LOW-MEDIUM | `monitor-` |
| 8 | Advanced Features | LOW | `advanced-` |

## 1. Query Performance (CRITICAL)

### Missing Indexes
```sql
-- ❌ BAD: Full table scan
SELECT * FROM orders WHERE customer_id = 'abc';

-- ✅ GOOD: Add index
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

**Prisma schema:**
```prisma
model Order {
  customerId String
  @@index([customerId])  // thêm cái này!
}
```

### Select Only What You Need
```typescript
// ❌ BAD: Over-fetching
const orders = await prisma.order.findMany()

// ✅ GOOD: Select specific fields
const orders = await prisma.order.findMany({
  select: {
    id: true,
    status: true,
    totalAmount: true,
    customer: { select: { name: true, phone: true } }
  }
})
```

### N+1 Queries
```typescript
// ❌ BAD: N+1
const orders = await prisma.order.findMany()
for (const order of orders) {
  const customer = await prisma.customer.findUnique({ // N queries!
    where: { id: order.customerId }
  })
}

// ✅ GOOD: Include relation
const orders = await prisma.order.findMany({
  include: { customer: true }  // 1 JOIN query
})
```

### Pagination — Always Required
```typescript
// ❌ BAD: No pagination (loads entire table)
const orders = await prisma.order.findMany()

// ✅ GOOD: Cursor-based pagination (best for large datasets)
const orders = await prisma.order.findMany({
  take: 20,
  cursor: lastCursor ? { id: lastCursor } : undefined,
  orderBy: { createdAt: 'desc' }
})
```

## 2. Connection Management (CRITICAL)

### Prisma Connection Pooling
```typescript
// ✅ GOOD: Singleton Prisma client
// prisma.service.ts
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect()
  }
  async onModuleDestroy() {
    await this.$disconnect()
  }
}

// ❌ BAD: New PrismaClient per request
// new PrismaClient() mỗi request = connection pool exhaustion
```

### Database URL với Pool Config
```bash
# .env
DATABASE_URL="postgresql://user:pass@host:5432/db?connection_limit=10&pool_timeout=10"
```

## 3. Security (CRITICAL)

### Row-Level Security (RLS) — nếu dùng Supabase
```sql
-- Chỉ cho phép user xem orders của chính họ
CREATE POLICY "users_own_orders" ON orders
  FOR ALL USING (auth.uid() = user_id);
```

### Parameterized Queries — Không Raw SQL String Interpolation
```typescript
// ❌ BAD: SQL injection risk
const result = await prisma.$queryRaw`
  SELECT * FROM orders WHERE status = '${status}'
`

// ✅ GOOD: Prisma parameterized (auto-safe)
const result = await prisma.order.findMany({
  where: { status }
})

// ✅ GOOD: Raw SQL với Prisma.sql template literal
const result = await prisma.$queryRaw(
  Prisma.sql`SELECT * FROM orders WHERE status = ${status}`
)
```

## 4. Schema Design (HIGH)

### Sử Dụng UUID thay vì Auto-Increment ID
```prisma
model Order {
  id String @id @default(uuid())  // ✅ UUID — không predict được
  // id Int @id @default(autoincrement())  // ❌ dễ enumerate
}
```

### Soft Delete Pattern
```prisma
model Product {
  id        String    @id @default(uuid())
  deletedAt DateTime?  // null = active, non-null = deleted
  @@index([deletedAt])
}
```

```typescript
// Query chỉ lấy active records
const products = await prisma.product.findMany({
  where: { deletedAt: null }
})
```

### Timestamps
```prisma
model BaseModel {
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  @@index([createdAt])  // thường cần index
}
```

## 5. Concurrency & Locking (MEDIUM-HIGH)

### Transactions cho Complex Operations
```typescript
// ✅ GOOD: Atomic transaction
await prisma.$transaction(async (tx) => {
  const order = await tx.order.create({ data: orderData })
  await tx.inventory.update({
    where: { productId: order.productId },
    data: { quantity: { decrement: order.quantity } }
  })
  await tx.payment.create({ data: { orderId: order.id, ...paymentData } })
})
// Nếu bất kỳ step nào fail → rollback toàn bộ
```

### Optimistic Concurrency với Version
```prisma
model Order {
  version Int @default(0)
}
```

```typescript
// Update với version check
await prisma.order.update({
  where: { id, version: expectedVersion },
  data: { status: 'PAID', version: { increment: 1 } }
})
```

## 6. Data Access Patterns (MEDIUM)

### Composite Indexes cho Common Queries
```prisma
model Order {
  customerId String
  status     String
  createdAt  DateTime
  
  @@index([customerId, status])        // query by customer + status
  @@index([status, createdAt])         // sort active orders by date
}
```

### Partial Indexes (Raw SQL Migration)
```sql
-- Index chỉ cho pending orders (thay vì tất cả)
CREATE INDEX idx_pending_orders ON orders(created_at)
  WHERE status = 'PENDING';
```

## 7. Monitoring & Diagnostics (LOW-MEDIUM)

### EXPLAIN ANALYZE
```sql
-- Kiểm tra query plan
EXPLAIN ANALYZE
SELECT o.*, c.name 
FROM orders o 
JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'PENDING';
```

Tìm: `Seq Scan` (có thể cần index), `Hash Join`, rows estimate accuracy.

### Prisma Query Logging
```typescript
const prisma = new PrismaClient({
  log: ['query', 'slow'], // log slow queries
})
```

## Quick Checklist

Trước khi commit database changes:

- [ ] Có indexes trên tất cả foreign keys không?
- [ ] Queries có `select` specific fields không?
- [ ] Pagination được implement (`take`/`skip` hoặc cursor)?
- [ ] Complex operations dùng `$transaction`?
- [ ] Không có raw SQL string interpolation?
- [ ] Prisma client là singleton (không new mỗi request)?

## References

- https://www.postgresql.org/docs/current/
- https://www.prisma.io/docs/orm/prisma-client/queries/query-optimization-performance
- https://supabase.com/docs/guides/database/overview
