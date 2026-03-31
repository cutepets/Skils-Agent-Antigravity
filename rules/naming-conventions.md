---
trigger: glob
glob: "**/*.{ts,tsx,js,prisma,env,env.example,yml,yaml}"
---

# NAMING-CONVENTIONS.MD - Chuẩn Đặt Tên Toàn Hệ Thống

> **Mục tiêu**: Nhất quán 100% từ DB → API → Frontend → Config. Đọc tên là biết mục đích.

---

## 📝 1. TYPESCRIPT / JAVASCRIPT

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| **Variable / const** | `camelCase` | `orderTotal`, `petId` |
| **Function** | `camelCase` + động từ | `getOrderById`, `createPet`, `validateToken` |
| **Class** | `PascalCase` | `OrderService`, `PetRepository` |
| **Interface / Type** | `PascalCase` + hậu tố rõ | `OrderDto`, `CreatePetInput`, `ApiResponse<T>` |
| **Enum** | `PascalCase` + giá trị `UPPER_SNAKE` | `OrderStatus.PENDING`, `PaymentMethod.CASH` |
| **Constant (global)** | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `TOKEN_EXPIRY_SECONDS` |
| **React Component** | `PascalCase` | `OrderDetailPage`, `PetFormModal` |
| **React Hook** | `use` + `PascalCase` | `useOrderDetail`, `usePetSearch` |
| **Boolean variable** | `is/has/can/should` prefix | `isLoading`, `hasError`, `canEdit` |

```
✅ const petOwnerName = 'Nguyen Van A'
✅ function calculateServiceTotal(items: ServiceItem[]): number
✅ interface CreateOrderInput { petId: string; services: string[] }

❌ const pet_owner_name = ...       // snake_case không dùng trong TS
❌ function calc(x)                  // tên quá ngắn, không rõ mục đích
❌ const data = await fetchSomething // 'data' quá generic
```

---

## 🗄️ 2. DATABASE (Prisma / SQL)

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| **Tên bảng** | `snake_case`, số nhiều | `orders`, `pet_services`, `hotel_stays` |
| **Tên cột** | `snake_case` | `pet_id`, `created_at`, `total_amount` |
| **Khóa chính** | `id` (UUID v7) | `id` |
| **Khóa ngoại** | `{table_singular}_id` | `pet_id`, `branch_id`, `order_id` |
| **Timestamp** | `created_at`, `updated_at`, `deleted_at` | — |
| **Boolean cột** | `is_` prefix | `is_active`, `is_paid` |
| **Enum DB** | `UPPER_SNAKE_CASE` | `PENDING`, `COMPLETED`, `CANCELLED` |

```prisma
// ✅ Đúng
model PetService {
  id         String   @id @default(uuid())
  pet_id     String
  branch_id  String
  is_active  Boolean  @default(true)
  created_at DateTime @default(now())
  updated_at DateTime @updatedAt
}

// ❌ Sai
model petservice {
  petId   String  // camelCase trong DB
  active  Boolean // thiếu is_ prefix
}
```

---

## ⚡ 3. CACHE KEYS (Redis)

**Format chuẩn:** `{service}:{entity}:{id}:{variant?}`

```
✅ petshop:order:ord_123
✅ petshop:pet:pet_456:detail
✅ petshop:user:usr_789:permissions
✅ petshop:branch:brn_001:services:list

❌ order_123              // thiếu namespace
❌ petshopOrderDetail123  // camelCase, không có dấu phân cách
❌ cache:data             // quá generic
```

**TTL naming:** Dùng constant, không hardcode số:
```typescript
const CACHE_TTL = {
  ORDER_DETAIL:  5 * 60,   // 5 phút
  PET_LIST:      15 * 60,  // 15 phút
  USER_SESSION:  60 * 60,  // 1 giờ
} as const;
```

---

## 📬 4. QUEUE NAMES (BullMQ)

**Format chuẩn:** `{service}-{action}` (kebab-case)

```
✅ order-processing
✅ email-notification
✅ report-generation
✅ hotel-checkout-reminder

❌ orderQueue        // camelCase
❌ PROCESS_ORDER     // UPPER_SNAKE
❌ queue1            // vô nghĩa
```

**Job names trong queue:** `{entity}:{action}`
```typescript
queue.add('order:confirm', { orderId })
queue.add('email:send-receipt', { orderId, email })
queue.add('report:daily-revenue', { date })
```

---

## 🌍 5. ENVIRONMENT VARIABLES

**Format chuẩn:** `UPPER_SNAKE_CASE`, nhóm theo prefix

```bash
# ✅ Đúng — Nhóm rõ ràng
DATABASE_URL=postgresql://...
DATABASE_POOL_SIZE=10

REDIS_URL=redis://localhost:6379
REDIS_TTL_DEFAULT=300

JWT_SECRET=...
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

MINIMAX_API_KEY=...
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587

# App
NODE_ENV=development
APP_PORT=3000
APP_URL=http://localhost:3000

# ❌ Sai
dbUrl=...            // camelCase
db_url=...           // lowercase
SECRET=...           // quá generic, thiếu context
```

---

## 📁 6. FILE & FOLDER NAMING

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| **React Component** | `PascalCase.tsx` | `OrderDetailPage.tsx`, `PetFormModal.tsx` |
| **Hook** | `use-kebab.ts` | `use-order-detail.ts` |
| **Service/Repository** | `kebab-case.service.ts` | `order.service.ts`, `pet.repository.ts` |
| **Type file** | `kebab-case.types.ts` | `pos.types.ts`, `order.types.ts` |
| **Utility** | `kebab-case.utils.ts` | `date.utils.ts`, `currency.utils.ts` |
| **Middleware** | `kebab-case.middleware.ts` | `auth.middleware.ts` |
| **Test file** | `{name}.test.ts` hoặc `{name}.spec.ts` | `order.service.test.ts` |
| **Folder** | `kebab-case` | `pet-services/`, `hotel-stays/` |

---

> **Quy tắc vàng:** Đọc tên → hiểu ngay mục đích. Không cần mở file mới biết nó làm gì.
