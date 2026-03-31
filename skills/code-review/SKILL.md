---
name: code-review
description: Thực hiện code review theo Sentry engineering practices, được adapt cho NestJS + React + Prisma stack. Dùng khi review pull requests, examine code changes, hoặc cung cấp feedback về code quality. Covers security, performance, testing, và design. Kích hoạt khi được yêu cầu review code, check PR, hoặc audit changes.
metadata:
  author: getsentry (adapted)
  source: https://github.com/getsentry/skills/tree/main/plugins/sentry-skills/skills/code-review
  version: "1.0.0"
---

# Code Review

Thực hiện comprehensive code review theo engineering best practices, adapted cho NestJS + React + Prisma stack.

## Review Checklist

### 1. Identifying Problems

Tìm những issues này trong code changes:

- **Runtime errors**: Potential exceptions, null/undefined access, out-of-bounds, unhandled promises
- **Performance**: N+1 queries, O(n²) operations, missing indexes, unnecessary re-renders
- **Side effects**: Unintended behavioral changes affecting other components/modules
- **Backwards compatibility**: Breaking API changes không có migration path
- **Prisma queries**: Complex queries với unexpected performance (missing `select`, over-fetching)
- **Security vulnerabilities**: Injection, XSS, auth gaps, secrets exposure, missing validation

### 2. Design Assessment

- Component interactions có logical sense không?
- Change có align với existing project architecture không?
- Có conflicts với current requirements hay goals không?
- NestJS module boundaries có bị vi phạm không?

### 3. Test Coverage

Mỗi PR phải có appropriate test coverage:

- Unit tests cho business logic (services, utilities)
- Integration tests cho API endpoints
- E2E tests cho critical user paths (POS flow, payment flow)

Verify tests cover actual requirements và edge cases. Tránh excessive branching trong test code.

### 4. Long-Term Impact

Flag để senior review khi changes liên quan đến:

- Database schema modifications (Prisma migrations)
- API contract changes (breaking changes)
- New framework/library adoption
- Performance-critical code paths
- Security-sensitive functionality (auth, payments)

## Feedback Guidelines

### Tone
- Polite và empathetic
- Provide actionable suggestions, không phải vague criticism
- Phrase như câu hỏi khi uncertain: "Anh có xem xét... không?"
- Phân biệt rõ: blocking issue vs suggestion vs nitpick

### Approval
- Approve khi chỉ còn minor issues
- Không block PRs vì stylistic preferences
- Mục tiêu: risk reduction, không phải perfect code

## Common Patterns to Flag

### TypeScript/NestJS

```typescript
// ❌ BAD: Missing error handling
async findOne(id: string) {
  return this.prisma.order.findUnique({ where: { id } })
  // Returns null silently — caller gets null, không có error
}

// ✅ GOOD: Explicit not-found handling
async findOne(id: string) {
  const order = await this.prisma.order.findUnique({ where: { id } })
  if (!order) throw new NotFoundException(`Order ${id} not found`)
  return order
}
```

```typescript
// ❌ BAD: Prisma N+1 query
for (const order of orders) {
  const customer = await this.prisma.customer.findUnique({
    where: { id: order.customerId }
  })
}

// ✅ GOOD: Include relation
const orders = await this.prisma.order.findMany({
  include: { customer: true }
})
```

```typescript
// ❌ BAD: Over-fetching với Prisma
const users = await this.prisma.user.findMany()
// Returns ALL fields including passwords, tokens

// ✅ GOOD: Select specific fields
const users = await this.prisma.user.findMany({
  select: { id: true, name: true, email: true }
})
```

### TypeScript/React

```typescript
// ❌ BAD: Missing dependency trong useEffect
useEffect(() => {
  fetchData(orderId)
}, []) // orderId không có trong deps

// ✅ GOOD
useEffect(() => {
  fetchData(orderId)
}, [orderId])
```

```typescript
// ❌ BAD: Unhandled promise rejection
function handleSubmit() {
  submitOrder(data) // không await, không catch
}

// ✅ GOOD
async function handleSubmit() {
  try {
    await submitOrder(data)
  } catch (err) {
    toast.error('Lỗi gửi đơn hàng')
  }
}
```

### Security

```typescript
// ❌ BAD: Missing authorization
@Get(':id')
async getOrder(@Param('id') id: string) {
  return this.ordersService.findOne(id)
  // Bất kỳ ai có token đều lấy được mọi order
}

// ✅ GOOD: Check ownership
@Get(':id')
async getOrder(@Param('id') id: string, @CurrentUser() user: User) {
  return this.ordersService.findOneForUser(id, user.id)
}
```

```typescript
// ❌ BAD: Raw SQL interpolation
const result = await prisma.$queryRaw`
  SELECT * FROM orders WHERE status = ${status}
`
// Nếu status từ user input → SQL injection

// ✅ GOOD: Prisma parameterized
const result = await prisma.order.findMany({
  where: { status }
})
```

## NestJS-Specific Flags

- **Guards**: Có `@UseGuards(JwtAuthGuard)` trên endpoints cần auth không?
- **DTOs**: Có `@IsString()`, `@IsUUID()` validation decorators không?
- **Interceptors**: Có transform response để không leak sensitive fields không?
- **Exception filters**: HTTP exceptions có proper status codes không?
- **Module imports**: Service có được import vào đúng module không?

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| 🔴 Critical | Security vuln, data loss risk, production blocker | Must fix before merge |
| 🟠 High | Important bug, significant performance issue | Should fix |
| 🟡 Medium | Code quality, minor performance | Discuss |
| 🟢 Low | Nitpick, style | Optional |
