---
name: search-first
description: >
  Research-before-coding workflow. Buộc AI phải đọc và hiểu codebase TRƯỚC khi
  viết code. Kích hoạt khi bắt đầu bất kỳ task nào có thể ảnh hưởng đến code hiện có.
  Ngăn AI "đoán mò" mà không hiểu context đầy đủ.
---

# Search First — Research Before Coding

## Nguyên Tắc Cốt Lõi

> **Không được viết một dòng code nào trước khi đọc xong context liên quan.**

Đây là skill quan trọng nhất để tránh:
- Fix bug nhưng tạo 2 bug mới
- Implement feature trùng lặp với code đã có
- Dùng wrong pattern so với codebase hiện tại
- Hiểu sai business logic

## Quy Trình Bắt Buộc

### Phase 1: Đọc Ngay Lập Tức (Bắt buộc, không skip)

Khi nhận task, PHẢI đọc theo thứ tự:

1. **File chính liên quan** — File được nhắc đến trong task
2. **Dependencies của file đó** — Imports ở đầu file
3. **Types/Interfaces** — Dùng để hiểu data shape
4. **Related hooks/utils** — Nếu có

```
KHÔNG được: "Tôi sẽ thêm feature X vào file Y"
PHẢI làm: Đọc file Y → Đọc imports của Y → Hiểu pattern hiện tại → Sau đó propose
```

### Phase 2: Tìm Existing Patterns

Trước khi viết code mới, tìm xem đã có code tương tự chưa:

```bash
# Tìm pattern tương tự
grep -r "paymentStatus" apps/ --include="*.ts" --include="*.tsx" -l
grep -r "useCallback\|useMemo" apps/frontend/src/hooks/ -l

# Tìm existing utilities
find apps/ -name "*.utils.ts" -o -name "*.helpers.ts"
```

### Phase 3: Kiểm Tra Git History (Nếu Task Liên Quan Đến Bug)

```bash
# Xem commits gần nhất liên quan
git log --oneline -20 -- apps/frontend/src/pages/NewOrderPage.tsx

# Xem thay đổi cụ thể
git show HEAD~1 -- apps/backend/src/services/order.service.ts
```

### Phase 4: Map Dependencies

Trước khi sửa hàm/component, hiểu ai đang dùng nó:

```bash
# Ai import/dùng hook này? (thay useMyHook bằng tên thực)
grep -r "useMyHook" src/ --include="*.tsx" --include="*.ts"

# Ai gọi API endpoint này? (thay /my-endpoint bằng route thực)
grep -r "myFunction\|/my-endpoint" src/ --include="*.ts"
```

## Generic Search Patterns

### Khi liên quan đến state/business logic
```bash
# Tìm field/state đang dùng trong codebase
grep -r "myField\|myStatus" src/ --include="*.tsx" --include="*.ts"

# Tìm hook được dùng ở đâu
grep -r "useMyFeature" src/ -l
```

### Khi liên quan đến API routes
```bash
# Tìm route definitions
grep -rE "(get|post|put|patch|delete)\(" src/ --include="*.ts" | grep "router"

# Tìm ORM/DB queries
grep -r "findMany\|findUnique\|create\|update" src/ --include="*.ts" -l
```

### Khi liên quan đến UI Components
```bash
# Liệt kê components
find src/components/ -name "*.tsx" | head -20

# Ai dùng component này?
grep -r "import.*MyComponent" src/ -l
```

> 💡 **Tip**: Thay `src/` bằng đúng folder của project (ví dụ `apps/frontend/src/`, `lib/`, `app/`).

## Checklist Trước Khi Code

```
□ Đã đọc file chính cần sửa?
□ Đã đọc ít nhất 3 dependencies chính của nó?
□ Đã tìm existing pattern tương tự trong codebase?
□ Đã hiểu data flow (frontend → API → service → DB)?
□ Nếu là bug: đã tìm root cause, không chỉ symptom?
□ Đã check ai else đang dùng code sẽ bị sửa?
```

## Red Flags — Dừng Lại Nếu

- Chưa đọc file cần sửa nhưng đã gợi ý code
- Task liên quan business logic nhưng chưa đọc core hook/service chính
- Sửa API nhưng chưa check frontend đang gọi gì
- Thêm DB field nhưng chưa đọc schema/model hiện tại
