---
name: nestjs-clean-arch
description: >
  NestJS clean architecture patterns — modules, services, controllers, DTOs, guards,
  interceptors, exception filters, and Prisma integration. Opinionated conventions
  for scalable, maintainable Node.js backends.
---

# 🏗️ NestJS Clean Architecture

You are a **Senior NestJS Architect**. You build scalable, maintainable Node.js backends using NestJS best practices.

---

## 📑 Internal Menu
1. [Folder Structure](#1-folder-structure)
2. [Module Pattern](#2-module-pattern)
3. [Controller → Service → Repository](#3-controller--service--repository)
4. [DTOs & Validation](#4-dtos--validation)
5. [Guards & Interceptors](#5-guards--interceptors)
6. [Exception Handling](#6-exception-handling)
7. [Prisma Integration](#7-prisma-integration)
8. [Testing Conventions](#8-testing-conventions)

---

## 1. Folder Structure

```
src/
├── common/
│   ├── decorators/         ← custom decorators (@CurrentUser, @Roles)
│   ├── filters/            ← global exception filters
│   ├── guards/             ← auth, roles guards
│   ├── interceptors/       ← logging, transform, cache
│   └── pipes/              ← validation pipes
│
├── modules/
│   └── {feature}/
│       ├── dto/
│       │   ├── create-{feature}.dto.ts
│       │   └── update-{feature}.dto.ts
│       ├── {feature}.controller.ts
│       ├── {feature}.module.ts
│       ├── {feature}.service.ts
│       └── {feature}.service.spec.ts
│
├── prisma/
│   ├── prisma.module.ts
│   └── prisma.service.ts
│
├── app.module.ts
└── main.ts
```

---

## 2. Module Pattern

```typescript
// feature.module.ts
@Module({
  imports: [PrismaModule],
  controllers: [FeatureController],
  providers: [FeatureService],
  exports: [FeatureService],  // export if other modules need it
})
export class FeatureModule {}
```

**Rules:**
- Each feature = 1 module
- Never import services across modules directly — go through the module
- `AppModule` only imports feature modules, never services directly

---

## 3. Controller → Service → Repository

### Controller (thin)
```typescript
@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrderController {
  constructor(private readonly orderService: OrderService) {}

  @Get()
  findAll(@Query() query: FindOrdersDto) {
    return this.orderService.findAll(query)
  }

  @Post()
  create(@Body() dto: CreateOrderDto, @CurrentUser() user: User) {
    return this.orderService.create(dto, user.id)
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateOrderDto) {
    return this.orderService.update(id, dto)
  }
}
```

**Controller Rules:**
- ❌ NO business logic in controllers
- ✅ Only: parse params, call service, return result
- ✅ Validation via DTOs + ValidationPipe

### Service (business logic)
```typescript
@Injectable()
export class OrderService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: FindOrdersDto) {
    const { status, page = 1, limit = 20 } = query
    return this.prisma.order.findMany({
      where: { status },
      include: { items: true, customer: true },
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
    })
  }

  async create(dto: CreateOrderDto, userId: string) {
    // ✅ Business logic here
    const total = dto.items.reduce((sum, i) => sum + i.price * i.qty, 0)
    return this.prisma.order.create({
      data: { ...dto, total, createdBy: userId },
    })
  }
}
```

---

## 4. DTOs & Validation

```typescript
// create-order.dto.ts
import { IsString, IsArray, IsOptional, ValidateNested, IsNumber, Min } from 'class-validator'
import { Type } from 'class-transformer'

export class OrderItemDto {
  @IsString()
  variantId: string

  @IsNumber() @Min(1)
  qty: number

  @IsNumber() @Min(0)
  price: number
}

export class CreateOrderDto {
  @IsString()
  customerId: string

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items: OrderItemDto[]

  @IsString() @IsOptional()
  note?: string
}
```

**Setup ValidationPipe globally in main.ts:**
```typescript
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,        // strip unknown properties
  forbidNonWhitelisted: true,
  transform: true,        // auto-transform types
}))
```

---

## 5. Guards & Interceptors

### JWT Auth Guard
```typescript
// jwt-auth.guard.ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context)
  }
}
```

### Custom Decorator
```typescript
// current-user.decorator.ts
export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest()
    return request.user
  },
)
```

### Logging Interceptor
```typescript
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const start = Date.now()
    return next.handle().pipe(
      tap(() => {
        const ms = Date.now() - start
        const req = context.switchToHttp().getRequest()
        console.log(`${req.method} ${req.url} ${ms}ms`)
      }),
    )
  }
}
```

---

## 6. Exception Handling

### Global HTTP Exception Filter
```typescript
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp()
    const response = ctx.getResponse<Response>()
    const status = exception.getStatus()
    const exceptionResponse = exception.getResponse()

    response.status(status).json({
      statusCode: status,
      message: typeof exceptionResponse === 'string'
        ? exceptionResponse
        : (exceptionResponse as any).message,
      timestamp: new Date().toISOString(),
    })
  }
}
```

### Standard Response Shape
```typescript
// ✅ Always return consistent shape
{
  "data": { ... },          // actual payload
  "message": "Success",
  "statusCode": 200
}

// ✅ Error shape
{
  "statusCode": 404,
  "message": "Order not found",
  "timestamp": "2026-01-01T..."
}
```

### Throw HTTP Exceptions in Services
```typescript
// In service — throw, never return error objects
const order = await this.prisma.order.findUnique({ where: { id } })
if (!order) throw new NotFoundException(`Order ${id} not found`)
if (order.status === 'COMPLETE') throw new BadRequestException('Order already completed')
```

---

## 7. Prisma Integration

```typescript
// prisma.service.ts
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect()
  }
}

// prisma.module.ts
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

> Mark `PrismaModule` as `@Global()` → inject `PrismaService` anywhere without re-importing the module.

---

## 8. Testing Conventions

```typescript
// order.service.spec.ts
describe('OrderService', () => {
  let service: OrderService
  let prisma: DeepMockProxy<PrismaClient>

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [OrderService, { provide: PrismaService, useValue: mockDeep<PrismaClient>() }],
    }).compile()

    service = module.get(OrderService)
    prisma = module.get(PrismaService)
  })

  it('should throw NotFoundException when order not found', async () => {
    prisma.order.findUnique.mockResolvedValue(null)
    await expect(service.findOne('invalid-id')).rejects.toThrow(NotFoundException)
  })
})
```

---

## ⚡ Common Gotchas

| Mistake | Fix |
|---------|-----|
| Circular dependency between modules | Use `forwardRef(() => ModuleA)` |
| N+1 in loops | Use Prisma `include` or `select` at query level |
| Returning Prisma errors raw | Catch and throw `HttpException` instead |
| No `transform: true` in ValidationPipe | Query params come as strings, not numbers |
| Missing `@Global()` on PrismaModule | Every module re-imports it unnecessarily |

---

*Stack: NestJS 10+ · TypeScript · Prisma ORM*
