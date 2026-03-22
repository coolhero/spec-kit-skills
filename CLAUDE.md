# Project Rules — spec-kit-skills

## Do NOT Modify (Permanent)

1. **HARD STOP 인라인 텍스트**: `**If response is empty → re-ask** (per MANDATORY RULE 1)` 같은 인라인 HARD STOP 재질문 텍스트를 축약하거나 센티널로 대체하지 마세요. 30+ 곳에 반복되더라도 그대로 유지해야 합니다. 에이전트가 reference 파일의 규칙을 무시하는 경향이 있어 의도적으로 인라인 처리한 것입니다.

2. **domains/data-science.md**: reverse-spec과 smart-sdd 양쪽 모두 TODO 스캐폴딩이 의도적으로 남아있습니다. 향후 구현 예정이므로 삭제하거나 placeholder로 축소하지 마세요.

3. **verify-phases.md — HARD STOP enforcement**: HARD STOP에서 `AskUserQuestion`을 반드시 호출하고 사용자 응답을 대기해야 합니다. health check 통과, non-blocking 분류 등을 이유로 HARD STOP을 우회하거나 자동 스킵하지 마세요.

4. **verify-phases.md — Bug Fix Severity Rule**: verify 단계에서 발견된 버그는 4단계(Minor, Major-Implement, Major-Plan, Major-Spec)로 분류합니다. Minor만 verify에서 즉시 수정하고, Major 이슈는 심각도에 따라 implement/plan/specify로 되돌립니다. 이 규칙의 구조와 분류 기준을 변경하지 마세요.

5. **verify-phases.md — Agent-managed app lifecycle**: UI 검증 시 앱 시작/종료는 에이전트가 직접 관리합니다. 사용자에게 앱을 수동으로 시작/재시작하라고 요청하지 마세요. CDP 프로브 로직의 세부 구현은 개선할 수 있지만, "에이전트가 앱을 직접 관리한다"는 원칙은 유지해야 합니다.

6. **analyze.md — Feature ID Tier-first ordering**: Feature ID는 Tier 우선 전역 순서로 할당합니다 (T1 전체 → T2 전체 → T3 전체, 각 Tier 내에서는 RG 순서). RG 우선 순서로 되돌리지 마세요. T1만 활성화된 파이프라인에서 ID 갭이 발생합니다.

7. **verify-phases.md — Playwright Pre-flight**: verify Phase 1 시작 전 Playwright 가용성 체크(CLI probe → library import probe → MCP probe)를 반드시 수행합니다. 이 pre-flight를 제거하거나 건너뛰지 마세요. CLI가 primary이며, Electron 앱은 `_electron.launch()`로 직접 연결합니다.

8. **pipeline.md — Execute+Review Continuity**: speckit-* 명령 실행 후 결과 요약만 표시하고 멈추지 마세요. Execute와 Review는 하나의 연속 동작입니다. `speckit-* 완료 → spec-kit raw output 억제 → artifact 읽기 → Review 표시 → AskUserQuestion 호출`이 반드시 같은 응답에서 이루어져야 합니다. 컨텍스트 한계로 불가능한 경우에만 fallback 메시지(`💡 Type "continue" to review the results.`)를 표시합니다.
   - **⚠️ speckit-* 호출 시 Skill tool 사용 금지**: `Skill(speckit-specify)`, `Skill(speckit-plan)` 등으로 호출하면 Skill tool의 응답 경계에서 smart-sdd의 턴이 종료되어 Review를 동일 응답에서 이어갈 수 없습니다. 반드시 **Inline Execution** (SKILL.md를 직접 읽고 inline 단계로 실행)을 사용하세요. pipeline.md의 Inline Execution Protocol 참조.
   - **위반 패턴 A (멈춤)**: spec-kit raw output 표시 후 멈춤 → 사용자가 Review를 볼 수 없고, 다음 단계로 진행 불가
   - **위반 패턴 B (건너뜀)**: spec-kit raw output 표시 후 Review/HARD STOP을 건너뛰고 다음 step으로 바로 진행 → 사용자가 산출물 승인 기회를 잃음
   - **위반 패턴 C (Skill tool)**: `Skill(speckit-*)` 호출 → speckit의 completion 메시지가 최종 응답이 됨 → Review 미표시, fallback 안내도 없음 → 사용자가 파이프라인 중단인지 완료인지 판단 불가
   - 세 패턴 모두 금지. Review HARD STOP은 생략 불가. SKILL.md MANDATORY RULE 3 참조.
   - **⚠️ 인라인 Execute+Review 섹션 필수**: pipeline.md에서 speckit-* 명령을 실행하는 모든 step(constitution, specify, plan, tasks, clarify, analyze, implement)에는 **전용 인라인 Execute+Review 섹션**이 있어야 합니다. Common Protocol(파일 상단)이나 injection 파일(specify.md 등)의 지시만으로는 부족합니다 — 실행 시점에 컨텍스트에서 밀려나 에이전트가 무시합니다. 새로운 speckit-* 실행 지점을 추가할 때 반드시 전용 섹션도 함께 추가하세요.
   - **⚠️ Catch-all fallback 필수**: 어떤 이유로든(context limit, tool error, 예기치 않은 흐름) AskUserQuestion 없이 응답이 끝나려 하면, 반드시 `✅ [command] executed for [FID].\n💡 Type "continue" to review the results.` fallback을 표시해야 합니다. **사용자가 다음에 뭘 해야 하는지 모르는 상태로 멈추는 것은 절대 허용되지 않습니다.** fallback은 "context limit인 경우"만이 아니라 **모든 비정상 종료**에 적용됩니다.

9. **pipeline.md — Inter-step Continuity**: Feature 내 step 간 전환(예: plan Update → tasks Checkpoint)은 자동으로 이어져야 합니다. step 완료 후 "completed" 메시지만 표시하고 멈추지 마세요. 멈출 수 있는 유일한 지점은 HARD STOP(사용자 승인 대기), BLOCK 조건, Feature 완료, 복구 불가 에러뿐입니다. **HARD STOP 없이 다음 step으로 건너뛰는 것은 "continuity"가 아니라 "HARD STOP 위반"입니다.**

## Design Principles — 3 Foundational Philosophies

모든 설계 결정과 구현은 아래 3가지 철학에 근거합니다. 새로운 규칙, 게이트, 명령, 스킬을 추가할 때 반드시 이 3가지 관점에서 검증하세요.

```
            P1. Context Continuity (무엇을 지키는가)
           /          |           \
  Domain Profile   Source Code    Cross-Feature
  전 단계 흐름     파이프라인 보존   GEL 기억
          \           |           /
         P2. Enforce, Don't Reference (어떻게 지키는가)
                      |
         P3. File over Memory (어디에 저장하는가)
```

### P1. Context Continuity (컨텍스트 연속성)

> **정보는 파이프라인의 모든 단계에서 연속적으로 흘러야 하며, 단계 간 전환에서 손실되면 안 된다.**

이 원칙은 3가지 핵심 영역으로 구체화됩니다:

**P1-a. Domain Profile은 First-Class Citizen**: Domain Profile(5축 + 1 modifier)은 한번 설정하고 잊는 구성이 아니라, code-explore → init → add → specify → plan → implement → verify 전 단계에서 적극적으로 동작하는 살아 있는 컨텍스트입니다. 새로운 규칙을 추가할 때 반드시 "이 규칙이 Domain Profile의 어떤 축(Interface, Concern, Archetype, Foundation, Scenario)이나 modifier(Scale)에 의해 조건부로 활성화되거나 깊이가 조절되어야 하는지" 판단하세요. Domain Profile과 무관한 범용 규칙은 명시적으로 "Domain Profile independent"로 표시합니다.

**P1-b. Source Code Fidelity (Artifact Separation Principle)**: Source app의 정보(UI 구조, 데이터 흐름, 유입 경로, 인터랙션 패턴)는 **reverse-spec 아티펙트에만 저장**되고, smart-sdd 파이프라인 아티펙트(spec.md, plan.md, tasks.md)에는 **소스 코드 내용이 보이지 않아야** 합니다. spec.md는 "무엇을 만드는지"만 정의하고, "어디서 왔는지"는 pre-context에 남깁니다. smart-sdd가 추가 소스 분석을 하면, 결과는 reverse-spec 아티펙트(pre-context.md)를 업데이트하는 방식으로 축적합니다. 이렇게 하면: (1) spec이 source에 종속되지 않음, (2) 소스 분석의 단일 출처가 보장됨, (3) implement/verify는 pre-context를 참조하여 소스 패턴을 따름.

**P1-c. Cross-Feature Memory (GEL)**: entity/API registry, pre-context, stubs, interaction surfaces 등 Global Evolution Layer 아티펙트가 Feature 간 정보를 전달합니다. Feature 2가 Feature 1의 결정을 체계적으로 알 수 있어야 하며, 이는 에이전트 역량에 기대하는 것이 아니라 아티펙트 구조로 보장해야 합니다.

### P2. Enforce, Don't Reference (참조가 아닌 강제)

> **"See X for details"는 행동 강제력이 없다. 규칙은 참조시키는 것이 아니라 실행 시점에서 직접 강제해야 한다.**

다른 파일을 참조하라는 지시만으로는 에이전트가 따르지 않습니다. 에이전트는 즉시 보이는 지시만 실행하고, 참조는 "선택적 읽기"로 취급합니다. 모든 critical 규칙에는 3가지가 갖춰져야 합니다:
1. **Inline instruction** — "See X.md"가 아니라, 실행 시점에 규칙 자체가 직접 보여야 함
2. **BLOCKING gate** — ⚠️ 경고가 아닌 🚫 차단. 규칙을 따르지 않으면 다음 단계로 진행 불가
3. **Anti-pattern examples** — ❌ WRONG / ✅ RIGHT. 잘못된 패턴을 명시적으로 금지

```
❌ "See verify-phases.md for details"
   → 에이전트: "참고 사항이구나" → 안 읽고 build+TS만 수행 → "verify ✅"

✅ "🚨 verify-phases.md를 읽지 않고 build+TS만 수행하는 것은 verify가 아닙니다"
   → 에이전트: "안 읽으면 위반이구나" → 읽고 Phase 0-4 전체 실행
```

### P3. File over Memory (메모리가 아닌 파일)

> **모든 중간 산출물과 상태는 파일로 저장하며, 에이전트 메모리에 의존하지 않는다.**

Phase 간 전달되는 중간 산출물은 에이전트 메모리에 보관하지 않고 반드시 파일로 저장합니다. 에이전트 메모리는 컨텍스트 윈도우 한계, 세션 단절, Phase 간 정보 손실에 취약합니다. 파일로 저장하면 언제든 다시 읽을 수 있고, 사용자가 내용을 직접 확인·수정할 수 있으며, 다른 세션에서도 활용 가능합니다.

### 적용 체크리스트

새로운 변경사항을 추가할 때 아래 질문에 답하세요:

| # | 질문 | 해당 원칙 |
|---|------|----------|
| 1 | 이 규칙은 Domain Profile의 어떤 축에 의해 조건부 활성화되는가? 아니면 범용인가? | P1-a |
| 2 | 이 정보가 다음 파이프라인 단계로 전달될 때 손실되는 부분은 없는가? | P1-b, P1-c |
| 3 | 이 규칙에 BLOCKING gate + 인라인 지시 + anti-pattern이 있는가? | P2 |
| 4 | 이 규칙의 결과/상태가 파일에 기록되는가, 에이전트 메모리에만 남는가? | P3 |
| 5 | 에이전트가 자동화할 수 없는 부분이 있다면, 사용자에게 위임하도록 설계되어 있는가? | P2-delegate |

### P2 부칙: Delegate, Don't Skip (자동화 불가 = 사용자 위임, 건너뛰기 아님)

> **에이전트의 도구 한계가 곧 검증의 한계가 아니다.**

에이전트가 자동화할 수 없는 검증(OS-native 기능, 외부 API 키, 하드웨어 의존)을 만나면 **"skip"이 아니라 사용자에게 구체적 수동 확인을 요청**해야 합니다. 이 원칙은 반복적으로 위반되는 패턴이므로 별도로 강조합니다.

```
❌ WRONG: "Playwright 한계로 드래그앤드롭 skip" → 미검증이 조용히 넘어감
❌ WRONG: "API 키 없음 → external-dep으로 분류 → skip" → 사용자가 키를 설정하면 테스트 가능
✅ RIGHT: AskUserQuestion "파일을 KB 영역에 드래그해주세요. 상태가 pending → processing으로 변하는지 확인해주세요"
✅ RIGHT: AskUserQuestion "Settings > Provider에서 API 키를 설정한 후 알려주세요. 설정 후 임베딩 생성을 자동 테스트합니다"
```

## Language

- **Skill files** (SKILL.md, commands/*.md, reference/*.md, domains/*.md, templates/*.md) and **project files** (history.md, PLAYWRIGHT-GUIDE.md) MUST be written in English. These are the framework's source code — language is not configurable.
- **lessons-learned.md**: 한국어로 작성합니다. 주 독자가 프로젝트 관리자(사용자)이므로 가독성을 우선합니다. 기술 용어(Context Injection, HARD STOP 등)는 영어 원문 유지.
- **Exception**: `README.ko.md`, `ARCHITECTURE-EXTENSIBILITY.ko.md`, `SCENARIO-CATALOG.ko.md`는 한국어로 작성합니다.
- **README.ko.md technical terms**: Use English originals when Korean translation would obscure meaning. Examples: Harness Engineering, Context Injection, Gate Enforcement, Behavioral Fidelity, Pipeline Integrity Guard. Criterion: if Korean translation doesn't immediately convey the original meaning, use English.
- **User-facing artifacts** (spec.md, plan.md, tasks.md, roadmap.md, registries, pre-context, constitution, demo scripts, and all other pipeline-generated files in `specs/`) follow the **Artifact Language** setting in `sdd-state.md`. Default: `en`. Configurable via `--lang` argument during `init`, `reverse-spec`, or `add`.
- User-facing AskUserQuestion option labels may use the user's preferred language if contextually appropriate, but skill source files and comments must remain in English.

## Conventions

- **Git commit messages MUST be written in English.**
- 변경 시 항상 `history.md`에 이력을 기록합니다. **이 레포에서 `history.md`는 루트(`./history.md`)에 위치합니다.** `specs/history.md`가 아닙니다. (스킬이 사용되는 대상 프로젝트에서는 `specs/history.md`가 맞지만, spec-kit-skills 레포 자체에서는 루트입니다.)
- README.md와 README.ko.md는 항상 동기화 상태를 유지합니다.
- ARCHITECTURE-EXTENSIBILITY.md와 ARCHITECTURE-EXTENSIBILITY.ko.md는 항상 동기화 상태를 유지합니다.
- SCENARIO-CATALOG.md와 SCENARIO-CATALOG.ko.md는 항상 동기화 상태를 유지합니다.
- **명령어·시나리오·모드 변경 시** SCENARIO-CATALOG 반드시 동시 업데이트합니다. 새 명령 추가 → 해당 카테고리에 시나리오 추가. 명령 동작 변경 → 기존 시나리오 설명 수정. 명령 제거 → 시나리오 삭제. 합계와 카테고리별 수도 갱신합니다.
- README 수정 시 `Last updated:` 타임스탬프를 **반드시** 현재 시간으로 갱신합니다. `date '+%Y-%m-%d %H:%M KST'` 명령으로 실제 시간을 확인한 후 적용하세요. 추측하지 마세요.
- 파일 추가/삭제/이동 시 `FILE-MAP.md` § 4 (File Inventory)를 **반드시** 업데이트합니다. 새 모듈 유형 추가 시 § 3 (Domain Module Hierarchy)도 업데이트합니다.
- 스크립트(`scripts/*.sh`)는 dead code로 판단하지 말고, 사용처를 확인하거나 연결해야 합니다.
- Dead reference는 삭제가 아니라 연결(connect)하는 방향으로 처리합니다.

## Post-Change Propagation Check

작업 완료 시 아래 파일들에 변경 사항을 반영해야 하는지 반드시 판단합니다:

| 파일 | 반영 기준 |
|------|----------|
| `README.md` + `README.ko.md` | 기능 변경 → 해당 섹션 업데이트. 항상 `Last updated:` 갱신 |
| `FILE-MAP.md` | 파일 추가/삭제/이동 → § 4 파일 인벤토리 업데이트. 새 모듈 유형 추가 → § 3 도메인 계층 업데이트 |
| `ARCHITECTURE-EXTENSIBILITY.md` + `.ko.md` | 모듈 추가/삭제, 확장성 구조 변경, Cross-Reference Map에 영향. **새로운 아키텍처 개념(spec-draft, UI Flow Spec, Artifact Separation 등) 추가 시 § 11 Rebuild Architecture와 § 12 Cross-Reference Map 반드시 업데이트** |
| `history.md` | 설계 결정, 구조 변경, SKF 반영 등 기록할 만한 변경 |
| `lessons-learned.md` | 범용적으로 적용 가능한 실패 패턴이나 교훈 발견 시 |
| `SCENARIO-CATALOG.md` + `SCENARIO-CATALOG.ko.md` | 시나리오 흐름 변경, 새 명령/모드 추가 → 관련 시나리오 업데이트 또는 신규 추가. **두 파일 항상 동기화** |

## FILE-MAP.md (File Inventory)

- 프로젝트 전체 파일 인벤토리와 관계도는 `FILE-MAP.md`에서 관리합니다.
- 파일 추가/삭제/이동 시 반드시 FILE-MAP.md § 4 (File Inventory)를 업데이트합니다.
- 새 모듈 유형 추가 시 § 3 (Domain Module Hierarchy) 다이어그램도 업데이트합니다.
- README.md와 README.ko.md는 FILE-MAP.md로의 링크만 유지합니다.

## Skill Feedback Intake

- 피드백 소스: `/Users/coolhero/Develop/angdu-studio/skill-feedback.md`
- 사용자가 "skill-feedback 확인해줘"라고 하면 위 파일을 읽고 각 SKF 항목을 처리
- 처리 절차:
  1. `skill-feedback.md` 읽기
  2. 각 항목의 **Skill Trace** → 해당 skill 파일 열기
  3. **Category**별 수정 방향에 따라 수정안 제시
  4. 사용자 승인 후 수정 반영
  5. 수정 완료된 항목은 `history.md`에 기록
- 수정 시 CLAUDE.md **Do NOT Modify** 항목을 반드시 확인 — 해당 영역이면 사용자에게 알리고 진행 여부 확인

## Documentation Writing Guidelines

- **README.md / README.ko.md**: High-level design direction. Users should understand the overall architecture and design philosophy at a glance. Keep explanations concise with visual diagrams where possible. Avoid duplicating detailed extension procedures.
- **ARCHITECTURE-EXTENSIBILITY.md**: Detailed extensibility specifics. Step-by-step guides for adding new modules, sophistication levels, concrete examples. This is the deep-dive reference for contributors and advanced users.
- **Linking**: README must link to ARCHITECTURE-EXTENSIBILITY.md for detailed extensibility content. Use the pattern: "For step-by-step extension guides, see [ARCHITECTURE-EXTENSIBILITY.md](ARCHITECTURE-EXTENSIBILITY.md)".
- **Single Source of Truth**: Detailed extension procedures live only in ARCHITECTURE-EXTENSIBILITY.md. README provides overview + link. Module section schemas live in `_schema.md` files; ARCHITECTURE-EXTENSIBILITY.md references them, not duplicates them.

## Review Protocol

전체 파일 검토 시 아래 순서로 수행합니다:

1. **Flow 일관성**: 전체적인 pipeline flow에 이상이 없는지, 파일 간 참조가 불일치하지 않는지 검토
2. **미활용 부분 분류**: 현재 활용되지 않는 부분이 (a) 원래 활용되어야 하는데 누락된 것인지, (b) 진짜 불필요한 것인지 구분
3. **공통화/스크립트화**: context 효율성을 위해 중복 패턴을 공통 reference로 추출할 수 있는지 검토
4. **과세분화(over-fragmentation) 점검**: 반복 업데이트로 동일한 내용이 여러 파일에 과도하게 세분화되어 있지 않은지 확인. 동일 개념의 설명이 3곳 이상에서 반복되면 아래 기준으로 통합:
   - **단일 출처 원칙(Single Source of Truth)**: 상세 정의는 하나의 reference 파일에, 나머지는 cross-reference(`See [file] §N`)로 대체
   - **인라인 반복 허용 예외**: HARD STOP 재질문 텍스트(Do NOT Modify #1), CLAUDE.md Do NOT Modify 항목
   - **판단 기준**: "이 내용이 바뀌면 몇 곳을 수정해야 하나?" — 3곳 이상이면 통합 대상
5. **HARD STOP + Execute+Review 패턴 검증**: pipeline.md, verify-phases.md, adopt.md 등에서 speckit-* 명령 실행 지점을 모두 확인하고, 각 지점에 아래 3가지가 갖춰져 있는지 검토:
   - (a) spec-kit raw output 억제 지시 ("Suppress", "Do NOT show")
   - (b) artifact 읽기 + Review 표시 + AskUserQuestion 호출 (HARD STOP)
   - (c) 컨텍스트 한계 시 fallback 메시지 (`💡 Type "continue"`)
   - 누락 시 해당 지점에 인라인으로 추가 (reference 파일 참조만으로는 에이전트가 무시하는 경향 — Do NOT Modify #1과 같은 이유)
6. **Cross-Reference Integrity (참조 링크 무결성)**: 모든 `See [file] §N`, `[text](path)` 링크가 실제 존재하는 파일/섹션을 가리키는지 검증. 파일 이동/이름 변경 시 깨지기 쉬움. 검증 방법: `See`, `](` 패턴으로 grep → 대상 파일 존재 확인.
7. **Numeric Consistency (숫자/카운트 일관성)**: "7-step loading order", "9 injection files", "4-tier severity" 등 여러 파일에서 동일한 숫자를 언급할 때 실제 개수와 일치하는지 검증. 모듈 추가/삭제 시 한 곳만 업데이트하고 나머지를 놓치는 패턴이 빈번. 예: `_resolver.md`에서 7단계라고 하면 `_schema.md`, `SKILL.md`, `ARCHITECTURE-EXTENSIBILITY.md`도 모두 7이어야 함.
8. **Template↔Schema Alignment (템플릿-스키마 정합성)**: `templates/*.md`의 필드가 `_schema.md`, `state-schema.md` 등 정의된 스키마와 일치하는지 검증. 스키마에 필드를 추가했는데 템플릿에 반영 안 된 경우, 또는 그 반대. 검증 방법: 스키마 파일의 필드 목록 추출 → 템플릿의 placeholder 비교.
9. **Graceful Degradation Coverage (우아한 퇴보 테이블 완전성)**: `context-injection-rules.md`의 graceful degradation 테이블이 모든 optional artifact를 커버하는지 검증. 새로운 optional artifact(예: org-convention, Brief Summary)를 추가하면 degradation 규칙도 함께 추가해야 하는데, 누락되기 쉬움. 검증 방법: injection 파일들에서 "if absent/missing/none" 조건 추출 → degradation 테이블과 대조.
10. **FILE-MAP.md Completeness (파일 인벤토리 완전성)**: FILE-MAP.md § 4의 파일 인벤토리가 실제 프로젝트 파일과 1:1 매칭되는지 검증. 파일 추가/삭제 후 업데이트를 잊는 패턴. 검증 방법: `glob **/*.md` 결과와 § 4 항목 비교 → 누락/잉여 식별.
11. **Guard↔Pipeline Step Binding (가드-파이프라인 바인딩 검증)**: `pipeline-integrity-guards.md`의 7개 가드(G1~G7)가 실제로 올바른 파이프라인 step에 바인딩되어 있는지 검증. 가드 정의는 있지만 실제 injection 파일에서 참조하지 않으면 사실상 미적용. 검증 방법: 각 Guard ID로 grep → injection/*.md, pipeline.md, verify-phases.md에서 참조 확인.
12. **Rule Extensibility Check (규칙 확장성 검증)**: 새로 추가되거나 수정된 규칙이 특정 프레임워크(React, Electron 등)에 하드코딩되어 있지 않은지 검증. 모든 규칙은 **보편적 원칙 + 프레임워크별 구현 예시** 구조여야 함. 검증 기준:
   - **원칙**: "저장 데이터 불변, 표시 시점 변환만 허용" (모든 프로젝트에 적용)
   - **구현 예시**: "React: useMemo, Vue: computed, Django: template filter" (프레임워크별로 다름)
   - ❌ WRONG: "`useMemo`로 변환하세요" (React만 해당)
   - ✅ RIGHT: "표시 시점 변환만 허용 (예: React useMemo, Vue computed, Django template filter)"
   - 검증 방법: 새 규칙에서 프레임워크명/라이브러리명이 예시가 아닌 **지시문**에 있으면 일반화 필요
13. **Scenario Catalog Regression (시나리오 회귀 검증)**: `SCENARIO-CATALOG.md`의 57개 시나리오 중 변경 사항에 영향받는 시나리오를 식별하고, 해당 Flow가 여전히 동작하는지 검증. 검증 방법: 변경된 파일명으로 카탈로그를 검색 → 관련 시나리오의 Flow를 따라가며 파이프라인 무결성 확인. 새 시나리오 추가 시 카탈로그도 업데이트.
