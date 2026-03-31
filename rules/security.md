---
trigger: conditional
description: "Khi phát hiện lỗ hổng bảo mật nghiêm trọng hoặc nghi ngờ lộ secret - xem GEMINI.md cho guardrails tóm tắt"
---

# SECURITY — Chi tiết đầy đủ (tham khảo khi cần)

## Coding Standards
- SQL: Parameterized Queries / ORM (Prisma/TypeORM). Cấm nối chuỗi trực tiếp.
- XSS: Sanitize input. `dompurify` khi render HTML.
- Auth: Hash password bằng Bcrypt/Argon2.
- CORS: Explicit origins, không dùng wildcard production.
- Headers: Dùng `helmet` middleware.

## Incident Protocol
1. DỪNG mọi tác vụ
2. BÁO CÁO ngay với RED ALERT
3. Đề xuất key rotation hoặc vá lỗi
