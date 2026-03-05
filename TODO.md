# TODO — Context Efficiency Refactoring

> Identified 2026-03-05. Status updated 2026-03-06.

---

## ~~#10a — pipeline.md 분할 (~3,000 토큰 절약)~~ ✅ 완료

- `commands/verify-phases.md` 신규 생성 (134줄, Verify Phase 1-4)
- `reference/branch-management.md` 스텁 → 전체 Git Branch Management (117줄)로 교체
- `commands/pipeline.md` 855줄 → 608줄 (-247줄)
- SKILL.md, injection/verify.md 교차 참조 업데이트

---

## ~~#8 — 데모 가이드 공통 파일 추출 (~1,500 토큰 절약)~~ ✅ 완료

- `reference/demo-standard.md` 신규 생성 (~140줄, 통합 데모 가이드)
- `reference/injection/implement.md` ~119줄 제거 → 참조 3줄
- `domains/app.md` § 1 ~18줄 제거 → 참조 1줄
- tasks.md, verify-phases.md 참조 노트 추가

---

## ~~#11 — 디스플레이 포맷 블록 압축~~ ❌ 미진행 확정

디스플레이 블록은 행동 명세 역할도 겸하므로 압축 시 에이전트 동작 오류 위험이 높아 진행하지 않음.

---

## ~~#9 — Adoption 동작 차이 통합 (~400 토큰 절약)~~ ✅ 완료

- `domains/app.md` § 4 (34줄) → 참조 2줄로 교체
- 나머지 파일 (adopt.md, adopt-*.md, state-schema.md): 각각 자기 완결적이어야 하므로 유지
