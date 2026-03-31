---
name: medusa-commerce
description: >
  Medusa.js — Open-source commerce platform with modular architecture.
  Use when building e-commerce solutions, understanding Medusa's module system,
  workflows, data models, events, or integrating Medusa into existing systems.
  Also use as reference for headless commerce architecture patterns.
  ⚠️ EXPLICIT INVOKE ONLY — dự án hiện tại là NestJS/Express app, không phải Medusa.
  Invoke explicitly khi cần architect commerce features hoặc study Medusa patterns.
---

# Medusa.js — Nền tảng Commerce Mô-đun

## Tổng quan

**Medusa** là "nền tảng commerce linh hoạt nhất thế giới" — một **digital commerce platform** với built-in framework cho customization. Khác với Shopify hay WooCommerce, Medusa cung cấp **foundational building blocks** thay vì solutions đóng gói cứng nhắc.

- **License**: MIT — hoàn toàn open-source
- **Stars**: 32.5k+ trên GitHub
- **Stack**: TypeScript, Node.js, PostgreSQL, MikroORM
- **Version hiện tại**: v2.13.x

### Vấn đề Medusa giải quyết

| Vấn đề | Giải pháp của Medusa |
|--------|---------------------|
| Platform cứng nhắc | Modular, fully customizable |
| Reinvent core commerce logic | Built-in modules (Cart, Product, Order...) |
| Distributed system data consistency | Built-in Workflow engine (durable execution) |
| Custom business models (B2B, Marketplace, PoS) | Module + Link system |
| Vendor lock-in | MIT license, self-hostable |

---

## Kiến trúc cốt lõi

```
┌──────────────────────────────────────────────────────────┐
│                    Medusa Application                     │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ API Routes│  │Workflows │  │Subscribers│              │
│  └─────┬────┘  └────┬─────┘  └────┬─────┘              │
│        └─────────────┼─────────────┘                     │
│                      ↓                                   │
│         ┌────────────────────────┐                       │
│         │  Medusa Container (DI) │                       │
│         └────────────────────────┘                       │
│                      ↓                                   │
│  ┌─────────────────────────────────────────────┐        │
│  │              Commerce Modules                │        │
│  │  ┌────────┐ ┌─────────┐ ┌────────────────┐ │        │
│  │  │  Cart  │ │ Product │ │  Order/Fulfill  │ │        │
│  │  └────────┘ └─────────┘ └────────────────┘ │        │
│  │  ┌────────┐ ┌─────────┐ ┌────────────────┐ │        │
│  │  │Payment │ │Inventory│ │  Custom Modules │ │        │
│  │  └────────┘ └─────────┘ └────────────────┘ │        │
│  └─────────────────────────────────────────────┘        │
│                      ↓                                   │
│            ┌──────────────────┐                          │
│            │   PostgreSQL DB  │                          │
│            └──────────────────┘                          │
└──────────────────────────────────────────────────────────┘
```

---

## 1. Commerce Modules

Modules là **reusable packages** của functionalities liên quan đến một domain.

### Built-in Commerce Modules

| Category | Modules |
|----------|---------|
| **Cart & Purchase** | Cart, Payment, Customer |
| **Merchandising** | Pricing, Promotion, Product |
| **Fulfillment** | Order, Inventory, Fulfillment, Stock Location |
| **Regions & Channels** | Region, Sales Channel, Tax, Currency |
| **User Access** | API Keys, Auth, Admin User |

### Cấu trúc một Custom Module

```
src/modules/blog/
├── models/
│   └── post.ts          ← Data Model (DML)
├── migrations/
│   └── Migration20240101.ts  ← Auto-generated
├── service.ts           ← Business logic + CRUD
└── index.ts             ← Module definition export
```

### Tạo Custom Module — Step by Step

**Bước 1: Data Model** (`src/modules/blog/models/post.ts`)
```typescript
import { model } from "@medusajs/framework/utils"

const Post = model.define("post", {
  id: model.id().primaryKey(),
  title: model.text(),
  content: model.text().nullable(),
  // created_at, updated_at, deleted_at → tự động có
})

export default Post
```

**Bước 2: Service** (`src/modules/blog/service.ts`)
```typescript
import { MedusaService } from "@medusajs/framework/utils"
import Post from "./models/post"

class BlogModuleService extends MedusaService({
  Post, // MedusaService tự generate CRUD methods
}) {
  // createPosts(), retrievePost(), listPosts(), deletePost()... ready!
  
  // Custom methods nếu cần:
  async getPublishedPosts() {
    return this.listPosts({ published: true })
  }
}

export default BlogModuleService
```

**Bước 3: Export Definition** (`src/modules/blog/index.ts`)
```typescript
import { Module } from "@medusajs/framework/utils"
import BlogModuleService from "./service"

export const BLOG_MODULE = "blog"

export default Module(BLOG_MODULE, {
  service: BlogModuleService,
})
```

**Bước 4: Register** (`medusa-config.ts`)
```typescript
module.exports = defineConfig({
  modules: [
    {
      resolve: "./src/modules/blog",
    },
  ],
})
```

**Bước 5: Migrate**
```bash
npx medusa db:generate blog    # Generate migration file
npx medusa db:migrate          # Run migrations
```

### MedusaService — Service Factory

`MedusaService` tự động generate các methods CRUD:
- `createPosts(data[])` → create records
- `retrievePost(id)` → get single record
- `listPosts(filters)` → list với filtering
- `updatePosts(data[])` → update records
- `deletePost(id)` → soft delete

> **Tip**: Suffix method = pluralized tên data model (Post → Posts, Category → Categories)

---

## 2. Module Links — Kết nối Modules Isolated

### Vấn đề: Modules bị isolated hoàn toàn

Medusa dùng **module isolation** để tránh side effects. Không thể trực tiếp add relation từ module này sang module khác.

### Giải pháp: `defineLink`

```typescript
// src/links/blog-product.ts
import { defineLink } from "@medusajs/framework/utils"
import ProductModule from "@medusajs/medusa/product"
import BlogModule from "../modules/blog"

export default defineLink(
  ProductModule.linkable.product,  // Product.id
  BlogModule.linkable.post,        // Post.id
)
// → Tạo bảng: product_product_blog_post { product_id, post_id }
```

### Relationship Types

```typescript
// One-to-One (default)
defineLink(ProductModule.linkable.product, BlogModule.linkable.post)

// One-to-Many (1 product → nhiều posts)
defineLink(
  ProductModule.linkable.product,
  { linkable: BlogModule.linkable.post, isList: true }
)

// Many-to-Many
defineLink(
  { linkable: ProductModule.linkable.product, isList: true },
  { linkable: BlogModule.linkable.post, isList: true }
)

// With cascade delete
defineLink(
  ProductModule.linkable.product,
  {
    linkable: BlogModule.linkable.post,
    deleteCascade: true,  // Xóa product → xóa linked posts
  }
)
```

```bash
npx medusa db:sync-links  # Sync link tables
```

---

## 3. Workflow Engine — Durable Execution

### Workflow là gì?

Medusa có **built-in durable execution engine** để orchestrate tasks spanning nhiều systems (ERP, CMS, CRM, Payment). Khác với function thông thường, Workflow:

1. ✅ Track từng step's progress internally
2. ✅ Support rollback logic (compensation functions)  
3. ✅ Perform long actions asynchronously
4. ✅ Execute from API Routes, Subscribers, Scheduled Jobs

### Tương đương Saga Pattern

```
Workflow = Orchestrated Saga với built-in compensation
Step = Local transaction với rollback logic
Compensation = Compensating transaction
```

### Tạo Workflow

**Step 1: Create Steps** (`src/workflows/create-post.ts`)
```typescript
import {
  createStep,
  createWorkflow,
  StepResponse,
} from "@medusajs/framework/workflows-sdk"
import { BLOG_MODULE } from "../modules/blog"
import BlogModuleService from "../modules/blog/service"

// Step: Create a blog post
const createPostStep = createStep(
  "create-post-step",
  // ← Step function
  async (input: { title: string }, { container }) => {
    const blogService = container.resolve<BlogModuleService>(BLOG_MODULE)
    const post = await blogService.createPosts({ title: input.title })
    
    return new StepResponse(post, post.id) // (result, rollbackData)
  },
  // ← Compensation function (rollback)
  async (postId: string, { container }) => {
    const blogService = container.resolve<BlogModuleService>(BLOG_MODULE)
    await blogService.deletePost(postId)
  }
)

// Step 2: Another step (e.g., notify ERP)
const notifyERPStep = createStep(
  "notify-erp-step",
  async (input: { postId: string }, { container }) => {
    // Call ERP API...
    return new StepResponse({ success: true })
  },
  // Compensation: undo ERP notification if later step fails
  async (_, { container }) => {
    // Roll back ERP notification
  }
)
```

**Step 2: Compose Workflow**
```typescript
// Tiếp trong file trên
import { transform } from "@medusajs/framework/workflows-sdk"

type CreatePostInput = { title: string }

export const createPostWorkflow = createWorkflow(
  "create-post",
  (input: CreatePostInput) => {
    // Execute steps in order
    const post = createPostStep(input)
    
    // Transform data between steps
    const notifyInput = transform({ post }, (data) => ({
      postId: data.post.id,
    }))
    
    notifyERPStep(notifyInput)
    
    return post
  }
)
```

**Step 3: Execute từ API Route**
```typescript
// src/api/admin/posts/route.ts
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { createPostWorkflow } from "../../../workflows/create-post"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { result } = await createPostWorkflow(req.scope).run({
    input: { title: req.body.title },
  })
  res.json({ post: result })
}
```

### Error Handling & Rollback

```
Workflow: Step1 → Step2 → Step3 → ❌ Error tại Step3

Medusa tự động:
→ Chạy compensation(Step2) [undo Step2]
→ Chạy compensation(Step1) [undo Step1]
→ Data consistent ✅
```

### Advanced Workflow Patterns

```typescript
// Parallel steps
import { parallelize } from "@medusajs/framework/workflows-sdk"

createWorkflow("parallel-example", (input) => {
  const [result1, result2] = parallelize(
    stepOne(input),
    stepTwo(input)
  )
  // Cả hai chạy song song!
})

// Conditional execution (When-Then)
import { when } from "@medusajs/framework/workflows-sdk"

createWorkflow("conditional-example", (input) => {
  const shouldNotify = transform(input, (data) => data.sendEmail)
  
  when({ shouldNotify }, ({ shouldNotify }) => shouldNotify)
    .then(() => sendEmailStep(input))
  
  return someStep(input)
})
```

---

## 4. API Routes

### Cấu trúc

```
src/api/
├── admin/              ← Authenticated admin routes
│   └── blog/
│       └── route.ts
└── store/              ← Public storefront routes
    └── blog/
        └── route.ts
```

### Tạo API Route

```typescript
// src/api/admin/blog/route.ts
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { BLOG_MODULE } from "../../modules/blog"
import BlogModuleService from "../../modules/blog/service"

// GET /admin/blog
export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const blogService = req.scope.resolve<BlogModuleService>(BLOG_MODULE)
  const posts = await blogService.listPosts({})
  res.json({ posts })
}

// POST /admin/blog
export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { result: post } = await createPostWorkflow(req.scope).run({
    input: req.body,
  })
  res.json({ post })
}
```

### Protected vs Public Routes

```typescript
// Middleware để protect routes
// src/api/middlewares.ts
import { defineMiddlewares, authenticate } from "@medusajs/framework/http"

export default defineMiddlewares({
  routes: [
    {
      matcher: "/admin/*",
      middlewares: [authenticate("admin", ["bearer", "session"])],
    },
    {
      matcher: "/store/*",
      middlewares: [authenticate("customer", ["bearer"], { allowUnregistered: true })],
    },
  ],
})
```

---

## 5. Events & Subscribers

### Event System

Medusa emit events khi commerce operations xảy ra (pub/sub pattern).

- **Dev**: Local Event Module (no setup)
- **Production**: Redis Event Module

### Tạo Subscriber

```typescript
// src/subscribers/order-placed.ts
import type {
  SubscriberArgs,
  SubscriberConfig,
} from "@medusajs/framework"
import { sendOrderConfirmationWorkflow } from "../workflows/send-order-confirmation"

// Subscriber function
export default async function orderPlacedHandler({
  event: { data },  // data = { id: "order_xxx" }
  container,
}: SubscriberArgs<{ id: string }>) {
  // Execute workflow to handle the event
  await sendOrderConfirmationWorkflow(container).run({
    input: { orderId: data.id },
  })
}

// Configuration
export const config: SubscriberConfig = {
  event: "order.placed",
  // Hoặc nhiều events:
  // event: ["order.placed", "order.updated"],
}
```

### Khi nào dùng Subscriber vs Workflow Hook?

| | Subscribers | Workflow Hooks |
|--|-------------|----------------|
| **Use case** | Non-integral actions (email, sync) | Integral to the main flow |
| **Timing** | Async, outside main flow | Synchronous, inside workflow |
| **Example** | Send confirmation email | Validate coupon before apply |
| **Impact on main flow** | None | Can fail/modify main flow |

---

## 6. Data Models (DML)

### Property Types

```typescript
const Product = model.define("product", {
  id: model.id().primaryKey(),          // UUID primary key
  title: model.text(),                   // Required string
  description: model.text().nullable(),  // Optional string
  handle: model.text().unique(),         // Unique constraint
  price: model.number(),                 // Number
  metadata: model.json().nullable(),     // JSON blob
  status: model.enum(["draft", "published"]), // Enum
  is_digital: model.boolean().default(false), // Boolean with default
  published_at: model.dateTime().nullable(),  // DateTime
})
```

### Relationships

```typescript
const Author = model.define("author", {
  id: model.id().primaryKey(),
  name: model.text(),
  posts: model.hasMany(() => Post), // One Author → Many Posts
})

const Post = model.define("post", {
  id: model.id().primaryKey(),
  title: model.text(),
  author: model.belongsTo(() => Author, { mappedBy: "posts" }),
  category: model.belongsTo(() => Category).nullable(),
})
```

---

## 7. Directory Structure

```
src/
├── api/                    ← REST API routes
│   ├── admin/              ← Admin-only endpoints
│   ├── store/              ← Storefront endpoints
│   └── middlewares.ts      ← Auth, CORS, validation
├── modules/                ← Custom modules
│   └── blog/
│       ├── models/
│       ├── migrations/
│       ├── service.ts
│       └── index.ts
├── workflows/              ← Durable workflows
│   └── create-post.ts
├── subscribers/            ← Event handlers
│   └── order-placed.ts
├── links/                  ← Module link definitions
│   └── blog-product.ts
├── jobs/                   ← Scheduled jobs
│   └── sync-catalog.ts
└── admin/                  ← Admin UI extensions
    ├── widgets/
    └── routes/
medusa-config.ts            ← Application config
```

---

## 8. Medusa vs Alternatives

| Aspect | Medusa | Shopify | WooCommerce | Commercetools |
|--------|--------|---------|-------------|---------------|
| License | MIT | Proprietary | GPL | Proprietary |
| Customization | Full | Limited | Medium | Full |
| Hosting | Self/Cloud | Shopify only | Self | Cloud only |
| Workflow engine | Built-in | None | None | None |
| Module system | Yes | App Store | Plugins | No |
| Cost | Free | $29-299+/mo | Free + hosting | $$$-$$$$|

---

## 9. Áp dụng cho Petshop Project

### Patterns học được từ Medusa

1. **Module Isolation** → Tổ chức services theo domain, không cross-import
2. **MedusaService pattern** → Có thể dùng `Prisma + Repository pattern` tương tự
3. **Workflow engine** → Dùng `bullmq + queue` cho distributed transactions
4. **Events/Subscribers** → Pattern tốt cho post-processing (email, sync)
5. **defineLink style** → Tránh direct FK giữa bounded contexts

### Khi nào apply vào dự án?

- **Nếu mở rộng commerce features**: Dùng Medusa thay build from scratch
- **B2B module** (thú y, wholesale): Medusa có sẵn B2B recipe
- **Multi-vendor/Marketplace**: Medusa hỗ trợ native
- **Event-driven notifications**: Copy subscriber pattern

---

## 10. Quick Reference — CLI Commands

```bash
# Setup
npx create-medusa-app@latest my-store

# Development
npx medusa dev

# Database
npx medusa db:generate <module-name>  # Generate migration
npx medusa db:migrate                  # Run migrations
npx medusa db:sync-links               # Sync link tables

# Plugin
npx medusa plugin:db:generate <module>

# Build
npx medusa build
```

---

## Resources

- **Docs**: https://docs.medusajs.com/
- **GitHub**: https://github.com/medusajs/medusa
- **Recipes**: https://docs.medusajs.com/resources/recipes
- **Workflows SDK Ref**: https://docs.medusajs.com/references/workflows-sdk
- **NotebookLM**: https://notebooklm.google.com/notebook/49d156d4-415f-4b2c-bc28-c9ea7ecd41b8
