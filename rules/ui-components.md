---
trigger: glob
glob: "**/*.{tsx,jsx}"
---

# UI-COMPONENTS.MD — Quy tắc Module hóa Giao diện

> **Mục tiêu**: Ngăn chặn trùng lặp UI. Mọi dialog, alert, confirm phải dùng module chung theo đúng theme app.

---

## 🚫 1. CẤM

1. **`window.confirm()`** — Cấm tuyệt đối. Dùng `ConfirmDialog` thay thế.
2. **`window.alert()`** — Cấm. Dùng `AlertDialog` thay thế.
3. **Copy-paste modal** — Nếu 2+ trang có cùng UI pattern → PHẢI tạo shared component.

---

## 📦 2. MODULE UI DÙNG CHUNG (tại `components/ui/`)

| Component | Dùng khi | Props chính |
|-----------|---------|------------|
| `ConfirmDialog` | Xóa, hành động không thể hoàn tác | `title`, `message`, `variant`, `onConfirm`, `onCancel` |
| `AlertDialog` | Thông báo kết quả sau hành động | `type` (success/error/warning/info), `title`, `message` |
| `ChoiceDialog` | Lựa chọn giữa nhiều phương án | `title`, `options[]`, `onSelect` |
| `DetailPage` | Trang chi tiết đầy đủ (full page) | `breadcrumbs`, `avatar`, `title`, `infoFields`, `actions` |
| `DetailModal` | Cửa sổ tạo/sửa trung tâm | `title`, `size` (sm/md/lg/xl), `footer`, `isLoading` + `.Section` |
| `DetailPanel` | Panel trượt từ phải | `title`, `subtitle`, `width`, `footer` + `.Avatar`, `.Field`, `.Group` |
| `DataTable` | Mọi bảng dữ liệu | `columns`, `data`, `pagination` |
| `DataTableToolbar` | Toolbar trên bảng | `search`, `filters`, `columnConfig` |
| `FormModal` | Form tạo/sửa đơn giản (legacy) | `title`, `onClose`, `onSubmit` |

---

## 🔧 3. KHI NÀO TẠO MODULE MỚI

Tạo shared component khi:
- Cùng UI xuất hiện ở **2+ trang** khác nhau
- Component có **state nội bộ** (loading, validation)
- Cần **nhất quán** về animation, spacing, màu sắc theo theme

**Quy trình:**
1. Tạo file trong `apps/frontend/src/components/ui/`
2. Dùng **CSS vars** của app (`--p500`, `--surface`, `--text-primary`)
3. Hỗ trợ **dark mode** tự động (app đang dark-first)
4. Export named export: `export function ConfirmDialog(...)`

---

## 🎨 4. THEME — CSS VARS TO KNOW

> Customize these for your project's design system:

```css
/* Primary colors — store as RGB values for rgba() support */
--p50 to --p900   /* Primary palette: rgb(var(--p500)) */

/* Surface */
--surface-1       /* Card backgrounds */
--surface-2       /* Modal backdrop */

/* Text */
--text-primary    /* Main text color */
--text-secondary  /* Secondary/placeholder text */

/* Status (customize RGB values for your palette) */
--success: [R G B];   /* Green family */
--warning: [R G B];   /* Yellow/Amber family */
--error:   [R G B];   /* Red family */
--info:    [R G B];   /* Blue/Indigo family */
```

> See your project's CSS theme file (`index.css` / `globals.css`) for actual values.


---

## ✅ 5. CHECKLIST TRƯỚC KHI VIẾT UI MỚI

- [ ] Trang này có pattern giống trang nào không?
- [ ] Đã import `ConfirmDialog` chưa hay đang dùng `window.confirm`?
- [ ] Dialog/Modal có đang dùng inline styles thay vì CSS vars không?
- [ ] Component có thể tái sử dụng ở trang khác không?
