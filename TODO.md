# TODO — Context Efficiency Refactoring

> Identified 2026-03-05. These require structural changes across multiple files.

---

## #10a — pipeline.md 분할 (~3,000 토큰 절약)

**현재**: pipeline.md 858줄 — verify/git 섹션이 모든 커맨드 실행 시 로드됨
**제안**: verify 4-phase 상세 + Git Branch Management를 별도 파일로 분리
- `commands/pipeline.md` → Common Protocol + Pipeline/Step Mode (~400줄)
- `commands/verify-phases.md` (신규) → Verify 4-phase 상세
- `reference/branch-management.md` → Git Branch Lifecycle 통합

---

## #8 — 데모 가이드 공통 파일 추출 (~1,500 토큰 절약)

**현재**: 데모 템플릿/안티패턴/요구사항이 5+ 파일에 반복
- SKILL.md Rule 2, implement.md (143줄), verify.md, tasks.md, domains/app.md

**제안**: `reference/demo-standard.md` 신규 생성, 모든 파일에서 참조

---

## #11 — 디스플레이 포맷 블록 압축 (~1,500 토큰 절약)

**현재**: 모든 injection 파일에 전체 ASCII 아트 Checkpoint/Review 레이아웃 반복
**제안**: pipeline.md Common Protocol에 포맷 템플릿 1회 정의, injection 파일은 섹션 목록만 기술

---

## #9 — Adoption 동작 차이 통합 (~500 토큰 절약)

**현재**: "Key Difference from Standard" 패턴이 adopt.md, adopt-*.md 3개, domains/app.md, state-schema.md에 반복
**제안**: adopt.md (또는 `reference/adoption-mode.md`)에 통합, 나머지는 참조
