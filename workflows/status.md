---
description: Dự án đang đến đâu rồi? Xem Dashboard báo cáo.
---

# /status - Show Status

$ARGUMENTS

---

## Task

Show current project and agent status.

### What It Shows

1. **Project Info**
   - Project name and path
   - Tech stack
   - Current features

2. **Agent Status Board**
   - Which agents are running
   - Which tasks are completed
   - Pending work

3. **File Statistics**
   - Files created count
   - Files modified count

4. **Preview Status**
   - Is server running
   - URL
   - Health check

---

## Example Output

```
=== Project Status ===

📁 Project: my-ecommerce
📂 Path: C:/projects/my-ecommerce
🏷️ Type: nextjs-ecommerce
📊 Status: active

🔧 Tech Stack:
   Framework: next.js
   Database: postgresql
   Auth: clerk
   Payment: stripe

✅ Features (5):
   • product-listing
   • cart
   • checkout
   • user-auth
   • order-history

⏳ Pending (2):
   • admin-panel
   • email-notifications

📄 Files: 73 created, 12 modified

=== Agent Status ===

✅ database-architect → Completed
✅ backend-specialist → Completed
🔄 frontend-specialist → Dashboard components (60%)
⏳ test-engineer → Waiting

=== Preview ===

🌐 URL: http://localhost:3000
💚 Health: OK
```

---

## Technical

Status uses these scripts:
- `python .agent/scripts/session_manager.py status`
- `python .agent/scripts/auto_preview.py status`

---

## 📦 Handoff Summary Protocol (MANDATORY after task completion)

When `/status` is called at the end of a development session or after completing a feature, **always append this structured summary**:

```
=== 📦 Handoff Summary ===

✅ What Was Built:
   • [Feature/endpoint 1]
   • [Feature/endpoint 2]
   • [Component/page 1]

🚀 How to Run:
   # Backend
   cd apps/backend && npm run dev

   # Frontend
   cd apps/frontend && npm run dev

   # Or from root (if turborepo)
   npm run dev

⚠️  What's Missing / Next Steps:
   • [Deferred item 1]
   • [Known limitation]
   • [Recommended improvement]

📁 Key Files:
   • apps/backend/src/[feature]/[file].ts — [what it does]
   • apps/frontend/src/pages/[Page].tsx — [what it does]
   • apps/frontend/src/components/[Component].tsx — [what it does]
```

> This summary must be provided even if no output scripts are available.
