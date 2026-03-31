---
description: Kiểm tra và chẩn đoán kết nối Frontend ↔ Backend. Dùng khi nghi ngờ mất kết nối, sau khi sửa config, hoặc trước khi deploy.
---

# /check-connections Workflow

## Khi nào dùng
- Sau khi sửa `vite.config.ts`, `api.ts`, `.env`, hoặc `routes/index.ts`
- Khi frontend không load được data (dashboard trắng)
- Trước khi commit code liên quan đến kết nối

## Các bước thực hiện

// turbo-all

### Bước 1: Chạy health check tự động
```bash
cd c:\Dev\Petshop_Service_Management && node scripts/check-connections.js
```

### Bước 2: Phân tích kết quả

Đọc output và phân loại:

| Output | Ý nghĩa | Hành động |
|--------|---------|-----------|
| `✅ PASS` | Mọi thứ bình thường | Tiếp tục |
| `⚠️ WARN` | Cảnh báo không chặn | Xem xét sửa |
| `❌ FAIL` | Lỗi nghiêm trọng | Fix ngay, xem Bước 3 |

### Bước 3: Nếu có FAIL — Fix theo loại lỗi

**FAIL ".env file exists"**
```bash
# Copy từ example
cp .env.example .env
# Điền các giá trị đúng vào .env
```

**FAIL "Proxy target matches .env PORT"**
- Mở `apps/frontend/vite.config.ts`
- Sửa `target: 'http://localhost:XXXX'` → đúng port trong `.env PORT`

**FAIL "baseURL = /api"**
- Mở `apps/frontend/src/lib/api.ts`
- Đảm bảo `baseURL: '/api'` (không có gì khác)

**FAIL "All routes registered"**
- Mở `apps/backend/src/routes/index.ts`
- Kiểm tra route bị thiếu, so sánh với `CONNECTION_MAP.md`

### Bước 4: Chạy lại để verify fix

```bash
cd c:\Dev\Petshop_Service_Management && node scripts/check-connections.js
```

Chỉ khi tất cả `✅ PASS` mới được commit và tiếp tục.

### Bước 5 (Optional): Test thủ công

Nếu muốn xác nhận thêm:
```bash
# Ping trực tiếp backend
curl http://localhost:3000/api/health
```
```
Expected: {"success":true,"message":"🐾 Petshop API is healthy!","timestamp":"..."}
```

## Tài liệu liên quan
- `CONNECTION_MAP.md` — Sơ đồ toàn bộ kết nối
- `ERRORS.md` — Log lỗi đã từng xảy ra
- `.agent/skills/connection-health-check/SKILL.md` — Skill hướng dẫn sửa DANGER FILES
