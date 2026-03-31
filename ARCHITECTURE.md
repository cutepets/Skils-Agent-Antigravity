# Kiến trúc Hệ thống .agent

> Bộ công cụ điều phối AI Agent cho dự án Petshop Service Management.

---

## 🏗️ Cấu trúc thư mục

```
.agent/
├── START_HERE.md        # Điểm vào — Quick start & pattern chuẩn
├── ARCHITECTURE.md      # File này — Tổng quan hệ thống
├── GEMINI.md            # Config IDE (identity, language protocol)
├── rules/               # Quy tắc tự động kích hoạt theo trigger
├── skills/              # Bộ kỹ năng chuyên sâu (load khi cần)
├── workflows/           # Slash commands (/create, /debug, ...)
└── scripts/             # Script kiểm tra tự động
```

---

## 🔄 Quy trình làm việc (PDCA)

```
PLAN  → /plan       → Phân tích, lập kế hoạch, trình anh duyệt
DO    → /create     → Thực thi code
CHECK → /audit      → Kiểm tra chất lượng, kết nối, security
ACT   → /status     → Báo cáo kết quả, cập nhật docs
```

---

## 📜 Rules — Quy tắc

Tự động active dựa trên `trigger` trong YAML frontmatter.

| File | Khi nào active |
|------|---------------|
| `GEMINI.md` | Luôn luôn |
| `frontend.md` | Mở file `.tsx .css .html` |
| `backend.md` | Mở file `.ts .sql .yaml` |
| `business.md` | Mở file logic nghiệp vụ |
| `security.md` | Luôn luôn |
| `ui-components.md` | Mở file `.tsx` |
| `error-logging.md` | Luôn luôn |
| `malware-protection.md` | Luôn luôn |

---

## 🧩 Skills — Kỹ năng

Load theo yêu cầu task. Quan trọng nhất cho Petshop:

### 🎨 Frontend & UI
| Skill | Dùng khi |
|-------|---------|
| `modern-web-architect` | Thiết kế component, React pattern |
| `frontend-design` | UI/UX decisions |
| `ui-ux-pro-max` | Thiết kế premium, palette |
| `tailwind-patterns` | (khi migrate sang Tailwind) |
| `tanstack-query-patterns` | TanStack Query, cache, mutations |

### 🗃️ Database & Backend
| Skill | Dùng khi |
|-------|---------|
| `database-migration` | Thay đổi Prisma schema |
| `prisma-orm` | Query optimization, N+1, transactions |
| `nestjs-clean-arch` | NestJS modules, DI, guards, interceptors |
| `fastify-patterns` | Fastify v5 plugin system, lifecycle, hooks |

### 🏪 Commerce & Microservices
| Skill | Gọi khi nào |
|-------|-------------|
| `medusa-commerce` | Xây dựng commerce features, hiểu Module system, Workflow engine, Events |
| `moleculer-patterns` | Thiết kế service architecture, fault tolerance, event-driven patterns |

### ⚙️ DevOps & Quality
| Skill | Dùng khi |
|-------|---------|
| `performance-engineer` | Tối ưu query, bundle size |
| `tdd-master-workflow` | Viết test |
| `deployment-engineer` | Deploy production |
| `connection-health-check` | Sửa DANGER FILES (vite.config, routes/index) |
| `security-scan` | Audit security trước khi commit |

---

## ⚡ Workflows — Slash Commands

| Lệnh | Mục đích |
|------|---------|
| `/plan` | Lập kế hoạch và phân tích |
| `/create` | Tạo tính năng mới (full-stack) |
| `/enhance` | Sửa nhỏ, cải thiện UI |
| `/debug` | Gỡ lỗi có hệ thống |
| `/check-connections` | Kiểm tra FE↔BE connectivity |
| `/ui-ux-pro-max` | Thiết kế giao diện premium |
| `/audit` | Review toàn diện trước bàn giao |
| `/status` | Dashboard trạng thái dự án |
| `/deploy` | Triển khai lên server |
| `/tdd` | Test-driven development |

---

## 🤖 Agent Roles (Scale: Solo-Ninja)

Dự án hiện tại **1 người** nên chạy chế độ **Flexible** — AI xử lý fullstack, không cần phân vai.

Khi team mở rộng, chuyển sang `Balanced` (có plan + review chéo) hoặc `Strict` (PDCA đầy đủ, security mandatory).
