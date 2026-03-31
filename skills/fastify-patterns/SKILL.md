---
name: fastify-patterns
description: >
  Fastify v5 patterns for high-performance Node.js APIs. Plugin system, Hooks, Decorators, 
  Encapsulation (DAG), JSON Schema validation/serialization, and production-ready patterns.
  Use when building or reviewing Fastify-based backends.
---

# Fastify Patterns — Production Guide

## Core Philosophy

Fastify được xây dựng trên 5 trụ cột:
1. **Plugin System** — Everything is a plugin, mọi thứ đều có thể encapsulate
2. **Decorators** — Mở rộng server/request/reply (V8-optimized)
3. **Hooks** — Intercept lifecycle tại các điểm cụ thể
4. **JSON Schema** — Validation + fast serialization
5. **Encapsulation (DAG)** — Scope isolation, không cross-contamination

---

## Request Lifecycle (Phải thuộc lòng)

```
Incoming Request → Routing → Instance Logger
    → onRequest       (auth, rate limit; body = undefined)
    → preParsing       (transform stream)
    → Parsing
    → preValidation    (modify body before validate)
    → Validation       (JSON Schema; 400 on fail)
    → preHandler       (prep before handler)
    → User Handler
    → preSerialization (wrap response)
    → onSend           (modify serialized payload)
    → Outgoing Response
    → onResponse       (logging, analytics)
```

---

## Pattern: Plugin Structure

```
src/
├── app.js
├── plugins/
│   ├── database.js   ← fp() wrapped → global scope
│   ├── auth.js       ← fp() wrapped → global scope
│   └── cors.js       ← fp() wrapped → global scope
└── routes/
    ├── users/index.js    ← NOT fp() → encapsulated
    └── products/index.js ← NOT fp() → encapsulated
```

**Rule**: Plugins muốn share globally → dùng `fastify-plugin (fp)`.  
Routes thì KHÔNG cần fp — scope isolation là feature, không phải bug.

---

## Pattern: Database Plugin

```js
const fp = require('fastify-plugin')
const { Pool } = require('pg')

async function databasePlugin(fastify, opts) {
  const pool = new Pool({ connectionString: opts.connectionString })

  fastify.decorate('db', {
    query: (text, params) => pool.query(text, params),
    transaction: async (fn) => {
      const client = await pool.connect()
      try {
        await client.query('BEGIN')
        const result = await fn(client)
        await client.query('COMMIT')
        return result
      } catch (err) {
        await client.query('ROLLBACK')
        throw err
      } finally {
        client.release()
      }
    }
  })

  fastify.addHook('onClose', async () => {
    await pool.end()
  })
}

module.exports = fp(databasePlugin, {
  name: 'database',
  fastify: '>=4'
})
```

---

## Pattern: Auth Plugin + Prehandler

```js
const fp = require('fastify-plugin')

async function authPlugin(fastify, opts) {
  // Declare shape TRƯỚC cho V8 optimization
  fastify.decorateRequest('user', null)

  // Expose authenticate function as preHandler
  fastify.decorate('authenticate', async function authenticate(request, reply) {
    const auth = request.headers.authorization
    if (!auth?.startsWith('Bearer ')) {
      return reply.code(401).send({ error: 'Unauthorized' })
    }
    const token = auth.replace('Bearer ', '')
    try {
      request.user = await fastify.jwt.verify(token)
    } catch {
      return reply.code(401).send({ error: 'Invalid token' })
    }
  })
}

module.exports = fp(authPlugin, {
  name: 'auth',
  dependencies: ['@fastify/jwt']
})

// Sử dụng trong routes:
fastify.get('/profile', {
  preHandler: [fastify.authenticate]
}, async (request, reply) => {
  return request.user // đã được set bởi authenticate
})
```

---

## Pattern: Route Schema (Validation + Serialization)

```js
const getUserSchema = {
  params: {
    type: 'object',
    properties: { id: { type: 'string' } },
    required: ['id']
  },
  response: {
    200: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string' },
        email: { type: 'string' }
        // password KHÔNG có đây → bị omit khỏi response (security!)
      }
    },
    404: {
      type: 'object',
      properties: {
        error: { type: 'string' }
      }
    }
  }
}

fastify.get('/users/:id', { schema: getUserSchema }, async (request, reply) => {
  const user = await fastify.db.query('SELECT * FROM users WHERE id = $1', [request.params.id])
  if (!user.rows[0]) return reply.code(404).send({ error: 'Not found' })
  return user.rows[0]
})
```

---

## Pattern: Error Handler

```js
fastify.setErrorHandler(function(error, request, reply) {
  // Validation errors từ JSON Schema
  if (error.statusCode === 400 && error.validation) {
    return reply.code(400).send({
      error: 'Validation Error',
      details: error.validation
    })
  }

  // Client errors (4xx)
  if (error.statusCode >= 400 && error.statusCode < 500) {
    return reply.code(error.statusCode).send({
      error: error.message,
      statusCode: error.statusCode
    })
  }

  // Server errors
  this.log.error({ err: error }, 'Unhandled error')
  reply.code(500).send({
    error: 'Internal Server Error',
    statusCode: 500
  })
})
```

---

## Decorator Rules (Quan trọng!)

```js
// ✅ Value types → OK
fastify.decorateRequest('userId', '')
fastify.decorateRequest('isAdmin', false)

// ❌ Reference types → Block! (shared across requests = security risk)
fastify.decorateRequest('user', { name: '' }) // THROWS ERROR

// ✅ Reference types → dùng null + onRequest hook
fastify.decorateRequest('user', null)
fastify.addHook('onRequest', async (req) => {
  req.user = { name: 'from DB' } // fresh cho mỗi request
})

// ✅ Getter/setter pattern
fastify.decorateRequest('_holder')
fastify.decorateRequest('ctx', {
  getter() {
    this._holder ??= {}
    return this._holder
  }
})
```

---

## Hook Scope — Encapsulation aware

```js
// Hooks chỉ áp dụng trong scope hiện tại và con của nó
fastify.register(async function adminRoutes(fastify, opts) {
  // Hook này CHỈ áp dụng cho routes trong adminRoutes
  fastify.addHook('preHandler', fastify.authenticate)
  
  fastify.get('/users', listUsersHandler)
  fastify.delete('/users/:id', deleteUserHandler)
})

// Các routes ngoài adminRoutes KHÔNG bị ảnh hưởng bởi hook trên
fastify.get('/health', (req, reply) => reply.send({ ok: true }))
```

---

## Checklist cho Fastify Project

- [ ] Tất cả shared plugins dùng `fastify-plugin`
- [ ] Decorators dùng reference type → init với `null`, set trong hook
- [ ] Response schema có cho tất cả routes quan trọng
- [ ] Error handler tập trung dùng `setErrorHandler`
- [ ] Graceful shutdown có `addHook('onClose', ...)`
- [ ] Không dùng arrow function trong route handlers (breaks `this`)
- [ ] Database/Redis cleanup trong `onClose` hook
- [ ] Logger configured với Pino serializers

---

## So sánh nhanh

| Express | Fastify |
|---------|---------|
| `app.use(middleware)` | `addHook('onRequest', ...)` |
| `app.use('/api', router)` | `register(routes, { prefix: '/api' })` |
| Manual `try/catch` | `setErrorHandler` centralized |
| No built-in schema | JSON Schema built-in |
| `JSON.stringify` slow | `fast-json-stringify` compiled |

## Resources
- https://fastify.dev/docs/latest/
- https://github.com/fastify/fastify
- https://github.com/fastify/fastify-plugin
- https://github.com/fastify/example
