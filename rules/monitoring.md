---
trigger: glob
glob: "**/*.{service,controller,middleware,repository}.ts"
---

# MONITORING.MD - Logging & Observability Standards

> **Mục tiêu**: Mọi sự cố production đều có thể trace được trong vòng 5 phút. Không có "black box".

---

## 📋 1. STRUCTURED LOGGING (Bắt buộc)

**Rule #1: KHÔNG BAO GIỜ dùng `console.log` trong production code.**

```typescript
// ❌ Unstructured — vô dụng ở scale
console.log(`Order created for user ${userId} with total ${total}`)

// ✅ Structured JSON — parseable, filterable, alertable
logger.info('Order created', {
  event: 'order.created',
  orderId: order.id,
  userId: user.id,
  total: order.total,
  itemCount: order.items.length,
  branchId: order.branchId,
  durationMs: Date.now() - startTime,
  requestId: req.id,
})
```

**Logger setup (Winston/Pino):**
```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  base: {
    service: 'petshop-backend',
    env: process.env.NODE_ENV,
  },
});
```

---

## 🎯 2. LOG LEVELS — Khi nào dùng gì

| Level | Khi nào | Production? | Ví dụ |
|-------|---------|-------------|-------|
| `error` | Lỗi cần xử lý ngay, ảnh hưởng user | ✅ Always | DB query fail, payment error |
| `warn` | Bất thường nhưng hệ thống vẫn chạy | ✅ Always | Retry attempt, deprecated API used |
| `info` | Sự kiện nghiệp vụ bình thường | ✅ Always | Order created, user login |
| `debug` | Chi tiết debug | ❌ Dev only | SQL query, cache hit/miss |
| `trace` | Rất chi tiết | ❌ Dev only | Function entry/exit |

```typescript
// ✅ Ví dụ thực tế Petshop
logger.error('Payment failed', {
  event: 'payment.failed',
  orderId, userId, amount,
  error: err.message,
  requestId: req.id,
});

logger.warn('Retry attempt', {
  event: 'queue.retry',
  jobId, attempt: job.attemptsMade,
  maxAttempts: 3,
});

logger.info('Service completed', {
  event: 'grooming.completed',
  orderId, petId, serviceId, staffId,
  durationMs,
});
```

---

## 🆔 3. REQUEST ID — Trace Request Xuyên Suốt

**Mỗi request phải có `requestId` duy nhất, propagated vào mọi log:**

```typescript
// middleware/request-id.middleware.ts
import { v4 as uuid } from 'uuid';

export function requestIdMiddleware(req, res, next) {
  req.id = req.headers['x-request-id'] ?? `req_${uuid()}`;
  res.setHeader('X-Request-Id', req.id);
  next();
}

// Trong service — propagate requestId
logger.info('Order processing started', {
  requestId: context.requestId, // luôn truyền từ controller xuống
  orderId,
});
```

---

## ❌ 4. KHÔNG LOG NHỮNG GÌ

```
❌ Passwords, API keys, secrets, tokens
❌ PII (Personal Identifiable Information): CMND, số thẻ, địa chỉ đầy đủ
❌ Credit card numbers
❌ JWT payload (chỉ log userId từ token, không log cả token)
```

```typescript
// ❌ KHÔNG làm thế này
logger.info('Login success', { user: req.body }) // includes password!

// ✅ Làm thế này
logger.info('Login success', {
  event: 'auth.login',
  userId: user.id,
  email: maskEmail(user.email), // mask: n***@gmail.com
  ip: req.ip,
  requestId: req.id,
})
```

---

## 🏥 5. HEALTH CHECK ENDPOINTS (Bắt buộc)

**Mọi service PHẢI có 2 endpoints này:**

```typescript
// ✅ Liveness — "Service còn sống không?"
GET /health
→ 200 { status: 'ok', uptime: 12345, timestamp: '...' }
// Chỉ trả 200 nếu process đang chạy. KHÔNG check DB ở đây.

// ✅ Readiness — "Service sẵn sàng nhận request chưa?"
GET /ready
→ 200 { status: 'ready', db: 'ok', redis: 'ok', queue: 'ok' }
→ 503 { status: 'not_ready', db: 'error', redis: 'ok' }
// Check tất cả dependencies. Trả 503 nếu bất kỳ dependency nào fail.
```

```typescript
// routes/health.route.ts
router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION ?? 'unknown',
  });
});

router.get('/ready', async (req, res) => {
  const checks = {
    db: await checkDatabase(),
    redis: await checkRedis(),
    queue: await checkQueue(),
  };
  const isReady = Object.values(checks).every(s => s === 'ok');
  res.status(isReady ? 200 : 503).json({ status: isReady ? 'ready' : 'not_ready', ...checks });
});
```

---

## ⏱️ 6. PERFORMANCE LOGGING

**Log duration cho mọi operation quan trọng:**

```typescript
// Decorator pattern hoặc manual
const startTime = Date.now();

try {
  const result = await orderService.create(data);
  
  logger.info('Order created successfully', {
    event: 'order.created',
    orderId: result.id,
    durationMs: Date.now() - startTime, // ← luôn log duration
    requestId: req.id,
  });
} catch (error) {
  logger.error('Order creation failed', {
    event: 'order.create.failed',
    durationMs: Date.now() - startTime,
    error: error.message,
    requestId: req.id,
  });
}
```

**Ngưỡng alert:**
```
> 200ms  → warn log "slow query detected"
> 1000ms → error log "critical slow operation"
> 5000ms → alert "timeout threshold exceeded"
```

---

## 📊 7. BUSINESS EVENTS (Petshop-Specific)

**Các event nghiệp vụ quan trọng PHẢI log:**

```typescript
const BUSINESS_EVENTS = [
  'order.created',       // Đơn hàng mới
  'order.confirmed',     // Xác nhận đơn
  'order.completed',     // Hoàn thành
  'order.cancelled',     // Huỷ đơn
  'payment.success',     // Thanh toán thành công
  'payment.failed',      // Thanh toán lỗi
  'hotel.checkin',       // Pet check-in khách sạn
  'hotel.checkout',      // Pet check-out
  'grooming.started',    // Bắt đầu grooming
  'grooming.completed',  // Hoàn thành grooming
  'inventory.low',       // Tồn kho thấp
  'auth.login',          // Đăng nhập
  'auth.logout',         // Đăng xuất
  'auth.login.failed',   // Đăng nhập thất bại
] as const;
```

---

> **Nhớ:** Log là radar của bạn. Không có log tốt = bay trong bóng tối. Khi production có vấn đề, đây là thứ cứu bạn.
