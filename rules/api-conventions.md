---
trigger: glob
glob: "**/*.{controller,route,router}.ts"
---

# API-CONVENTIONS.MD - Chuẩn REST API

> **Mục tiêu**: Mọi API trong hệ thống đều trả về cùng 1 format. Frontend không cần đoán cấu trúc response.

---

## 📦 1. RESPONSE ENVELOPE (Bắt buộc)

**Mọi API response PHẢI wrap qua envelope này:**

```typescript
// ✅ Success Response
{
  "success": true,
  "data": <T>,           // Payload thực sự
  "meta": {              // Optional — cho pagination/list
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  },
  "message": "string"   // Optional — thông báo ngắn gọn
}

// ✅ Error Response
{
  "success": false,
  "error": {
    "code": "ORDER_NOT_FOUND",    // Mã lỗi snake_UPPER
    "message": "Order not found", // Mô tả cho developer
    "detail": "Order with id 'ord_123' does not exist",
    "field": "orderId"            // Optional — cho validation errors
  },
  "requestId": "req_abc123"       // Để trace log
}
```

**Helper function chuẩn:**
```typescript
// utils/response.utils.ts
export const ApiResponse = {
  success: <T>(data: T, message?: string, meta?: PaginationMeta) => ({
    success: true, data, message, meta,
  }),
  error: (code: string, message: string, detail?: string, field?: string) => ({
    success: false,
    error: { code, message, detail, field },
  }),
};

// Trong controller:
res.status(200).json(ApiResponse.success(order, 'Order retrieved'));
res.status(404).json(ApiResponse.error('ORDER_NOT_FOUND', 'Order not found'));
```

---

## 🛣️ 2. ENDPOINT NAMING (REST Standard)

**Format:** `/{version}/{resource}/{id?}/{sub-resource?}`

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `GET` | `/api/v1/orders` | Lấy danh sách |
| `GET` | `/api/v1/orders/:id` | Lấy chi tiết 1 item |
| `POST` | `/api/v1/orders` | Tạo mới |
| `PUT` | `/api/v1/orders/:id` | Cập nhật toàn bộ |
| `PATCH` | `/api/v1/orders/:id` | Cập nhật một phần |
| `DELETE` | `/api/v1/orders/:id` | Xoá |
| `GET` | `/api/v1/orders/:id/services` | Sub-resource |
| `POST` | `/api/v1/orders/:id/confirm` | Action verb |

```
✅ GET  /api/v1/pets
✅ POST /api/v1/pets/:petId/services
✅ PATCH /api/v1/orders/:id/status

❌ GET  /api/getPets        // động từ trong URL
❌ POST /api/v1/createOrder // action trong URL
❌ GET  /api/order          // số ít resource
❌ GET  /api/Orders         // PascalCase trong URL
```

---

## 🔢 3. HTTP STATUS CODES

**Chỉ dùng các status codes này:**

| Code | Khi nào dùng |
|------|-------------|
| `200 OK` | GET thành công, PUT/PATCH thành công |
| `201 Created` | POST tạo mới thành công |
| `204 No Content` | DELETE thành công (không cần trả data) |
| `400 Bad Request` | Input không hợp lệ (validation fail) |
| `401 Unauthorized` | Chưa đăng nhập / token hết hạn |
| `403 Forbidden` | Đã đăng nhập nhưng không có quyền |
| `404 Not Found` | Resource không tồn tại |
| `409 Conflict` | Conflict (đặt trùng, duplicate) |
| `422 Unprocessable Entity` | Business logic validation fail |
| `429 Too Many Requests` | Rate limit exceeded |
| `500 Internal Server Error` | Lỗi không mong đợi của server |
| `503 Service Unavailable` | DB/Service chết, không thể phục vụ |

```
❌ KHÔNG dùng 200 cho mọi thứ (kể cả lỗi)
❌ KHÔNG trả về 500 cho lỗi validation của user
❌ KHÔNG dùng 400 cho "không tìm thấy" (phải là 404)
```

---

## 📄 4. PAGINATION

**Query params chuẩn:**
```
GET /api/v1/orders?page=1&limit=20&sortBy=createdAt&sortOrder=desc
```

| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `page` | number | 1 | Trang hiện tại |
| `limit` | number | 20 | Số item/trang (max: 100) |
| `sortBy` | string | `createdAt` | Cột sort |
| `sortOrder` | `asc\|desc` | `desc` | Chiều sort |
| `search` | string | — | Full-text search |

**Response meta chuẩn:**
```typescript
{
  "meta": {
    "total": 150,       // Tổng số records
    "page": 1,          // Trang hiện tại
    "limit": 20,        // Số item/trang
    "totalPages": 8     // Tổng số trang
  }
}
```

---

## ❌ 5. ERROR CODES (Chuẩn hoá)

**Format:** `{ENTITY}_{VERB}` — ALL_CAPS_SNAKE

```typescript
// Auth
UNAUTHORIZED            // Token thiếu/invalid
TOKEN_EXPIRED           // Token hết hạn
FORBIDDEN               // Không đủ quyền

// Resource
ORDER_NOT_FOUND
PET_NOT_FOUND
SERVICE_NOT_FOUND

// Validation
VALIDATION_ERROR        // Lỗi input validation
DUPLICATE_ENTRY         // Đã tồn tại
INVALID_STATUS          // Trạng thái không hợp lệ

// Business Logic
ORDER_ALREADY_PAID
PET_SERVICE_UNAVAILABLE
HOTEL_ROOM_FULL
INSUFFICIENT_STOCK

// System
INTERNAL_SERVER_ERROR
SERVICE_UNAVAILABLE
RATE_LIMIT_EXCEEDED
```

---

## 🔒 6. SECURITY HEADERS (Bắt buộc)

```typescript
// Cấu hình Helmet middleware
app.use(helmet({
  contentSecurityPolicy: true,
  hsts: { maxAge: 31536000 },
  xFrameOptions: { action: 'deny' },
}));

// CORS — explicit origins, KHÔNG dùng wildcard production
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') ?? [],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
}));
```

---

## 📌 7. QUERY PARAMS vs PATH PARAMS

```
✅ Path param — Khi identify 1 resource cụ thể
   GET /api/v1/orders/:orderId

✅ Query param — Khi filter, search, paginate
   GET /api/v1/orders?status=PENDING&branchId=brn_001

✅ Request body — Khi POST/PUT/PATCH data
   POST /api/v1/orders { petId, services, note }

❌ KHÔNG dùng body trong GET request
❌ KHÔNG đặt sensitive data (token, password) vào URL
```

---

> **Tuân thủ rule này = Frontend và Backend có thể làm việc độc lập mà không cần hỏi nhau về response format.**
