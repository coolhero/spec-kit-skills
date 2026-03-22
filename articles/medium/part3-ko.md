생각하는 400개의 마크다운 파일: spec-kit-skills의 아키텍처

4부작 중 3편 — 설계 철학, 파일 구조, 확장성

![3편 커버](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part3.png)

*2편: 세 가지 스킬, 하나의 파이프라인 — (Medium 2편 링크로 교체)에서 이어집니다*

---

## AI 스킬 설계의 역설

AI 에이전트를 위한 도구를 만들 때의 이상한 진실: **에이전트가 사용자이자 런타임입니다.**

React 컴포넌트를 작성하면 React가 실행합니다. Claude Code 스킬을 작성하면 Claude가 마크다운으로 *읽고* 어떻게 행동할지 결정합니다. "코드"는 자연어. "컴파일러"는 LLM. "버그"는 행동적 — 구문 오류가 아니라 의도 오해.

---

## 세 가지 기초 철학

수백 번의 실패한 파이프라인 실행을 통해 힘들게 배운 것들입니다.

---

### P1: Context Continuity (컨텍스트 연속성)

> 정보는 모든 파이프라인 단계를 통해 연속적으로 흘러야 한다. 전환에서 아무것도 손실되면 안 된다.

당연해 보이지만 그렇지 않습니다. Feature 3을 시작하는 에이전트는 Feature 1에 대해 아무것도 모릅니다 — 명시적으로 로드하지 않으면.

**P1-a: Domain Profile은 First-Class Citizen.** 일회성 설정이 아니라 모든 단계에서 적극적으로 동작합니다.

**P1-b: Artifact Separation.** 스펙은 *무엇을 만들 것인가*만 기술합니다. 소스 분석은 reverse-spec 아티팩트에 남습니다.

**P1-c: Cross-Feature Memory (GEL).** 엔티티 레지스트리, API 레지스트리 — 정보는 파일을 통해 앞으로 흐릅니다.

---

### P2: Enforce, Don't Reference (참조가 아닌 강제)

> "자세한 내용은 X 참조"는 강제력이 없다. 규칙은 실행 지점에서 직접 강제되어야 한다.

가장 반직관적입니다. 에이전트는 참조를 선택적 읽기로 취급합니다.

"전체 검증 프로토콜은 verify-phases.md 참조"
→ 에이전트: "어딘가에 더 있지만, 빌드 + 테스트만 하고 완료."

모든 핵심 규칙에는 세 가지가 필요합니다:

**인라인 지시** — 실행 지점에 직접

**차단 게이트** — 경고가 아닌 차단

**안티패턴 예시** — 명시적 WRONG과 RIGHT

HARD STOP 텍스트가 30곳 이상에 반복됩니다. 의도적입니다. 각각이 다른 실행 지점이고, 공유 파일 참조는 동작하지 않습니다.

---

### P3: File over Memory (메모리가 아닌 파일)

> 모든 중간 산출물과 상태는 파일에 저장한다. 에이전트 메모리에 의존하지 않는다.

에이전트의 컨텍스트 윈도우는 제한적이고, 세션 범위이며, 검사 불가능합니다. 파일은 지속적이고, diff 가능하며, 편집 가능하고, 공유 가능합니다.

`sdd-state.md`가 존재하는 이유입니다 — 프로젝트의 상태 머신이 에이전트 머릿속이 아니라 파일에 있습니다.

---

## 파일 아키텍처

**SKILL.md** — 시스템 프롬프트. 슬림 라우팅 + 필수 규칙. 항상 로드. ~200줄.

**commands/** — 온디맨드 워크플로우. 호출된 커맨드만 로드.

**reference/injection/** — 커맨드별 컨텍스트 주입 규칙.

**domains/** — 모듈식 도메인 전문성:
- `_core.md` — 보편 규칙 (항상 로드)
- `interfaces/` — 9개 인터페이스 모듈
- `concerns/` — 48개 관심사 모듈
- `archetypes/` — 15개 아키타입 모듈
- `profiles/` — 15개 사전 빌드 프로필

---

### 컨텍스트 효율성

- 항상 로드: ~200줄 (SKILL.md)
- 커맨드별: ~500줄
- 도메인별: ~400줄 (3–5개 모듈)
- Feature별: ~200줄
- **합계: ~1,300줄**

전부 로드하면 ~15,000줄 이상 → 컨텍스트 오버플로우. 선택적 로딩이 핵심입니다.

---

### 모듈 로딩 순서

1. `_core.md` → 2. `interfaces/` → 3. `concerns/` → 4. `archetypes/` → 5. `foundations/` → 6. `org-convention` → 7. `scenarios/` → 8. `domain-custom`

후순위가 선순위를 확장합니다. `gui`와 `realtime`이 모두 활성화되면 양쪽의 SC 생성 규칙이 병합됩니다.

---

### Context Injection — 핵심 혁신

각 파이프라인 단계마다 injection 파일이 어떤 컨텍스트를 조립할지 정의합니다. 자연어 규칙을 위한 의존성 주입 컨테이너입니다.

`ai-assistant` + `gui` + `realtime` 프로젝트에서 `speckit-specify`가 실행되면: `_core.md`의 보편 SC 규칙 + `gui.md`의 UI 패턴 + `realtime.md`의 스트리밍 요구사항 + `ai-assistant`의 LLM 확장 — 모두 하나의 일관된 컨텍스트로 병합.

---

## 확장성

**새 Concern 모듈 추가:** `domains/concerns/your-concern.md` 생성. 끝 — resolver가 자동 발견.

**새 Foundation 추가:** `domains/foundations/your-framework.md` 생성. 매칭 시 자동 로드.

**커스텀 프로필 생성:** ~10줄 매니페스트 작성. `--profile`로 사용.

코드 변경 없음. 등록 없음. 규약 기반입니다.

---

## 🤖 에이전트를 위한 글 — 아키텍처 참조

```
architecture:
  principles:
    P1 Context Continuity: Domain Profile first-class + Artifact Separation + GEL
    P2 Enforce Don't Reference: inline + blocking gate + anti-pattern (참조만으론 안됨)
    P3 File over Memory: 모든 상태를 파일에 (sdd-state.md, registries)

  module loading:
    _core → interfaces → concerns → archetypes → foundations → org → scenarios → custom

  context budget:
    typical: ~1,300줄
    all loaded: ~15,000줄 (선택적 로딩으로 회피)

  extensibility:
    add concern: domains/concerns/{name}.md → 자동 발견
    add foundation: domains/foundations/{name}.md → 자동 로드
    add profile: domains/profiles/{name}.md → --profile로 사용
```

---

*다음 편: **4편 — 실패 패턴과 팁** — 스킬 개발자를 위한 실전 가이드.*
