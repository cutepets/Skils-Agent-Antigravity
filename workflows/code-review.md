---
description: Review code chuyên sâu theo 3 góc nhìn: kiến trúc, bảo mật, testability. Dùng khi muốn kiểm tra chất lượng trước khi merge/deploy.
---

# /code-review — Multi-Angle Code Review

## Mục tiêu
$ARGUMENTS

---

## 🔴 PROTOCOL: DRAFT TRƯỚC, WRITE SAU

Đây là lệnh phân tích. Agent KHÔNG được sửa bất kỳ file nào tự động.
Mọi đề xuất phải được trình bày dưới dạng **report** và chờ người dùng quyết định.

---

## Bước 1: Xác định target

Nếu `$ARGUMENTS` có tên file/thư mục → review file/thư mục đó.
Nếu không có → hỏi: "Em cần review file nào? (VD: `src/api/auth.ts`, `apps/backend/src/routes/`)"

---

## Bước 2: Impact Analysis (trước khi review)

Trước khi phân tích, chạy:

```
gitnexus_context({name: "<tên function/class chính trong file>"})
```

→ Xem file này có bao nhiêu nơi phụ thuộc vào để biết mức độ quan trọng của nó.

---

## Bước 3: Ba góc review song song

### 🏗️ Góc 1 — Lead Programmer (Architecture)
Phân tích:
- **Separation of Concerns**: Logic có bị trộn lẫn không? (business logic trong controller, UI logic trong service...)
- **DRY & Reusability**: Có code trùng lặp không? Có thể extract ra không?
- **Naming**: Tên biến/hàm/file có rõ ràng, đúng convention không?
- **Error Handling**: Có handle edge cases không? Có `try/catch` đúng chỗ không?
- **Pattern compliance**: Có tuân theo patterns chuẩn của project không? (Đọc `START_HERE.md` để biết pattern)
- **Complexity**: Hàm nào quá phức tạp (>30 lines, >3 levels nesting)?

### 🔒 Góc 2 — Security Engineer (Security)
Phân tích:
- **Input validation**: Input từ user/API có được validate không?
- **SQL Injection**: Có dùng raw query với string concat không?
- **XSS**: Có render HTML từ user input không?
- **Authentication**: Endpoint có check auth/role đúng không?
- **Secrets**: Có hardcode key/token/password không?
- **Data exposure**: Response có trả về field nhạy cảm không cần thiết không?
- **Rate limiting**: Endpoint có bị thiếu rate limit không?

### 🧪 Góc 3 — QA Engineer (Testability)
Phân tích:
- **Testability**: Hàm có quá nhiều dependencies để mock không?
- **Side effects**: Có side effects ẩn khó test không?
- **Edge cases**: Liệt kê các case cần test (null, empty, boundary values)
- **Test coverage gợi ý**: Viết outline test cases (không viết code test ngay)
- **Mocking complexity**: Dependencies có quá phức tạp để isolated test không?

---

## Bước 4: Tổng hợp Report

```markdown
## 📋 Code Review Report

**File:** `[path/to/file]`
**Reviewer:** Lead Programmer + Security Engineer + QA Engineer
**Thời điểm:** [timestamp]
**Impact:** [Số nơi phụ thuộc từ GitNexus]

---

### 🏗️ Architecture

| Issue | Mức độ | Vị trí | Đề xuất |
|-------|--------|--------|---------|
| [Tên issue] | 🔴 Critical / 🟡 Warning / 🟢 Info | Line X | [Hành động cụ thể] |

**Điểm tốt:** [Những thứ đã làm đúng]

---

### 🔒 Security

| Issue | Mức độ | Vị trí | Đề xuất |
|-------|--------|--------|---------|
| [Tên issue] | 🔴 Critical / 🟡 Warning / 🟢 Info | Line X | [Hành động cụ thể] |

---

### 🧪 Testability

**Test cases cần có:**
- [ ] [Case 1]
- [ ] [Case 2]
- [ ] [Case 3]

**Khó test vì:** [Lý do nếu có]

---

### 📊 Tổng điểm

| Tiêu chí | Điểm | Ghi chú |
|----------|------|---------|
| Architecture | X/10 | |
| Security | X/10 | |
| Testability | X/10 | |
| **Tổng** | **X/10** | |

---

### 🎯 Ưu tiên hành động

1. 🔴 **[Vấn đề nghiêm trọng nhất]** — Phải sửa trước khi merge
2. 🟡 **[Vấn đề quan trọng]** — Nên sửa trong sprint này
3. 🟢 **[Cải tiến]** — Backlog, làm khi có thời gian

---

**Anh muốn em sửa mục nào trước không?**
```

---

## Quy tắc bắt buộc

- ✅ Chỉ phân tích, KHÔNG tự sửa file
- ✅ Luôn chỉ rõ line number khi báo cáo issue
- ✅ Đề xuất cụ thể, không chung chung
- ✅ Đọc `docs/technical/DECISIONS.md` để biết ADR trước khi đánh giá kiến trúc
- ✅ Đọc `START_HERE.md` để biết pattern chuẩn của project
