---
name: security-review
description: >
  Review APPLICATION CODE (NestJS backend + React frontend) tìm security vulnerabilities,
  suggest fixes, và viết code secure-by-default. Kích hoạt khi user yêu cầu security
  review/report trên source code, hoặc khi phát hiện critical vulnerability trong app code.
  ⚠️ ROUTING: Skill này CHỈ cho app code. Để scan AI agent config (.agent/ directory),
  dùng security-scan skill thay thế. Output: app_security_report.md
metadata:
  author: openai (adapted)
  source: https://github.com/openai/skills/tree/main/skills/.curated/security-best-practices
  version: "1.1.0"
---

> **🔀 ROUTING NOTE:**
> - **Skill này** = Review *application source code* (NestJS, React, Prisma)
> - **`security-scan` skill** = Audit *AI agent configuration* (.agent/, hooks.json, rules/)

# Security Review

Skill này identify language và frameworks trong project, sau đó áp dụng security best practices phù hợp. Có thể hoạt động theo 3 modes:

1. **Passive mode**: Write secure-by-default code
2. **Detection mode**: Flag critical issues khi working in project
3. **Report mode**: Full security report khi được yêu cầu

## Workflow

### Step 1: Identify Stack
```
Backend: NestJS + Prisma + PostgreSQL
Frontend: Vite + React + TanStack Query
Auth: JWT (Bearer tokens)
```

### Step 2: Apply Relevant Guidelines

---

## NestJS Backend Security

### Authentication & Authorization

```typescript
// ❌ CRITICAL: Endpoint không có auth guard
@Controller('orders')
export class OrdersController {
  @Get()
  findAll() { ... }  // Ai cũng access được!

// ✅ GOOD: Protected endpoint
@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  @Get()
  findAll(@CurrentUser() user: User) { ... }
}
```

```typescript
// ❌ CRITICAL: IDOR - không check ownership
@Get(':id')
async getOrder(@Param('id') id: string) {
  return this.ordersService.findOne(id)  // Bất kỳ user nào lấy được!
}

// ✅ GOOD: Check ownership
@Get(':id')
async getOrder(@Param('id') id: string, @CurrentUser() user: User) {
  return this.ordersService.findOneForUser(id, user.id)
}
```

### Input Validation

```typescript
// ❌ BAD: Không validate input
@Post()
createOrder(@Body() body: any) { ... }

// ✅ GOOD: Validate với DTOs + class-validator
export class CreateOrderDto {
  @IsUUID()
  customerId: string

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items: OrderItemDto[]

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod
}

// Enable global validation pipe
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,     // Strip extra properties
  forbidNonWhitelisted: true,  // Throw if extra properties
  transform: true,     // Auto-transform types
}))
```

### Secrets & Configuration

```typescript
// ❌ CRITICAL: Hardcoded secrets
const JWT_SECRET = 'my-super-secret'

// ✅ GOOD: Environment variables
@Injectable()
export class ConfigService {
  get jwtSecret(): string {
    const secret = process.env.JWT_SECRET
    if (!secret) throw new Error('JWT_SECRET not configured')
    return secret
  }
}
```

### Rate Limiting

```typescript
// ✅ Thêm rate limiting cho auth endpoints
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler'

ThrottlerModule.forRoot([{
  ttl: 60000,
  limit: 10,  // Max 10 requests/minute
}])

@UseGuards(ThrottlerGuard)
@Post('login')
login(@Body() dto: LoginDto) { ... }
```

### Error Handling — Không Leak Internal Details

```typescript
// ❌ BAD: Leak stack traces
throw new Error(error.message)  // "Prisma error: relation not found in..."

// ✅ GOOD: Generic error cho client
throw new InternalServerErrorException('Lỗi server, vui lòng thử lại')
// Log full error chi tiết vào server-side logger

// ✅ GOOD: Custom exception filter
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    // Log full error
    this.logger.error(exception)
    // Return generic response
    res.status(500).json({ message: 'Internal server error' })
  }
}
```

### SQL Injection Prevention

```typescript
// ✅ GOOD: Prisma ORM (auto-parameterized)
const orders = await prisma.order.findMany({
  where: { status, customerId }
})

// ✅ GOOD: Raw SQL với template literal (parameterized)
const result = await prisma.$queryRaw(
  Prisma.sql`SELECT * FROM orders WHERE id = ${orderId}`
)

// ❌ CRITICAL: String concatenation
const result = await prisma.$queryRawUnsafe(
  `SELECT * FROM orders WHERE id = '${orderId}'`  // SQL injection!
)
```

---

## React Frontend Security

### XSS Prevention

```tsx
// ❌ CRITICAL: dangerouslySetInnerHTML với user input
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ GOOD: Never inject HTML from user input
// Nếu cần rich text, dùng DOMPurify
import DOMPurify from 'dompurify'
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(richText) }} />
```

### No Secrets in Client Code

```typescript
// ❌ CRITICAL: API key trong frontend
const API_KEY = 'sk-1234...'

// ✅ GOOD: Call through backend proxy
const response = await fetch('/api/external-service', {
  method: 'POST',
  body: JSON.stringify(data)
})
// Backend giữ API key, frontend không cần biết
```

### JWT Storage

```typescript
// ❌ BAD: localStorage — vulnerable to XSS
localStorage.setItem('token', jwtToken)

// ✅ BETTER: HttpOnly cookies — XSS không thể access
// Cookies được set bởi backend với httpOnly: true, secure: true, sameSite: 'strict'

// ✅ ACCEPTABLE: Memory-only storage (cleared on refresh)
// Dùng React context/state, kết hợp với refresh token mechanism
```

### CSRF Protection

```typescript
// ✅ NestJS CSRF với cookie-based auth
import * as csurf from 'csurf'
app.use(csurf({ cookie: true }))
```

---

## General Security Principles

### Avoid Auto-Increment IDs for Public Resources
```typescript
// ❌ BAD: Predictable IDs (1, 2, 3...) → enumeration attack
id: Int @id @default(autoincrement())

// ✅ GOOD: UUID
id: String @id @default(uuid())
```

### Principle of Least Privilege
- Database user chỉ có quyền cần thiết (không dùng postgres superuser)
- NestJS modules chỉ export những gì cần thiết
- API endpoints chỉ trả về fields cần thiết

### Security Headers
```typescript
// ✅ Thêm Helmet middleware
import helmet from 'helmet'
app.use(helmet())
// Tự động set: X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security, etc.
```

---

## Report Format

Khi tạo security report, lưu vào `app_security_report.md`:

```markdown
# Security Audit Report — [Project Name]
Date: [Date]
Stack: NestJS + React + PostgreSQL

## Executive Summary
[1-2 câu tóm tắt overall security posture]

## Critical Findings (phải fix ngay)
### [ID] [Title]
- **Impact**: [1 sentence]
- **Location**: `file.ts:line`
- **Issue**: [mô tả]
- **Fix**: [code example]

## High Findings
...

## Medium Findings
...
```

---

## Override Policy

Nếu project có lý do cụ thể để bypass một best practice, document nó:
```typescript
// SECURITY-NOTE: Using localStorage for token because app runs in Electron
// desktop context where HttpOnly cookies are not practical.
// Risk accepted and documented in security/DECISIONS.md
```

> ⚠️ **TLS Note**: Không report thiếu TLS như security issue trong dev environment.
> Production deployment có TLS ở infrastructure level (nginx, load balancer).
