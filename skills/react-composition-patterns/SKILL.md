---
name: react-composition-patterns
description: React composition patterns để build flexible, maintainable components. Dùng khi refactor components có nhiều boolean props, build component libraries, hoặc design reusable APIs. Kích hoạt khi làm việc với compound components, render props, context providers, hoặc component architecture. Includes React 19 API changes.
license: MIT
metadata:
  author: vercel
  source: https://github.com/vercel-labs/agent-skills/tree/main/skills/composition-patterns
  version: "1.0.0"
---

# React Composition Patterns

Composition patterns để build flexible, maintainable React components. Tránh boolean prop proliferation bằng compound components, lifting state, và composing internals. Áp dụng cho cả Vite + React và NestJS full-stack apps.

## When to Apply

- Refactor components có nhiều boolean props (`isLoading`, `isDisabled`, `hasError`...)
- Build reusable component libraries
- Design flexible component APIs
- Review component architecture
- Working với compound components hoặc context providers

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Component Architecture | HIGH | `architecture-` |
| 2 | State Management | MEDIUM | `state-` |
| 3 | Implementation Patterns | MEDIUM | `patterns-` |
| 4 | React 19 APIs | MEDIUM | `react19-` |

## 1. Component Architecture (HIGH)

### `architecture-avoid-boolean-props`
❌ **Đừng** thêm boolean props để customize behavior — dùng composition thay thế.

```tsx
// ❌ BAD: Boolean prop explosion
<Button primary disabled loading size="large" withIcon />

// ✅ GOOD: Composition
<PrimaryButton>
  <Spinner />
  Save
</PrimaryButton>
```

### `architecture-compound-components`
Structure complex components với shared context.

```tsx
// ✅ GOOD: Compound component pattern
<Tabs defaultValue="orders">
  <Tabs.List>
    <Tabs.Trigger value="orders">Đơn hàng</Tabs.Trigger>
    <Tabs.Trigger value="customers">Khách hàng</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="orders"><OrderList /></Tabs.Content>
  <Tabs.Content value="customers"><CustomerList /></Tabs.Content>
</Tabs>
```

## 2. State Management (MEDIUM)

### `state-decouple-implementation`
Provider là nơi duy nhất biết state được quản lý như thế nào.

### `state-context-interface`
Define generic interface với `state`, `actions`, `meta` cho dependency injection.

```tsx
interface DataTableContext<T> {
  state: { rows: T[]; loading: boolean; selectedIds: Set<string> }
  actions: { select: (id: string) => void; refresh: () => void }
  meta: { totalCount: number; page: number }
}
```

### `state-lift-state`
Move state vào provider components để siblings có thể access.

## 3. Implementation Patterns (MEDIUM)

### `patterns-explicit-variants`
Tạo explicit variant components thay vì boolean modes.

```tsx
// ❌ BAD
<Alert type="success" /> 
<Alert type="error" />

// ✅ GOOD
<Alert.Success>Lưu thành công</Alert.Success>
<Alert.Error>Lỗi kết nối</Alert.Error>
```

### `patterns-children-over-render-props`
Dùng `children` cho composition thay vì `renderX` props.

```tsx
// ❌ BAD
<DataTable renderHeader={() => <CustomHeader />} />

// ✅ GOOD
<DataTable>
  <DataTable.Header><CustomHeader /></DataTable.Header>
</DataTable>
```

## 4. React 19 APIs (MEDIUM)

> ⚠️ **React 19+ only.** Skip nếu dùng React 18.

### `react19-no-forwardref`
Không dùng `forwardRef` trong React 19 — refs được pass như regular props.

```tsx
// ❌ React 18 style
const Input = forwardRef<HTMLInputElement, Props>((props, ref) => (
  <input ref={ref} {...props} />
))

// ✅ React 19 style
function Input({ ref, ...props }: Props & { ref?: Ref<HTMLInputElement> }) {
  return <input ref={ref} {...props} />
}
```

## Áp dụng thực tế — POS/Admin UI

```tsx
// ✅ Modal với compound pattern (thay vì 10 boolean props)
<Modal>
  <Modal.Trigger asChild>
    <Button>Thêm sản phẩm</Button>
  </Modal.Trigger>
  <Modal.Content>
    <Modal.Header>Thêm sản phẩm mới</Modal.Header>
    <Modal.Body><ProductForm /></Modal.Body>
    <Modal.Footer>
      <Modal.Close>Hủy</Modal.Close>
      <Button type="submit">Lưu</Button>
    </Modal.Footer>
  </Modal.Content>
</Modal>
```
