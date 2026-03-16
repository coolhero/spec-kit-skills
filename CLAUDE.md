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

## Design Principles

- **에이전트 워킹 메모리 대신 파일에 기록**: Phase 간 전달되는 중간 산출물은 에이전트 메모리에 보관하지 않고 반드시 파일로 저장합니다. 에이전트 메모리는 컨텍스트 윈도우 한계, 세션 단절, Phase 간 정보 손실에 취약합니다. 파일로 저장하면 언제든 다시 읽을 수 있고, 사용자가 내용을 직접 확인·수정할 수 있으며, 다른 세션에서도 활용 가능합니다.

## Language

- **All artifacts MUST be written in English.** This includes skill files (SKILL.md, commands/*.md, reference/*.md, domains/*.md, templates/*.md), TODO.md, history.md, PLAYWRIGHT-GUIDE.md, and all other project files.
- **Exception**: `README.ko.md` is the only file written in Korean.
- User-facing AskUserQuestion option labels may use Korean if contextually appropriate for Korean-speaking users, but the surrounding documentation and comments must be in English.

## Conventions

- **Git commit messages MUST be written in English.**
- 변경 시 항상 `history.md`에 이력을 기록합니다.
- README.md와 README.ko.md는 항상 동기화 상태를 유지합니다.
- README 수정 시 `Last updated:` 타임스탬프를 **반드시** 현재 시간으로 갱신합니다. `date '+%Y-%m-%d %H:%M KST'` 명령으로 실제 시간을 확인한 후 적용하세요. 추측하지 마세요.
- 스크립트(`scripts/*.sh`)는 dead code로 판단하지 말고, 사용처를 확인하거나 연결해야 합니다.
- Dead reference는 삭제가 아니라 연결(connect)하는 방향으로 처리합니다.

## README File Table

- README.md와 README.ko.md 말미에는 프로젝트 전체 파일 설명 테이블을 유지합니다.
- 파일 추가/삭제/이동 시 반드시 테이블을 업데이트합니다.
- 테이블은 스킬별로 그룹핑하고, 루트 파일은 별도로 정리합니다.

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
