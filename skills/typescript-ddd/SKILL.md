---
name: typescript-ddd
description: >
  TypeScript DDD (Domain-Driven Design) patterns: Hexagonal Architecture,
  CQRS, Event-Driven Architecture. Tổng hợp từ CodelyTV/typescript-ddd-example
  và Sairyss/domain-driven-hexagon — production-grade, battle-tested.
  Kích hoạt khi thiết kế domain model, viết aggregate, value object,
  domain event, command/query handler, Result pattern, hoặc cần áp dụng
  Hexagonal Architecture trong NestJS/Express/Fastify.
  ⚠️ LARGE SKILL (54KB) — chỉ load khi explicitly cần DDD patterns.
  Không auto-trigger cho tasks đơn giản như CRUD, fix bug, hay UI work.
trigger:
  - khi nhắc đến DDD, domain model, aggregate root
  - khi thiết kế bounded context
  - khi nhắc đến CQRS, command bus, query bus
  - khi cần event-driven architecture
  - khi tái cấu trúc business logic lớn
  - khi xử lý domain errors, Result type, Either monad
  - khi thiết kế persistence model, mapper, repository
  - khi nhắc đến integration events, outbox pattern
---

# TypeScript DDD — Hexagonal Architecture, CQRS & EDA

> **Sources**:
> - [Sairyss/domain-driven-hexagon](https://github.com/Sairyss/domain-driven-hexagon) — 14.5k ★ (PRIMARY — infrastructure & error patterns)
> - [ddd-by-examples/library](https://github.com/ddd-by-examples/library) — Java/Spring, **best for**: Policy pattern, State Types, Functional domain, BDD DSL
> - [CodelyTV/typescript-ddd-example](https://github.com/CodelyTV/typescript-ddd-example) — CQRS/EDA reference
> - [natserract/nodejs-ddd](https://github.com/natserract/nodejs-ddd) — KoaJS + Sequelize + TSyringe, **best for**: types-ddd lib, CQRS Repo split, Nested Transactions
> - [node-ts/ddd](https://github.com/node-ts/ddd) — 614 ★, **best for**: `when()` auto-dispatch convention, atomic WriteRepository<T,TWriteModel>, Event versioning
> **Stack**: TypeScript + NestJS/KoaJS + PostgreSQL (Slonik/Prisma/Sequelize)

---

## 🗂️ Folder Structure — Vertical Slice (Sairyss style)

```
src/
├── modules/                    ← Mỗi module = 1 Bounded Context
│   └── user/
│       ├── commands/
│       │   └── create-user/    ← Vertical Slice: tất cả code cho 1 use case
│       │       ├── create-user.command.ts
│       │       ├── create-user.service.ts      ← Command Handler
│       │       ├── create-user.http.controller.ts
│       │       ├── create-user.cli.controller.ts    ← 1 controller/trigger
│       │       ├── create-user.message.controller.ts
│       │       └── create-user.request.dto.ts
│       ├── queries/
│       │   └── find-users/
│       │       ├── find-users.query-handler.ts  ← DB trực tiếp, no repo
│       │       └── find-users.query.ts
│       ├── domain/
│       │   ├── user.entity.ts
│       │   ├── user.errors.ts
│       │   └── value-objects/
│       │       └── address.value-object.ts
│       ├── database/
│       │   ├── user.repository.ts          ← Prisma/SQL implementation
│       │   └── user.repository.port.ts     ← Interface (port)
│       ├── dtos/
│       │   └── user.response.dto.ts
│       └── user.mapper.ts                  ← Domain ↔ Persistence mapping
└── libs/
    ├── ddd/
    │   ├── aggregate-root.base.ts
    │   ├── entity.base.ts
    │   └── repository.port.ts              ← Generic repository interface
    ├── db/
    │   └── sql-repository.base.ts          ← Base CRUD repository
    └── ports/
        └── logger.port.ts
```

### 🔑 Key Rules
1. **Domain layer** không có dependency ra ngoài — pure TypeScript, no frameworks.
2. **Application layer** dùng ports (interfaces), không concrete infrastructure.
3. **Infrastructure** implement ports. Core không biết DB là gì.
4. **Modules giao tiếp qua Events** hoặc CommandBus — không import trực tiếp.
5. **Query handlers** có thể bypass domain+repo, query DB trực tiếp (CQRS read side).
6. **1 controller per trigger type**: HTTP, CLI, Message — tách biệt hoàn toàn.

---

## 🧱 Shared Domain Primitives

### ValueObject Base

```typescript
// src/Contexts/Shared/domain/value-object/ValueObject.ts
export type Primitives = String | string | number | Boolean | boolean | Date;

export abstract class ValueObject<T extends Primitives> {
  readonly value: T;

  constructor(value: T) {
    this.value = value;
    this.ensureValueIsDefined(value);  // guard: không cho null/undefined
  }

  private ensureValueIsDefined(value: T): void {
    if (value === null || value === undefined) {
      throw new InvalidArgumentError('Value must be defined');
    }
  }

  // Structural equality (by type + value)
  equals(other: ValueObject<T>): boolean {
    return other.constructor.name === this.constructor.name
        && other.value === this.value;
  }

  toString(): string {
    return this.value.toString();
  }
}
```

**Variants:**
- `StringValueObject` — extends `ValueObject<string>`
- `IntValueObject` — extends `ValueObject<number>`
- `Uuid` — extends `StringValueObject`, tự validate UUID format & generate
- `EnumValueObject<T>` — validate giá trị nằm trong enum list

### AggregateRoot

```typescript
// src/Contexts/Shared/domain/AggregateRoot.ts
export abstract class AggregateRoot {
  private domainEvents: Array<DomainEvent> = [];

  // Pull-then-clear pattern: lấy events sau khi save
  pullDomainEvents(): Array<DomainEvent> {
    const domainEvents = this.domainEvents.slice();
    this.domainEvents = [];
    return domainEvents;
  }

  // Gọi trong factory method khi có state change
  record(event: DomainEvent): void {
    this.domainEvents.push(event);
  }

  // Mỗi aggregate PHẢI implement — dùng để serialize/deserialize
  abstract toPrimitives(): any;
}
```

### DomainEvent Base

```typescript
// src/Contexts/Shared/domain/DomainEvent.ts
export abstract class DomainEvent {
  static EVENT_NAME: string;
  static fromPrimitives: (...) => DomainEvent; // for deserialization

  readonly aggregateId: string;
  readonly eventId: string;   // auto-generated UUID if not provided
  readonly occurredOn: Date;  // auto-set to now if not provided
  readonly eventName: string;

  constructor(params: {
    eventName: string;
    aggregateId: string;
    eventId?: string;
    occurredOn?: Date;
  }) { ... }

  abstract toPrimitives(): DomainEventAttributes; // for serialization
}
```

---

## 🗿 Aggregate Pattern (Course Example)

### 1. Value Objects (domain layer)

```typescript
// CourseName.ts — validation logic TRONG value object
export class CourseName extends StringValueObject {
  constructor(value: string) {
    super(value);
    this.ensureLengthIsLessThan30Characters(value);
  }

  private ensureLengthIsLessThan30Characters(value: string): void {
    if (value.length > 30) {
      throw new CourseNameLengthExceeded(
        `The Course Name <${value}> has more than 30 characters`
      );
    }
  }
}

// CourseDuration.ts — simple wrap
export class CourseDuration extends StringValueObject {}
```

### 2. Aggregate Root

```typescript
// Course.ts
export class Course extends AggregateRoot {
  readonly id: CourseId;
  readonly name: CourseName;
  readonly duration: CourseDuration;

  constructor(id: CourseId, name: CourseName, duration: CourseDuration) {
    super();
    this.id = id;
    this.name = name;
    this.duration = duration;
  }

  // Factory method — ghi lại domain event
  static create(id: CourseId, name: CourseName, duration: CourseDuration): Course {
    const course = new Course(id, name, duration);
    course.record(
      new CourseCreatedDomainEvent({
        aggregateId: course.id.value,
        duration: course.duration.value,
        name: course.name.value,
      })
    );
    return course;
  }

  // Reconstruction từ DB (không ghi event)
  static fromPrimitives(plainData: { id: string; name: string; duration: string }): Course {
    return new Course(
      new CourseId(plainData.id),
      new CourseName(plainData.name),
      new CourseDuration(plainData.duration)
    );
  }

  // Serialization
  toPrimitives(): any {
    return {
      id: this.id.value,
      name: this.name.value,
      duration: this.duration.value,
    };
  }
}
```

#### 2b. `when()` Auto-dispatch Convention (node-ts/ddd)

Thay vì dispatch domain event thủ công, dùng convention-based `when()` để **tự động gọi handler** theo tên event.

```typescript
// aggregate-root.base.ts — mở rộng AggregateRoot hiện tại
abstract class AggregateRoot<T> {
  private _domainEvents: DomainEvent[] = [];

  /**
   * when() làm 3 việc:
   * 1. Thêm event vào queue
   * 2. Tăng version
   * 3. Dispatch tới handler `when<EventName>()` nếu tồn tại
   */
  protected when<TEvent extends DomainEvent>(event: TEvent): void {
    this._domainEvents.push(event);
    this._version++;

    // Convention: dispatch tới method `when<ClassName>`
    const handlerName = `when${event.constructor.name}`; // e.g. "whenUserRegistered"
    const handler = (this as any)[handlerName];
    if (typeof handler === 'function') {
      handler.call(this, event);
    }
  }

  get domainEvents(): DomainEvent[] { return this._domainEvents; }
  clearEvents(): void { this._domainEvents = []; }
}

// User.ts — sử dụng when() convention
export class User extends AggregateRoot<UserProps> {
  // Static factory — aggregate không bao giờ "new" trực tiếp từ consumer
  static register(id: UserId, email: Email): User {
    const user = new User(id);
    user.when(new UserRegistered(id.value, email.value, true)); // ← gọi when()
    return user;
  }

  disable(): void {
    user.when(new UserDisabled(this.id.value, false));          // ← gọi when()
  }

  // Handler tự động được gọi khi when(new UserRegistered()) được gọi
  protected whenUserRegistered(event: UserRegistered): void {
    this.props.email = new Email(event.email);
    this.props.isEnabled = event.isEnabled;
  }

  // Handler tự động được gọi khi when(new UserDisabled()) được gọi
  protected whenUserDisabled(event: UserDisabled): void {
    this.props.isEnabled = false;
  }
}
```

> **Khi nào dùng**: Aggregate có nhiều event types, muốn tránh switch/if-else trong apply logic.
> **Lưu ý**: Method name phải đúng convention `when<EventClassName>` để auto-dispatch hoạt động.

#### 2c. Event Versioning (node-ts/ddd)

```typescript
// Đánh version event để hỗ trợ schema evolution
export class UserRegistered {
  static readonly NAME = 'petshop/account/user-registered'; // namespace/domain/event
  readonly $name = UserRegistered.NAME;
  readonly $version = 0;  // ← tăng khi schema thay đổi breaking

  constructor(
    readonly userId: string,   // v0
    readonly email: string,    // v0
    readonly isEnabled: boolean // v0
    // v1 sẽ thêm: readonly role: UserRole
  ) {}
}

// Khi consumer nhận event cũ (v0) phải migrate:
function migrateUserRegistered(raw: any): UserRegistered {
  if (raw.$version === 0 && !raw.role) {
    return { ...raw, role: 'customer' }; // backfill default
  }
  return raw;
}
```

> **Lưu ý**: Event versioning quan trọng khi dùng Event Sourcing hoặc publish events ra message bus ngoài.

### 3. Domain Event

```typescript
// CourseCreatedDomainEvent.ts
type CreateCourseDomainEventAttributes = {
  readonly duration: string;
  readonly name: string;
};

export class CourseCreatedDomainEvent extends DomainEvent {
  static readonly EVENT_NAME = 'course.created';  // ← snake_case convention

  readonly duration: string;
  readonly name: string;

  constructor({ aggregateId, name, duration, eventId, occurredOn }: {
    aggregateId: string;
    eventId?: string;
    duration: string;
    name: string;
    occurredOn?: Date;
  }) {
    super({ eventName: CourseCreatedDomainEvent.EVENT_NAME, aggregateId, eventId, occurredOn });
    this.duration = duration;
    this.name = name;
  }

  toPrimitives(): CreateCourseDomainEventAttributes {
    return { name: this.name, duration: this.duration };
  }

  // Dùng để deserialize từ message queue
  static fromPrimitives(params: {
    aggregateId: string;
    attributes: CreateCourseDomainEventAttributes;
    eventId: string;
    occurredOn: Date;
  }): DomainEvent {
    return new CourseCreatedDomainEvent({
      aggregateId: params.aggregateId,
      duration: params.attributes.duration,
      name: params.attributes.name,
      eventId: params.eventId,
      occurredOn: params.occurredOn,
    });
  }
}
```

### 4. Repository Interface (domain layer — port)

```typescript
// CourseRepository.ts — chỉ là interface, không biết DB
export interface CourseRepository {
  save(course: Course): Promise<void>;
  searchAll(): Promise<Array<Course>>;
  search(id: CourseId): Promise<Nullable<Course>>;
}
```

---

## ⚙️ CQRS Pattern

### Command + CommandHandler

```typescript
// CreateCourseCommand.ts — dumb data bag (domain layer)
export class CreateCourseCommand extends Command {
  readonly id: string;
  readonly name: string;
  readonly duration: string;

  constructor({ id, name, duration }: { id: string; name: string; duration: string }) {
    super();
    this.id = id;
    this.name = name;
    this.duration = duration;
  }
}

// CreateCourseCommandHandler.ts (application layer)
export class CreateCourseCommandHandler implements CommandHandler<CreateCourseCommand> {
  constructor(private courseCreator: CourseCreator) {}

  subscribedTo(): Command {
    return CreateCourseCommand;  // ← bind handler to command class
  }

  async handle(command: CreateCourseCommand): Promise<void> {
    const id = new CourseId(command.id);          // primitive → VO
    const name = new CourseName(command.name);
    const duration = new CourseDuration(command.duration);
    await this.courseCreator.run({ id, name, duration });
  }
}
```

### Use Case (Application Service)

```typescript
// CourseCreator.ts — thin orchestrator
export class CourseCreator {
  constructor(
    private repository: CourseRepository,  // port
    private eventBus: EventBus             // port
  ) {}

  async run(params: { id: CourseId; name: CourseName; duration: CourseDuration }): Promise<void> {
    const course = Course.create(params.id, params.name, params.duration);
    await this.repository.save(course);
    await this.eventBus.publish(course.pullDomainEvents()); // publish after save
  }
}
```

### InMemory CommandBus (infrastructure)

```typescript
// InMemoryCommandBus.ts
export class InMemoryCommandBus implements CommandBus {
  constructor(private commandHandlers: CommandHandlers) {}

  async dispatch(command: Command): Promise<void> {
    const handler = this.commandHandlers.get(command); // lookup by command class
    await handler.handle(command);
  }
}
```

---

## 📡 Event-Driven Architecture (EDA)

### Domain Event Subscriber

```typescript
// IncrementCoursesCounterOnCourseCreated.ts
// Bounded context khác (CoursesCounter) lắng nghe event từ Courses context
export class IncrementCoursesCounterOnCourseCreated
  implements DomainEventSubscriber<CourseCreatedDomainEvent>
{
  constructor(private incrementer: CoursesCounterIncrementer) {}

  // Khai báo sự kiện muốn subscribe
  subscribedTo(): DomainEventClass[] {
    return [CourseCreatedDomainEvent];
  }

  // Handler được gọi khi event xảy ra
  async on(domainEvent: CourseCreatedDomainEvent) {
    await this.incrementer.run(new CourseId(domainEvent.aggregateId));
  }
}
```

### EventBus Interface (domain port)

```typescript
// EventBus.ts
export interface EventBus {
  publish(events: Array<DomainEvent>): Promise<void>;
}
```

**Implementations:**
- `InMemoryAsyncEventBus` — local, async, dùng cho dev/test
- `RabbitMqEventBus` — production, cross-service pub/sub

---

## 🔄 Full Flow: Create Course

```
HTTP PUT /courses/:id
  ↓
Controller (apps layer)
  ↓ dispatch(CreateCourseCommand)
CommandBus → CreateCourseCommandHandler
  ↓ courseCreator.run()
CourseCreator (use case)
  ↓ Course.create() → records CourseCreatedDomainEvent
  ↓ repository.save(course)
  ↓ eventBus.publish(pullDomainEvents())
    ↓ [async]
    IncrementCoursesCounterOnCourseCreated.on()
      ↓ CoursesCounterIncrementer.run()
```

---

## 🔴 Domain Errors — Result/Either Pattern (Sairyss)

Thay vì throw HTTP exceptions trong domain, dùng **Result type** để return errors explicitly:

```typescript
// user.errors.ts — domain-specific errors
export class UserAlreadyExistsError extends Error {
  readonly code = 'USER_ALREADY_EXISTS';
}
export class IncorrectUserAddressError extends Error {
  readonly code = 'INCORRECT_ADDRESS';
}

// Sum type — exhaustive union
type CreateUserError = UserAlreadyExistsError | IncorrectUserAddressError;
```

```typescript
// create-user.service.ts — return Result, không throw
import { Ok, Err, Result } from 'oxide.ts'; // npm: oxide.ts

async execute(command: CreateUserCommand): Promise<Result<string, CreateUserError>> {
  // Check tồn tại → return Err, không throw
  if (await this.userRepo.exists(command.email)) {
    return Err(new UserAlreadyExistsError());
  }
  const user = UserEntity.create(command);
  await this.userRepo.save(user);
  return Ok(user.id.value);
}
```

```typescript
// create-user.http.controller.ts — map Error → HTTP status
const result = await this.commandBus.execute(command);
return match(result, {
  Ok: (id: string) => new IdResponse(id),
  Err: (error: Error) => {
    if (error instanceof UserAlreadyExistsError)
      throw new ConflictHttpException(error.message); // 409
    if (error instanceof IncorrectUserAddressError)
      throw new BadRequestException(error.message);   // 400
    throw error; // 500 - unknown
  },
});

// create-user.cli.controller.ts — CLI không cần HTTP status
const result = await this.commandBus.execute(command);
result.unwrap(); // throw nếu error — acceptable in CLI
```

**Khi nào throw, khi nào return?**
- ✅ **Return Err**: Business errors (UserAlreadyExists, InsufficientBalance, OutOfStock...)
- ⚠️ **Throw**: Technical exceptions (DB connection failed, OOM, process crash)

---

## 🔄 Domain Events vs Integration Events

```
Domain Events  = in-process, same bounded context, sync
Integration Events = cross-process/microservice, async, via message broker
```

```typescript
// Flow:
// 1. User aggregate records DomainEvent internally
// 2. Repository.save() publishes domain events
// 3. Domain event handler may emit Integration Event to broker (RabbitMQ/Kafka)

// create-wallet-when-user-is-created.domain-event-handler.ts
export class CreateWalletWhenUserIsCreated
  implements DomainEventHandler<UserCreatedDomainEvent>
{
  constructor(private walletCreator: WalletCreator) {}

  async handle(event: UserCreatedDomainEvent): Promise<void> {
    // Cross-aggregate side effect — triggered by event, not direct call
    await this.walletCreator.execute(new UserId(event.aggregateId));
  }
}

// sql-repository.base.ts — publishes domain events after save
async save(entity: AggregateRoot): Promise<void> {
  await this.db.save(entity.toPrimitives());
  // Pull then publish — events dispatched AFTER successful save
  const events = entity.pullDomainEvents();
  await this.eventBus.publish(events);
}
```

**Integration Event patterns cho distributed systems:**
- **Transactional Outbox**: save event trong DB cùng transaction, publish sau
- **Saga**: compensating events để rollback distributed transactions
- **Process Manager**: orchestrate multi-step cross-service workflows

---

## 🛡️ Guard vs Validate — Two-Layer Defense

```
Layer 1 (Outside): Validation    = filtration, input DTOs, class-validator
Layer 2 (Inside):  Guarding      = invariant, domain objects, Fail Fast
```

```typescript
// Layer 1: DTO validation (outside domain)
export class CreateUserRequestDto {
  @IsEmail()
  @MaxLength(320)
  email: string;

  @IsString()
  @MinLength(2)
  name: string;
}

// Layer 2: Domain guard (inside Value Object)
export class UserEmail extends ValueObject<string> {
  constructor(value: string) {
    super(value);
    // Guard: chỉ kiểm tra rule đơn giản, không conflict với class-validator
    Guard.againstNullOrEmpty(value, 'email');
    Guard.matches(value, /@/, 'email must contain @');
  }
}

// guard.ts — reusable guards
export class Guard {
  static againstNullOrEmpty(value: unknown, name: string): void {
    if (value === null || value === undefined || value === '')
      throw new ArgumentNotProvidedException(`${name} cannot be empty`);
  }
  static matches(value: string, pattern: RegExp, msg: string): void {
    if (!pattern.test(value)) throw new ArgumentInvalidException(msg);
  }
  static isPositive(value: number, name: string): void {
    if (value <= 0) throw new ArgumentOutOfRangeException(`${name} must be positive`);
  }
}
```

---

## 🗃️ Persistence Model Separation

Domain entities ≠ Database schema. Dùng Mapper để convert:

```typescript
// user.mapper.ts — bi-directional mapping
export class UserMapper {
  // Domain → DB (khi save)
  static toPersistence(entity: UserEntity): UserModel {
    return {
      id: entity.id.value,
      email: entity.email.value,       // VO → primitive
      name: entity.name.value,
      country: entity.address.country, // nested VO → flat columns
      street: entity.address.street,
      postalCode: entity.address.postalCode,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    };
  }

  // DB → Domain (khi load)
  static toDomain(record: UserModel): UserEntity {
    return UserEntity.reconstitute({
      id: new UserId(record.id),
      email: new UserEmail(record.email),
      name: new UserName(record.name),
      address: new Address({
        country: record.country,
        street: record.street,
        postalCode: record.postalCode,
      }),
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    });
  }
}
```

```typescript
// sql-repository.base.ts — generic CRUD với mapper
export abstract class SqlRepositoryBase<Entity, Model> {
  abstract tableName: string;
  abstract mapper: Mapper<Entity, Model>;

  async save(entity: Entity): Promise<void> {
    const record = this.mapper.toPersistence(entity);
    await this.db.upsert(this.tableName, record);
    // Publish domain events after save!
    if (entity instanceof AggregateRoot) {
      await this.eventBus.publish(entity.pullDomainEvents());
    }
  }

  async findOneById(id: string): Promise<Entity | null> {
    const record = await this.db.findOne(this.tableName, { id });
    return record ? this.mapper.toDomain(record) : null;
  }
}
```

---

## 🔒 Make Illegal States Unrepresentable (Typestate Pattern)

```typescript
// ❌ Cho phép illegal state: cả email và phone đều undefined
interface ContactInfo {
  email?: Email;
  phone?: Phone;
}

// ✅ Compile-time enforcement: PHẢI có ít nhất 1
type ContactInfo = Email | Phone | [Email, Phone];
// IDE báo lỗi ngay nếu không truyền vào!

// ❌ Primitive string cho phép bất kỳ giá trị nào
const role: string = 'superadmin'; // không có trong business rules

// ✅ Enum prevents illegal values at compile time
export enum UserRole { admin = 'admin', moderator = 'moderator', guest = 'guest' }
const role: UserRole = 'superadmin'; // ← TypeScript ERROR ngay!

// ✅ Domain Primitive — validate on creation, never invalid after
export class Money extends ValueObject<{ amount: number; currency: string }> {
  constructor(amount: number, currency: string) {
    super({ amount, currency });
    Guard.isPositive(amount, 'amount');
    Guard.isCurrencyCode(currency); // 3-letter ISO code
    // Sau khi tạo được, Money luôn valid — không cần validate lại
  }
}
```

---

## 🎯 Policy Pattern — Composable Business Rules (ddd-by-examples)

Thay vì if/else dài trong aggregate, extract từng business rule thành **Policy function**.
Mỗi policy là một pure function: `(context) => Either<Rejection, Allowance>`.

```typescript
// PlacingOnHoldPolicy.ts — functional interface
type PlacingOnHoldPolicy = (
  book: AvailableBook,
  patron: Patron,
  duration: HoldDuration
) => Either<Rejection, Allowance>;

// Policies riêng lẻ — dễ test, dễ đọc
const onlyResearcherCanHoldRestrictedBooks: PlacingOnHoldPolicy =
  (book, patron, _duration) => {
    if (book.isRestricted && patron.isRegular())
      return left(Rejection.withReason('Regular patrons cannot hold restricted books'));
    return right(new Allowance());
  };

const overdueCheckoutsRejectionPolicy: PlacingOnHoldPolicy =
  (book, patron, _duration) => {
    if (patron.overdueCheckoutsAt(book.libraryBranch) >= MAX_OVERDUE)
      return left(Rejection.withReason('Overdue checkouts exist at this branch'));
    return right(new Allowance());
  };

const regularPatronMaxHoldsPolicy: PlacingOnHoldPolicy =
  (book, patron, _duration) => {
    if (patron.isRegular() && patron.numberOfHolds() >= MAX_HOLDS)
      return left(Rejection.withReason('Patron cannot hold more books'));
    return right(new Allowance());
  };

const openEndedOnlyForResearchers: PlacingOnHoldPolicy =
  (_book, patron, duration) => {
    if (patron.isRegular() && duration.isOpenEnded())
      return left(Rejection.withReason('Regular patron cannot place open-ended holds'));
    return right(new Allowance());
  };
```

```typescript
// Patron.ts — aggregate compose tất cả policies
class Patron {
  placeOnHold(
    book: AvailableBook,
    duration: HoldDuration,
    policies: PlacingOnHoldPolicy[] = DEFAULT_POLICIES
  ): Either<BookHoldFailed, BookPlacedOnHoldEvents> {
    // Chạy tất cả policies — first rejection wins
    const rejection = policies
      .map(policy => policy(book, this, duration))
      .find(result => result.isLeft());

    if (rejection) {
      return left(BookHoldFailed.now(rejection.getLeft().reason, this.patronId, book.bookId));
    }

    const event = BookPlacedOnHold.now(this.patronId, book.bookId, duration);
    const maxHoldsEvent = this.numberOfHolds() >= MAX_HOLDS - 1
      ? some(MaximumNumberOfHoldsReached.now(this.patronId))
      : none();

    return right(BookPlacedOnHoldEvents.of(event, maxHoldsEvent));
  }
}
```

**Tại sao Policy Pattern tốt hơn if/else?**
- ✅ Mỗi policy có thể unit test độc lập
- ✅ Thêm/bỏ rule không sửa aggregate
- ✅ Inject policies khác nhau theo context
- ✅ Code phản ánh ngôn ngữ domain (từ EventStorming)

---

## 🎨 Domain Type System — State-based Classes (ddd-by-examples)

Thay vì 1 class `Book` với `status: Enum`, model mỗi state là 1 class riêng.
Compiler enforce transition rules — **không cần if/else check runtime**.

```typescript
// ❌ Status-based — phải check liên tục
class Book {
  status: 'AVAILABLE' | 'ON_HOLD' | 'CHECKED_OUT';

  placeOnHold(patron: Patron) {
    if (this.status !== 'AVAILABLE') throw new Error('Cannot hold'); // runtime!
    this.status = 'ON_HOLD';
  }
}

// ✅ Type-based — compile-time enforcement
class AvailableBook {           // chỉ có thể placeOnHold
  placeOnHold(patron: Patron, duration: HoldDuration): BookOnHold {
    return new BookOnHold(this.bookId, patron.patronId, duration);
  }
}

class BookOnHold {              // chỉ có thể cancelHold hoặc checkout
  cancelHold(): AvailableBook {
    return new AvailableBook(this.bookId, this.libraryBranch);
  }
  checkout(patron: Patron): CheckedOutBook {
    return new CheckedOutBook(this.bookId, patron.patronId);
  }
  // ❌ TỰ ĐỘNG BÁO LỖI: BookOnHold không có placeOnHold()
}

class CheckedOutBook {          // chỉ có thể return
  returnBook(): AvailableBook {
    return new AvailableBook(this.bookId, this.libraryBranch);
  }
}

// Business flow rõ ràng — function signatures nói lên tất cả:
// placeOnHold: AvailableBook → BookOnHold | BookHoldFailed
// cancelHold:  BookOnHold   → AvailableBook | BookHoldCancelFailed
// checkout:    BookOnHold   → CheckedOutBook
// return:      CheckedOutBook → AvailableBook
```

**TypeScript Union type để export ra ngoài:**
```typescript
type Book = AvailableBook | BookOnHold | CheckedOutBook;

// Repository trả về Book (union), caller phải narrow type
interface BookRepository {
  findBy(id: BookId): Promise<Book | null>;
  save(book: Book): Promise<void>;
}

// Callers dùng instanceof hoặc tagged unions:
const book = await repo.findBy(bookId);
if (book instanceof AvailableBook) {
  const result = patron.placeOnHold(book, duration); // OK!
}
```

---

## ⚡ Aggregate Returning Events (Event-First Pattern)

Aggregate method trả về **event trực tiếp**, repository lưu event thay vì state:

```typescript
// Thay vì
await repo.save(patronEntity); // save entity state

// Event-first:
const event: BookPlacedOnHold = await patron.placeOnHold(book); // method returns event!
await patronRepo.save(event); // repo saves the event
await bookRepo.handle(event); // book reacts to event
```

```typescript
// PatronRepository — saves events directly
interface PatronRepository {
  save(event: PatronEvent): Promise<void>;
  publish(event: PatronEvent): Promise<void>; // saves + dispatches
}

// Book aggregate is immutable — reacts to external events
class AvailableBook {
  // Books không tự hold — REACT to PatronEvent
  handle(event: BookPlacedOnHold): BookOnHold {
    return new BookOnHold(this.bookId, event.patronId, event.holdDuration);
  }

  handle(event: BookHoldCanceled): AvailableBook {
    return this; // vẫn available
  }
}
```

**Lợi ích:** Domain model thành immutable — mỗi method là pure function, không mutation.

---

## 🔀 Immediate vs Eventual Consistency Toggle

Design system để dễ dàng switch giữa 2 consistency models:

```typescript
// EventPublisher interface — abstract away delivery mechanism
interface DomainEventPublisher {
  publish(event: DomainEvent): Promise<void>;
}

// === OPTION 1: Immediate (sync) ===
// Dùng khi chưa cần message broker
class SyncEventPublisher implements DomainEventPublisher {
  constructor(private handlers: Map<string, DomainEventHandler[]>) {}

  async publish(event: DomainEvent): Promise<void> {
    const handlers = this.handlers.get(event.eventName) ?? [];
    await Promise.all(handlers.map(h => h.handle(event)));
    // Immediate: handler chạy TRONG cùng transaction
  }
}

// === OPTION 2: Store-and-Forward (eventual) ===
// Thêm message broker sau khi cần scale
class StoreAndForwardPublisher implements DomainEventPublisher {
  constructor(
    private eventStore: EventStore,
    private syncPublisher: SyncEventPublisher
  ) {}

  async publish(event: DomainEvent): Promise<void> {
    await this.eventStore.save(event); // persist trước
    // Scheduler chạy định kỳ:
  }

  // Chạy mỗi 3 giây — eventual delivery
  @Cron('*/3 * * * * *')
  async publishPending(): Promise<void> {
    const pending = await this.eventStore.findUnpublished();
    for (const event of pending) {
      await this.syncPublisher.publish(event);
      await this.eventStore.markPublished(event);
    }
  }
}

// NestJS module: chỉ đổi implementation, code không đổi
@Module({
  providers: [
    // Swap implementation khi cần:
    { provide: 'DomainEventPublisher', useClass: SyncEventPublisher },
    // { provide: 'DomainEventPublisher', useClass: StoreAndForwardPublisher },
  ]
})
export class InfrastructureModule {}
```

> **Nguyên tắc:** Bắt đầu với Immediate consistency (đơn giản). Khi cần scale, swap sang StoreAndForward — code không thay đổi.

---

## 🧪 BDD Testing DSL — Domain Language Tests

Viết test bằng ngôn ngữ domain, không phải tech language:

```typescript
// Test DSL builder — fluent API phản ánh ubiquitous language
class BookTestBuilder {
  private bookId = new BookId(uuid());
  private libraryBranch = new LibraryBranchId(uuid());

  static aCirculatingBook() { return new BookTestBuilder('CIRCULATING'); }
  static aRestrictedBook() { return new BookTestBuilder('RESTRICTED'); }

  with(bookId: BookId) { this.bookId = bookId; return this; }
  locatedIn(branch: LibraryBranchId) { this.libraryBranch = branch; return this; }

  // State transition DSL
  placedOnHoldBy(patron: PatronId): BookOnHoldBuilder {
    const event = new BookPlacedOnHold(this.bookId, patron, this.libraryBranch);
    return new BookOnHoldBuilder(this, event);
  }

  build(): AvailableBook {
    return new AvailableBook(this.bookId, this.bookType, this.libraryBranch);
  }
}

// Test reads like business specification:
it('should make book available when hold canceled', async () => {
  // Given
  const bookOnHold = BookTestBuilder
    .aCirculatingBook()
    .with(anyBookId())
    .locatedIn(anyBranch())
    .placedOnHoldBy(anyPatron())
    .build();

  // When
  const cancelEvent = new BookHoldCanceled(bookOnHold.bookId, anyPatron());
  const availableBook = bookOnHold.handle(cancelEvent); // pure function!

  // Then
  expect(availableBook).toBeInstanceOf(AvailableBook);
  expect(availableBook.bookId).toEqual(bookOnHold.bookId);
});

// Aggregate test — NO mocking, NO DB
it('researcher can place open-ended hold', async () => {
  const researcher = PatronTestBuilder.aResearcher().build();
  const restrictedBook = BookTestBuilder.aRestrictedBook().build();

  const result = researcher.placeOnHold(restrictedBook, HoldDuration.openEnded());

  expect(result.isRight()).toBe(true);
  const events = result.getRight();
  expect(events.bookPlacedOnHold).toBeDefined();
});
```

**Kết hợp Vitest + DSL builder:**
- Test không cần mock DB, không cần Spring context
- Test là tài liệu sống của business rules
- Từ EventStorming → Example Mapping → BDD test → code

---

## 🏛️ Architecture Enforcement (TypeScript equivalent of ArchUnit)

Dùng **eslint rules** + **module boundaries** thay ArchUnit:

```typescript
// .eslintrc.js — enforce layer dependencies
module.exports = {
  rules: {
    // Domain KHÔNG được import infrastructure
    'no-restricted-imports': ['error', {
      patterns: [
        {
          group: ['*/infrastructure/*'],
          message: 'Domain layer cannot depend on infrastructure'
        },
        {
          group: ['@nestjs/*', 'express', 'fastify'],
          message: 'Domain layer cannot depend on frameworks'
        }
      ]
    }]
  },
  overrides: [
    {
      files: ['src/**/domain/**/*.ts'],
      rules: { 'no-restricted-imports': 'error' }
    }
  ]
};

// Hoặc dùng @nx/enforce-module-boundaries trong NX monorepo
// Hoặc dùng jest-architecture từ Sairyss pattern
```

---

## 🗺️ Bounded Context Design Rules

| Rule | Why |
|------|-----|
| Mỗi context có `Shared/` riêng | Tránh coupling giữa các context |
| Contexts giao tiếp qua Events, không direct call | Loose coupling |
| `apps/` không có business logic | Separation of concerns |
| Controller chỉ parse HTTP → dispatch Command/Query | Thin controllers |
| Repository interface trong `domain/`, impl trong `infrastructure/` | Hexagonal |

---

## 🧪 Testing Patterns

### Unit Test — Use Case

```typescript
// Test CourseCreator
it('should create a course', async () => {
  const repository = new InMemoryCourseRepository();
  const eventBus = new FakeEventBus();
  const creator = new CourseCreator(repository, eventBus);

  await creator.run({ id: new CourseId('uuid'), name: new CourseName('DDD'), duration: new CourseDuration('10 hours') });

  expect(repository.courses).toHaveLength(1);
  expect(eventBus.published).toHaveLength(1);
  expect(eventBus.published[0]).toBeInstanceOf(CourseCreatedDomainEvent);
});
```

### Integration Test — Cucumber/Gherkin

Repo dùng **Cucumber.js** cho acceptance tests — BDD style:

```gherkin
Feature: Create Course
  Scenario: A valid non existing course
    Given I send a PUT request to "/courses/uuid" with body:
      | name     | TypeScript DDD |
      | duration | 10 hours       |
    Then the response status code should be 201
```

---

## ⚠️ Anti-patterns to Avoid

```typescript
// ❌ Anemic domain model — logic ở service, không ở aggregate
class CourseService {
  createCourse(id: string, name: string) {
    const course = new Course();
    course.id = id;
    course.name = name; // setter công khai
    return course;
  }
}

// ✅ Rich domain model — logic trong aggregate
const course = Course.create(id, name, duration); // factory method
// domain validates ngay trong constructor/factory

// ❌ Leaking domain logic vào controller
app.put('/courses/:id', async (req, res) => {
  if (req.body.name.length > 30) throw new Error('Too long'); // validation sai chỗ
  await db.save({ id: req.params.id, ...req.body });
});

// ✅ Controller chỉ dispatch command
app.put('/courses/:id', async (req, res) => {
  await commandBus.dispatch(new CreateCourseCommand({
    id: req.params.id,
    name: req.body.name,
    duration: req.body.duration,
  }));
  res.status(201).send();
});

// ❌ Application layer biết về HTTP
class CourseCreator {
  async run(req: Request, res: Response) { ... } // sai!
}

// ✅ Use case nhận domain objects, trả Response interface
class CourseCreator {
  async run(params: { id: CourseId; name: CourseName; duration: CourseDuration }): Promise<void>
}
```

---

## 📦 Naming Conventions

| Artifact | Convention | Example |
|----------|-----------|---------|
| Aggregate | `PascalCase` | `Course`, `CoursesCounter` |
| Value Object | `{Aggregate}{Field}` | `CourseName`, `CourseDuration` |
| Domain Event | `{Aggregate}{PastAction}DomainEvent` | `CourseCreatedDomainEvent` |
| Event name constant | `snake_case` | `'course.created'` |
| Command | `{Action}{Aggregate}Command` | `CreateCourseCommand` |
| CommandHandler | `{Action}{Aggregate}CommandHandler` | `CreateCourseCommandHandler` |
| Use Case | `{Aggregate}{Action}` | `CourseCreator`, `CourseFinder` |
| Repository | `{Aggregate}Repository` | `CourseRepository` |
| Event Subscriber | `{Action}On{Event}` | `IncrementCoursesCounterOnCourseCreated` |
| Folder (use case type) | `PascalCase` intent | `Create/`, `SearchAll/`, `Find/`, `Increment/` |

---

## 🔧 Applying to NestJS/Prisma Stack

### Adapter Pattern cho Prisma Repository

```typescript
// infrastructure/MysqlCourseRepository.ts
@Injectable()
export class MysqlCourseRepository implements CourseRepository {
  constructor(private prisma: PrismaService) {}

  async save(course: Course): Promise<void> {
    const data = course.toPrimitives();
    await this.prisma.course.upsert({
      where: { id: data.id },
      update: data,
      create: data,
    });
  }

  async searchAll(): Promise<Course[]> {
    const rows = await this.prisma.course.findMany();
    return rows.map(r => Course.fromPrimitives(r));
  }
}
```

### NestJS Module wiring (DI)

```typescript
@Module({
  providers: [
    // Use cases
    CourseCreator,
    // Repositories (bind interface → implementation)
    { provide: 'CourseRepository', useClass: MysqlCourseRepository },
    // Buses
    { provide: 'EventBus', useClass: InMemoryAsyncEventBus },
    { provide: 'CommandBus', useClass: InMemoryCommandBus },
    // Command Handlers
    CreateCourseCommandHandler,
  ],
})
export class CoursesModule {}
```

---

## 🚦 When to Use Each Pattern

| Situation | Pattern |
|-----------|---------|
| Tạo/thay đổi state | Command + CommandHandler |
| Đọc dữ liệu | Query + QueryHandler |
| Phản ứng với event (cross-context) | DomainEventSubscriber |
| Business validation phức tạp | ValueObject với guard clauses |
| Nhiều bước orchestration | Use Case (Application Service) |
| Complex business rule | Domain Service (inject vào Use Case) |
| Test infrastructure | In-Memory implementations |

---

## 📁 Folder Naming Conventions (Sairyss)

| File | Pattern | Example |
|------|---------|--------|
| Entity | `{name}.entity.ts` | `user.entity.ts` |
| Value Object | `{name}.value-object.ts` | `address.value-object.ts` |
| Domain Event | `{past-action}.domain-event.ts` | `user-created.domain-event.ts` |
| Domain Error | `{module}.errors.ts` | `user.errors.ts` |
| Command | `{action}-{resource}.command.ts` | `create-user.command.ts` |
| Command Handler/Service | `{action}-{resource}.service.ts` | `create-user.service.ts` |
| HTTP Controller | `{action}-{resource}.http.controller.ts` | |
| CLI Controller | `{action}-{resource}.cli.controller.ts` | |
| Message Controller | `{action}-{resource}.message.controller.ts` | |
| Query Handler | `find-{resource}.query-handler.ts` | |
| Repository Port | `{resource}.repository.port.ts` | |
| Repository Impl | `{resource}.repository.ts` | |
| Mapper | `{resource}.mapper.ts` | |
| Request DTO | `{action}-{resource}.request.dto.ts` | |
| Response DTO | `{resource}.response.dto.ts` | |

---

## ⚖️ When to Apply Full DDD (YAGNI Check)

| Project Size | Recommendation |
|---|---|
| Small CRUD API | ❌ Skip DDD — quá phức tạp, dùng simple service/repo |
| Medium with business rules | ✅ Apply selectively: Entities, VOs, basic CQRS |
| Large complex domain | ✅ Full DDD: Aggregates, Events, Result type, Persistence Model separation |
| Microservices | ✅ Full DDD + Integration Events + Outbox + Saga |

> "It's easier to refactor over-design than it's to refactor no design."

**Process Discovery first:**
1. **Big Picture EventStorming** → identify bounded contexts
2. **Example Mapping** → concrete scenarios, business rules
3. **Design Level EventStorming** → commands, events, aggregates, policies
4. → Code reflects the model (no model-code gap)

---

## 🔗 Related Skills

- `nestjs-clean-arch` — NestJS-specific architecture patterns (overlapping với DDD)
- `prisma-orm` — Persistence layer implementation
- `moleculer-patterns` — Microservices extension của EDA patterns
- `medusa-commerce` — Workflow pattern tương tự cho commerce domain

---

## 🏭 `types-ddd` Library — Built-in DDD Abstractions (natserract)

Thay vì tự viết base classes từ đầu, dùng `types-ddd` npm package:

```bash
npm install types-ddd
```

```typescript
import { Aggregate, Result, IUseCase } from 'types-ddd';

// ✅ Aggregate tích hợp sẵn event system
export class User extends Aggregate<UserCreationAttributes> {
  private constructor(props: UserCreationAttributes) {
    super(props); // id, createdAt, updatedAt auto-managed
  }

  static create(props: UserCreationAttributes): Result<User> {
    const user = new User(props);
    const userAdded = new UserAdded(); // domain event
    user.addEvent(userAdded);          // register event
    return Result.Ok(user);
  }
}

// ✅ Result<T, Err> type built-in
const result: Result<User> = User.create(props);
if (result.isFail()) {
  console.log(result.error()); // type-safe error
}
const user = result.value(); // unwrap safely

// ✅ IUseCase<Input, Output> contract
export class UserCreateUseCase implements IUseCase<CreateUserDTO, Result<UserModel, string>> {
  async execute(dto: CreateUserDTO): Promise<Result<UserModel, string>> {
    const schema = CreateUserDTOSchema.safeParse(dto); // Zod validation
    if (!schema.success) {
      return Result.fail(fromZodError(schema.error).toString()); // schema error → Result.fail
    }
    // ...
    return Result.Ok(createdUser);
  }
}
```

**Tradeoff:** `types-ddd` bundled Aggregate/Result — tiện nhưng coupling vào third-party. NestJS stack thường tự implement base classes.

---

## 💉 TSyringe IoC — DI Không Cần NestJS Framework

Dùng [microsoft/tsyringe](https://github.com/microsoft/tsyringe) cho DI trong non-NestJS apps (Express, Koa, Fastify):

```typescript
// tsconfig.json bắt buộc:
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  }
}
```

```typescript
// Đăng ký dependencies
import 'reflect-metadata'; // phải import TRƯỚC tsyringe
import { container } from 'tsyringe';

container.register('UserRepository', { useClass: UserWriteRepository });
container.registerSingleton(UserCreateUseCase);

// Use case nhận deps qua constructor injection
@injectable()
export class UserCreateUseCase implements IUseCase<CreateUserDTO, Result<UserModel, string>> {
  constructor(
    @inject(UserReadRepository)  private readRepo: UserReadRepository,
    @inject(UserWriteRepository) private writeRepo: IUserCreateRepository,
    @inject(CustomerWriteRepository) private customerRepo: CustomerWriteRepository,
  ) {}

  async execute(dto: CreateUserDTO): Promise<Result<UserModel, string>> { ... }
}

// Controller cũng injectable
@injectable()
export class UserController extends BaseController {
  constructor(
    @inject(UserGetAllUseCase) private getAllUseCase: UserGetAllUseCase,
    @inject(UserCreateUseCase) private createUseCase: UserCreateUseCase
  ) { super(); }
}

// Bootstrap: resolve từ container
const userController = container.resolve(UserController);
app.use('/users', userController.register().routes());
```

**So sánh TSyringe vs NestJS DI:**
| | TSyringe | NestJS |
|---|---|---|
| Setup | Nhẹ, decorator-based | Module system phức tạp hơn |
| Framework | Framework-agnostic | Tied to NestJS |
| Scope | Transient/Singleton | Transient/Singleton/Scoped(request) |
| Testing | `container.resolve()` in tests | `createTestingModule()` |

---

## 📂 CQRS Repository Split — Read vs Write Repos

Thay vì 1 repository có cả read lẫn write, tách thành 2 base classes riêng:

```typescript
// BaseReadRepository — CHỈ đọc dữ liệu
export abstract class BaseReadRepository<ModelT extends Model> {
  protected readonly model: ModelStatic<ModelT>;
  eagerLoadMapping: Map<string, EagerLoad>;   // preloaded associations
  orderSet: Set<OrderItem>;                   // default ordering
  baseWhereClause: WhereOptions<...>;         // soft-delete filter, tenant filter...

  // Consistent query API:
  async get(id: number, options?): Promise<ModelT>           // throw if not found
  async getAny(id: number, options?): Promise<ModelT | null> // return null if not found
  async getAll(options?): Promise<ModelT[]>
  async first(where?, options?): Promise<ModelT | null>      // findOne
  async firstAny(where?, options?): Promise<ModelT | null>   // findOne, no throw
  async where(where?, options?): Promise<ModelT[]>           // findAll with filter
  async count(where?, options?): Promise<number>
}

// BaseWriteRepository — CHỈ ghi/xóa dữ liệu
export abstract class BaseWriteRepository<WriteModelType, WriteAttributesType, AggregateRootType> {
  async save(aggregate, transaction?): Promise<WriteModelType>
  async update(aggregate, transaction?): Promise<WriteModelType>
  async updateAny(aggregate, transaction?): Promise<WriteModelType> // no modifiable check
  async delete(id, transaction?): Promise<number>
  async getById(id): Promise<WriteModelType>             // fetch before update/delete

  // Template methods cho subclass override:
  protected toAggregateRoot(model): AggregateRootType   // Model → Domain
  protected toValues(aggregate): object                  // Domain → Model (via .toObject())
}
```

```typescript
// Concrete Read Repository — inject associations tại constructor
@injectable()
export class UserReadRepository extends BaseReadRepository<UserModel> {
  constructor() {
    super(
      UserModel,
      [{ model: ProfileModel, as: 'profile' }], // eager load
      [['createdAt', 'DESC']],                   // default order
      { deletedAt: null }                        // default where (soft delete)
    );
  }

  // Custom query nằm trong read repo
  async getByUserUuid(uuid: string): Promise<UserModel> {
    return this.first({ uuid });
  }
}

// Concrete Write Repository — simple, no associations
@injectable()
export class UserWriteRepository extends BaseWriteRepository<UserModel, UserCreationAttributes, User> {
  constructor() { super(UserModel); }

  // toValues() override để convert User aggregate → plain object
  protected toValues(user: User) {
    return user.toObject(); // types-ddd aggregate method
  }
}
```

**Tại sao split Read/Write?**
- ✅ Read side: optimize for queries — joins, eager loading, projections
- ✅ Write side: optimize for writes — transactions, validation, events
- ✅ Scale independently: read DB ≠ write DB (future CQRS scaling)

---

## 🔄 Nested Transaction Propagation

Pattern truyền transaction qua call stack — tránh nested transactions mở transaction mới bên trong transaction đã tồn tại:

```typescript
// BaseWriteRepository.beginTransaction — static helper
static async beginTransaction<T>(
  options: { t?: TransactionSequelize },  // t = parent transaction (optional)
  callback: (t: TransactionSequelize) => Promise<T>
): Promise<T> {
  let currentTransaction = options.t;

  // Nếu KHÔNG có parent transaction → tạo mới
  if (!currentTransaction) {
    currentTransaction = await sequelize.transaction();
  }
  // Nếu CÓ parent transaction → dùng lại (không tạo nested)

  try {
    const result = await callback(currentTransaction);
    // Chỉ commit khi là TOP-LEVEL (không có t được truyền vào)
    if (!options.t) {
      await currentTransaction.commit();
    }
    return result;
  } catch (err) {
    // Chỉ rollback khi là TOP-LEVEL
    if (!options.t) {
      await currentTransaction.rollback();
    }
    throw err;
  }
}

// Dùng trong use case — một user tạo kéo theo customer trong cùng transaction:
export class UserCreateUseCase {
  async execute(dto, isAdmin = false, parentTransaction?: Transaction) {
    return BaseWriteRepository.beginTransaction({ t: parentTransaction }, async (t) => {
      const user = User.create(dto);
      const createdUser = await this.userRepo.save(user.value(), t); // pass t xuống

      if (!isAdmin) {
        // createCustomer CŨNG dùng cùng t → atomic!
        await this.createCustomer(createdUser.id, dto, t);
      }

      return Result.Ok(createdUser);
    });
  }

  private async createCustomer(userId, dto, parentTransaction: Transaction) {
    const customer = Customer.create({ ...dto, userId });
    return this.customerRepo.save(customer.value(), parentTransaction);
  }
}

// Caller có thể wrap trong transaction lớn hơn:
const outerTx = await sequelize.transaction();
try {
  await userUseCase.execute(dto, false, outerTx);   // dùng outerTx
  await paymentUseCase.execute(payData, outerTx);   // cùng outerTx
  await outerTx.commit();
} catch {
  await outerTx.rollback();
}
```

**Nguyên tắc:** `parentTransaction` optional parameter — caller quyết định scope. Không bao giờ bắt đầu transaction mới nếu đã có parent.

---

## 🏪 AsyncLocalStorage — Request-Scoped Context

Chia sẻ data trong scope của 1 request mà không cần truyền qua params:

```typescript
// store.ts — singleton AsyncLocalStorage
import { AsyncLocalStorage } from 'async_hooks';

type RequestStore = {
  user?: UserModel;
  requestId?: string;
  // thêm context cần thiết khác
};

class RequestContextStore {
  private storage = new AsyncLocalStorage<RequestStore>();

  run<T>(store: RequestStore, callback: () => Promise<T>) {
    return this.storage.run(store, callback);
  }

  get(): RequestStore | undefined {
    return this.storage.getStore();
  }
}

export const asyncLocalStorage = new RequestContextStore();

// Controller: set context một lần tại middleware/router param
this.router.use('/:userUuid', async (ctx: Context, next: Next) => {
  const user = await this.userGetUseCase.execute(ctx.params.userUuid);
  const store = asyncLocalStorage.get();
  await asyncLocalStorage.run({ ...store, user }, next); // inject user vào context
});

// Handler: đọc từ context — không cần query lại DB
get = async (ctx: Context) => {
  const user = asyncLocalStorage.get()!.user!; // available từ middleware
  ctx.body = { user };
};
```

**Khi nào dùng AsyncLocalStorage:**
- ✅ Pass authenticated user qua toàn bộ request pipeline
- ✅ Distributed tracing (request ID, correlation ID)
- ✅ Tenant context trong multi-tenant apps
- ❌ Không dùng làm cache — reset mỗi request

---

## 🗃️ Interface Segregation cho Repository Ports

Thay vì 1 interface lớn, split thành nhiều interface nhỏ theo use case:

```typescript
// ❌ God repository interface
interface IUserRepository {
  getAll(): Promise<UserModel[]>;
  getById(id: string): Promise<UserModel>;
  getByUuid(uuid: string): Promise<UserModel>;
  save(user: User): Promise<UserModel>;
  update(user: User): Promise<UserModel>;
  delete(id: string): Promise<void>;
}

// ✅ Segregated interfaces — ISP principle
export interface IUserGetAllRepository {
  getAll(): Promise<UserModel[]>;
}

export interface IUserGetByIdRepository {
  getByUserUuid(uuid: string): Promise<UserModel>;
}

export interface IUserReadRepository extends IUserGetAllRepository, IUserGetByIdRepository {}

export interface IUserCreateRepository {
  getById(id: AggregateId): Promise<UserModel>;
  save(user: User, tx?: Transaction): Promise<UserModel>;
}

export interface IUserWriteRepository extends IUserCreateRepository {}

// Use case chỉ phụ thuộc vào interface cần thiết:
class UserCreateUseCase {
  constructor(
    private readRepo: IUserReadRepository,   // chỉ dùng để check duplicate
    private writeRepo: IUserCreateRepository, // chỉ dùng để save
  ) {}
}
```

**Lợi ích:**
- Test dễ hơn — mock nhỏ hơn
- Use case tường minh về dependency
- Dễ phát hiện vi phạm SRP trong use case

---

## 📚 Key References

- [Sairyss/domain-driven-hexagon](https://github.com/Sairyss/domain-driven-hexagon) — 14.5k★, NestJS + Slonik (infrastructure, errors)
- [ddd-by-examples/library](https://github.com/ddd-by-examples/library) — Java/Spring, Policy, State Types, functional domain
- [CodelyTV/typescript-ddd-example](https://github.com/CodelyTV/typescript-ddd-example) — CQRS/EDA TypeScript baseline
- [natserract/nodejs-ddd](https://github.com/natserract/nodejs-ddd) — KoaJS + TSyringe, CQRS repo split, nested transactions
- [Sairyss/backend-best-practices](https://github.com/Sairyss/backend-best-practices)
- [Effective Aggregate Design (Vernon)](https://www.dddcommunity.org/wp-content/uploads/files/pdf_articles/Vernon_2011_1.pdf)
- [Always-Valid Domain Model](https://enterprisecraftsmanship.com/posts/always-valid-domain-model/)
- [types-ddd](https://www.npmjs.com/package/types-ddd) — Built-in Aggregate/Result/IUseCase
- [microsoft/tsyringe](https://github.com/microsoft/tsyringe) — Lightweight DI container TypeScript
- [oxide.ts](https://www.npmjs.com/package/oxide.ts) — Result<T, E> TypeScript
- [fp-ts](https://gcanti.github.io/fp-ts/) — Either/Option monads TypeScript
