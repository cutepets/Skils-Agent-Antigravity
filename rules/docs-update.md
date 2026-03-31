---
trigger: conditional
description: "Khi user thêm skill mới, tạo workflow mới, thêm rule mới, hoặc thêm agent mới vào hệ thống"
---

# DOCS-UPDATE — Documentation Sync

Khi thêm mới bất kỳ thành phần nào, cập nhật:

| Thêm | Files cần update |
|------|-----------------|
| **Skill** | `SKILLS.md`, `docs/SKILLS_GUIDE.vi.md`, `README.md`, `README.vi.md` |
| **Workflow** | `docs/WORKFLOW_GUIDE.vi.md`, `README.md`, `README.vi.md` |
| **Rule** | `docs/RULES_GUIDE.vi.md`, `README.vi.md` |
| **Agent** | `docs/AGENTS_GUIDE.vi.md`, `README.vi.md` |

Sau khi cập nhật: `node .agent/scripts/update-docs.js` → commit riêng cho docs.
