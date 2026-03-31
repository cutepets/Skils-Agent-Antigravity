---
trigger: always_on
---

# FILE-SAFETY — Quy tắc an toàn khi sửa file source

## BẮTBUỘC: Luôn dùng UTF-8 khi đọc/ghi file

**Lý do:** Windows dùng encoding mặc định CP1252. Khi đọc/ghi file tiếng Việt mà không chỉ định UTF-8, các ký tự Vietnamese sẽ bị **mojibake** — ví dụ: `San Pham` bị ghi thành chuỗi rác `Sáº£n Pháº©m`. Lỗi này xảy ra âm thầm, file vẫn hợp lệ binary nhưng hiển thị sai trên browser.

**Bài học thực tế:** File `InventoryPage.tsx` đã bị mojibake khi restore từ git stash trên Windows — mất 1 giờ debug.

### Quy tắc bắt buộc:

| Môi trường | Doc file | Ghi file |
|---|---|---|
| PowerShell | `Get-Content file -Encoding UTF8` | `Set-Content file -Encoding UTF8` |
| Node.js | `fs.readFileSync(path, 'utf8')` | `fs.writeFileSync(path, content, 'utf8')` |
| Python | `open(path, 'r', encoding='utf-8')` | `open(path, 'w', encoding='utf-8')` |
| Git stash | Luôn verify encoding sau `git stash apply` với file tiếng Việt | |

### TUYET DOI KHONG:

```powershell
# CẤM - dùng encoding mặc định của Windows (CP1252)
Get-Content file                           # thiếu -Encoding UTF8
[IO.File]::ReadAllText($path)              # dùng OS default
[IO.File]::WriteAllText($path, $content)   # dùng OS default
```

```python
# CẤM
open(path, 'r')    # thiếu encoding='utf-8'
```

```javascript
// CẤM  
fs.readFileSync(path)           // trả về Buffer chưa decode
fs.readFileSync(path, 'latin1') // sai encoding
```

### Kiểm tra nhanh sau khi apply stash hay restore file:

```powershell
# Tìm dấu hiệu mojibake trong tất cả TSX/TS files
Select-String -Path "apps/frontend/src/**/*.tsx" -Pattern "áº|Ã " -Encoding UTF8
# Có kết quả = file bị lỗi encoding!
```

### Dấu hiệu nhận biết mojibake:
- `Sáº£n` thay vì `Sản`  
- `Ã­` thay vì `í`
- `Ä'` thay vì `đ`
- `ðŸ"¦` thay vì `📦` (emoji vỡ)

---


## ⚠️ KHÔNG DÙNG WriteAllLines trực tiếp trên file source

**Lý do:** `[System.IO.File]::WriteAllLines` trên Windows sẽ:
1. Convert tất cả line endings CRLF → LF (hoặc ngược lại)
2. Gây ra "diff khổng lồ" làm git nghĩ toàn bộ file bị sửa
3. Trong trường hợp xấu: file trở thành 1 dòng duy nhất

### Thay thế an toàn:

| Mục đích | Dùng |
|----------|------|
| Format code | `npx prettier --write <file>` |
| Thay thế chuỗi | `(Get-Content file) -replace 'old','new' \| Set-Content file -Encoding UTF8` |
| Ghi file mới | `Set-Content -Path file -Value $content -Encoding UTF8` |
| Transform lớn | `npx ts-node scripts/transform.ts` với proper encoding |

### TUYỆT ĐỐI KHÔNG:
```powershell
# ❌ CẤM - sẽ phá line endings
[System.IO.File]::WriteAllLines($path, $lines)
[System.IO.File]::WriteAllText($path, $content)
```

---

## 🔒 Bắt buộc: Tạo snapshot trước khi chạy script

**Trước khi chạy BẤT KỲ script nào có thể sửa file source (>200 dòng), PHẢI:**

```powershell
# Cách 1: Dùng safe-run wrapper (khuyên dùng)
pwsh scripts/safe-run.ps1 <command>

# Cách 2: Tạo thủ công
git add -A
git stash push -m "snapshot-truoc-script-$(Get-Date -Format 'yyyyMMdd-HHmm')"
```

**Hoặc commit trước:**
```powershell
git add -A
git commit -m "chore: snapshot before running script"
```

### Lệnh rollback khẩn cấp:
```powershell
# Lấy lại snapshot gần nhất
git stash pop

# Hoặc xem danh sách snapshots
git stash list

# Rollback về commit cụ thể
git checkout HEAD -- <file>
```

---

## 📁 Danh sách DANGER FILES (cần đặc biệt cẩn thận)

Các file này rất lớn và quan trọng — LUÔN snapshot trước khi sửa bằng script:

- `apps/frontend/src/pages/NewOrderPage.tsx` (2052+ dòng)
- `apps/frontend/src/pages/InventoryPage.tsx` (2000+ dòng) — **từng bị mojibake, cần theo dõi**
- `apps/frontend/src/hooks/usePOSOrder.ts`
- `apps/backend/src/routes/*.routes.ts`
- `apps/backend/prisma/schema.prisma`

