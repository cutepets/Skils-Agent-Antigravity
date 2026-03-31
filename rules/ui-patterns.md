---
trigger: glob
glob: "**/*.{tsx,jsx}"
---



## 1. Quy tắc khi nào dùng Modal chồng vs Inline Edit

| Số trường cần nhập | Phương pháp |
|---|---|
| **1 trường** | **Inline edit** — hiện input ngay trong hàng của bảng/card |
| **2+ trường** | **Modal phụ chồng lên** — hiện cửa sổ riêng dùng `createPortal` |

---

## 2. Pattern: Modal chồng lên Modal (Nested Modal via Portal)

Dùng khi cần form thêm/sửa nhiều trường xuất hiện trên một modal đang mở.

### Code mẫu

```tsx
import { createPortal } from 'react-dom'

function NestedFormModal({ open, form, setForm, onSave, onClose, saving }: {
  open: boolean; form: any; setForm: (f: any) => void;
  onSave: () => void; onClose: () => void; saving: boolean;
}) {
  if (!open) return null
  return createPortal(
    <div
      className="fixed inset-0 z-[230] flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-150"
      onClick={onClose}  // bấm ngoài để đóng
    >
      <div
        className="w-full max-w-lg bg-background rounded-2xl shadow-2xl border border-border animate-in zoom-in-95 duration-150 overflow-hidden"
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-5 py-3 border-b border-border bg-background-secondary">
          <h3 className="font-bold text-sm">Tiêu đề</h3>
          <button onClick={onClose}><X size={15} /></button>
        </div>

        {/* Body - form fields */}
        <div className="p-5 space-y-4">
          {/* ... các trường input ... */}
        </div>

        {/* Footer */}
        <div className="flex gap-2 px-5 py-3 border-t border-border bg-background-secondary">
          <button onClick={onSave} disabled={saving}>Lưu</button>
          <button onClick={onClose}>Hủy</button>
        </div>
      </div>
    </div>,
    document.body   // render ngoài DOM tree → luôn nằm trên mọi thứ
  )
}
```

### Lưu ý z-index

| Layer | z-index |
|---|---|
| Modal chính (hồ sơ pet, etc.) | `z-[200]` |
| Modal phụ (form thêm/sửa) | `z-[230]` |
| Dropdown / tooltip | `z-[250]` |

---

## 3. Pattern: Inline Edit (1 trường)

Dùng cho trường đơn như cân nặng, tên gắn thẻ, ghi chú ngắn.

```tsx
{isEditing ? (
  <input
    className="form-input text-xs h-7 w-24"
    value={val}
    onChange={e => setVal(e.target.value)}
    onBlur={save}
    onKeyDown={e => e.key === 'Enter' && save()}
    autoFocus
  />
) : (
  <span className="cursor-pointer hover:text-blue-400" onClick={() => setIsEditing(true)}>
    {displayValue}
  </span>
)}
```

---

*Tham khảo triển khai thực tế: `POSPetDetailModal.tsx` → `VaccineFormModal`*
