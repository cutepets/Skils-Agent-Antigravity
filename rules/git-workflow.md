---
trigger: always_on
---

# GIT-WORKFLOW — Commit & Branch Convention

## Branch: `{type}/{description}`
Types: `feature/` `fix/` `hotfix/` `refactor/` `chore/` `docs/` `test/`

## Commit: `{type}({scope}): {description}`
Types: `feat` `fix` `refactor` `perf` `docs` `test` `chore` `style` `ci` `revert`
Scopes: `[customize for your project — e.g., auth, api, ui, db, payments, users]`

## Merge Strategy
- `feature/*` → `develop`: Squash and merge
- `develop` → `main`: Merge commit
- `hotfix/*` → `main`: Merge commit + cherry-pick sang develop

## Pre-commit
- Không có `console.log` / secrets / `.env` bị stage
- TypeScript compile OK (`tsc --noEmit`)
- Commit message theo conventional commits

## Không commit
`.env`, `dist/`, `node_modules/`, `.DS_Store`, `*.local`
