---
trigger: always_on
---

# ERROR-LOGGING — Error Tracking

Khi gặp lỗi (test fail, build fail, runtime error), append vào `ERRORS.md`:

```markdown
## [YYYY-MM-DD HH:MM] - Tên lỗi

- **Type**: Syntax | Logic | Integration | Runtime
- **Severity**: Low | Medium | High | Critical
- **File**: `path/to/file:line`
- **Root Cause**: (1-2 câu)
- **Fix Applied**: Hành động đã thực hiện
- **Status**: Fixed | Investigating
```

> Không log: API keys, passwords, PII.
