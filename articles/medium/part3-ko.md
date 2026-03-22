# 생각하는 400개의 마크다운 파일: spec-kit-skills의 아키텍처

## 4부작 중 3편 — 설계 철학, 파일 구조, 확장성

![3편 커버](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part3.png)

*2편: 세 가지 스킬, 하나의 파이프라인 — (Medium 2편 링크로 교체)에서 이어집니다*

---

## AI 스킬 설계의 역설

AI 에이전트를 위한 도구를 만들 때의 이상한 진실: **에이전트가 사용자이자 런타임입니다.**

React 컴포넌트를 작성하면 React가 실행합니다. Claude Code 스킬을 작성하면 Claude가 마크다운으로 *읽고* 어떻게 행동할지 결정합니다. "코드"는 자연어. "컴파일러"는 LLM. "버그"는 행동적입니다 — 구문 오류 때문이 아니라 의도를 오해해서 에이전트가 잘못된 일을 합니다.

이것은 스택 트레이스로 디버깅할 수 없다는 뜻입니다. 브레이크포인트를 설정할 수 없습니다. "에이전트가 X 지시를 따르는가"에 대한 유닛 테스트를 작성할 수 없습니다. 유일한 테스트 방법은: 파이프라인을 실행하고, 무슨 일이 일어나는지 관찰하고, 반복하는 것입니다.

거기에 더해 이것을 특별히 어렵게 만드는 추가 제약이 있습니다: **컨텍스트 윈도우는 유한하며 압축됩니다.** 스킬 파일 상단에 정성껏 쓴 규칙이? 50개 메시지 후에는 한 문장 요약으로 압축되거나 — 아예 삭제될 수 있습니다.

이것이 설계 방식 전체를 바꿉니다.

---

## 세 가지 기초 철학

spec-kit-skills의 모든 설계 결정은 세 가지 원칙으로 거슬러 올라갑니다. 처음부터 이 원칙을 가지고 시작한 게 아닙니다 — 수백 번의 실패한 파이프라인 실행을 통해 발견했습니다. 각 실패가 "더 좋은 지시를 쓰자"로는 해결할 수 없는 패턴을 드러냈습니다.

---

### P1: Context Continuity — 정보는 앞으로 흘러야 한다

> 정보는 모든 파이프라인 단계를 통해 연속적으로 흘러야 한다. 전환에서 아무것도 손실되면 안 된다.

당연해 보이지만, AI 에이전트에서 "전환"이 무엇을 의미하는지 깨닫기 전까지는 그렇습니다:

**Feature 간:** Feature 3은 깨끗한 컨텍스트에서 시작합니다. Feature 1의 User 엔티티나 Feature 2의 API 계약에 대해 아무것도 모릅니다 — 명시적으로 그 정보를 로드하지 않으면. 이를 Global Evolution Layer로 해결했습니다: entity-registry.md, api-registry.md, sdd-state.md가 정보를 파일로 앞으로 전달합니다.

**파이프라인 단계 간:** `speckit-specify`가 끝나고 `speckit-plan`이 시작될 때, 에이전트의 작업 컨텍스트가 전환됩니다. specify의 상세 분석이 압축될 수 있습니다. 이를 각 단계별로 관련 컨텍스트를 명시적으로 재로드하는 injection 파일로 해결했습니다.

**세션 간:** 사용자가 노트북을 닫고 다음 날 열어서 계속합니다. 에이전트가 어제 "알고 있던" 모든 것이 사라집니다 — 파일에 있는 것만 빼고. 모든 중간 결과, 모든 결정, 모든 상태 전환이 파일 시스템에 영속화됩니다.

Context Continuity에는 세 가지 하위 원칙이 있습니다:

**P1-a: Domain Profile은 First-Class Citizen.** 일회성 설정이 아닙니다. Domain Profile이 모든 단계를 적극적으로 형성합니다 — `add`에서 어떤 프로브가 질문되는지, `specify`에서 어떤 규칙이 활성화되는지, `verify`에서 어떤 검증 단계가 실행되는지. 프로필이 `gui + realtime`이면, specify는 낙관적 UI 업데이트와 재연결 처리를 위한 SC를 생성합니다. `cli + resilience`면, 완전히 다른 SC가 나옵니다.

구체적인 메커니즘은 이렇습니다: 도메인 모듈에는 표준화된 섹션이 있습니다 (S1은 SC 생성 규칙, S5는 정교화 프로브, S7은 버그 방지 규칙, S8은 런타임 검증 전략). 파이프라인이 실행될 때, injection 파일이 관련 모듈을 로드하고 해당 섹션을 병합합니다. `ai-assistant` 아키타입은 A2 (토큰 관리, 스트리밍 중단을 위한 SC 확장)를 추가합니다. `gui` 인터페이스는 S6 (UI 테스트 통합)을 추가합니다. 누적됩니다 — specify의 최종 컨텍스트는 모든 활성 모듈의 S1 섹션의 합집합입니다.

**P1-b: Artifact Separation (소스 코드 충실성).** 이 원칙은 고통스러운 실패에서 태어났습니다. 리빌드 프로젝트에서 Feature 3의 스펙이 원하는 동작 대신 소스 앱의 구현 디테일을 기술했습니다. 다르게 구현하려고 하니(더 나은 데이터 모델, 다른 API 설계) 스펙이 저항했습니다 — 옛 구현 쪽으로 계속 끌려갔습니다.

해결책: 스펙은 *무엇을 만들 것인가*만 기술하고, *어디서 왔는가*는 절대 기술하지 않습니다. 소스 분석은 reverse-spec 아티팩트(pre-context.md)에 남습니다. Smart-sdd 스펙(spec.md)은 소스에 무관합니다. 이 분리 덕분에 스펙이 옛 구현에 오염되지 않은 채로 다르게 재구축할 수 있습니다.

**P1-c: Cross-Feature Memory (GEL).** Global Evolution Layer는 Feature 간 정보를 전달하는 파일로 구성됩니다:
- `entity-registry.md` — 필드, 타입, 관계를 가진 모든 데이터 모델
- `api-registry.md` — 계약을 가진 모든 엔드포인트
- `sdd-state.md` — 프로젝트 상태 머신 (어떤 Feature가 어떤 단계에 있는지)
- `roadmap.md` — Feature 의존성 그래프
- `pre-context.md` (Feature별) — 상세 요구사항 컨텍스트

Feature 3이 시작될 때, 에이전트가 레지스트리를 읽습니다. Feature 1의 User 엔티티를 보고, 가상의 필드가 아니라 기존 필드를 참조하는 SC를 생성합니다. 돌이켜보면 너무나 당연한데 — 이것 없이는 모든 Feature가 모든 엔티티를 재발명하고, 통합이 악몽이 됩니다.

---

### P2: Enforce, Don't Reference — 가장 반직관적인 원칙

> "자세한 내용은 X 참조"는 강제력이 없다. 규칙은 실행 지점에서 직접 강제되어야지, 먼 곳에서 참조되면 안 된다.

일반 소프트웨어에서는 함수를 한 번 작성하고 여러 곳에서 호출합니다. DRY — Don't Repeat Yourself. 하지만 에이전트 스킬에서는 **DRY가 컴플라이언스를 죽입니다.**

이유는 이렇습니다: 에이전트는 참조를 선택적 읽기로 취급합니다. "전체 검증 프로토콜은 verify-phases.md 참조"를 보면, "더 많은 정보가 있지만, 진행하기에 충분한 컨텍스트가 있다"로 처리합니다. 빌드 + TypeScript를 실행하고, "verify ✅"를 보고하고, 넘어갑니다. verify-phases.md의 400줄 상세 검증 로직은 읽히지 않습니다.

이건 가정이 아닙니다. Feature 6 검증 중에 실제로 일어났습니다 — 같은 에이전트가 Feature 1부터 5까지는 전체 검증 프로토콜을 올바르게 실행한 후에요. 컨텍스트 압축이 verify-phases.md 내용을 먹어치웠고, 참조는 선택사항으로 취급되었습니다.

해결에는 세 가지 레이어가 필요했습니다:

**레이어 1 — 인라인 지시.** 규칙이 참조된 파일이 아니라 실행 지점에 직접 나타납니다. "verify-phases.md 참조"가 아니라 실제 규칙이 바로 거기에.

**레이어 2 — 차단 게이트.** 경고("⚠️ 검증해야 합니다")가 아니라 차단("🚫 BLOCKING: 검증 미완료. 머지로 진행 불가."). 차이는 에이전트가 차단을 합리화해서 넘어갈 수 없다는 것 — 검증을 완료하지 않으면 구조적으로 다음 단계의 출력을 생산할 수 없습니다.

**레이어 3 — 안티패턴 예시.** 명시적 WRONG과 RIGHT 패턴:

```
❌ WRONG: 빌드+TS 실행, "verify ✅" 표시, 머지로 진행
   → 10개 SC 미검증. Feature가 UI에서 도달 불가.

✅ RIGHT: verify-phases.md 읽기 → Phase 0-4 실행 →
   SC 커버리지 매트릭스 표시 → AskUserQuestion
```

이것이 spec-kit-skills에 중복처럼 보이는 텍스트가 있는 이유입니다. HARD STOP 재질문 지시가 여러 파일에 걸쳐 30회 이상 나타납니다. 각각이 다른 실행 지점에 있습니다. 공유 파일로 추출하면 "더 깔끔한" 코드가 되겠지만 — 에이전트에게 무시됩니다.

**패턴의 구체적 예시:**

에이전트가 종종 spec-kit 커맨드를 실행하고, raw output을 보여주고, 거기서 멈추는 것을 발견했습니다 — 생성된 아티팩트를 읽지도, 리뷰를 표시하지도, 사용자 승인을 요청하지도 않고 (일명 "Skill Tool Response Boundary" 문제). 해결은 단일 규칙이 아니라 4중 방어였습니다:

1. SKILL.md (항상 로드)에 MANDATORY RULE 3: "모든 speckit-* 실행 후 반드시 아티팩트를 읽고, 리뷰를 보여주고, AskUserQuestion을 호출해야 합니다"
2. 각 파이프라인 단계의 섹션에 해당 단계에 특화된 인라인 Execute+Review 프로토콜
3. Catch-all fallback: 어떤 이유로든 응답이 AskUserQuestion 없이 끝나면 continue 프롬프트를 표시
4. raw spec-kit 탐색 메시지가 누출되는 것을 감지하는 Stop 훅 (셸 스크립트)

---

### P3: File over Memory — 영속성의 원칙

> 모든 중간 산출물과 상태는 파일에 저장한다. 에이전트 메모리에 의존하지 않는다.

에이전트의 컨텍스트 윈도우를 상태 저장에 신뢰할 수 없게 만드는 세 가지 속성:

- **유한** — 대화가 길어지면 압축됩니다. 50개 메시지 후, 초기 컨텍스트가 요약되거나 완전히 삭제됩니다.
- **세션 범위** — 세션이 끝나면 모든 것이 사라집니다. 다음 세션은 백지에서 시작합니다.
- **검사 불가** — 에이전트가 무엇을 기억하는지 볼 수 없습니다. "왜 Feature 1이 UUID를 사용한다는 걸 잊었을까?"를 디버깅할 수 없습니다.

파일에는 이런 문제가 없습니다. 영구적이고, diff 가능하고 (`git diff`로 정확히 무엇이 변했는지 볼 수 있음), 편집 가능하고 (스펙을 수동으로 고치고 재실행할 수 있음), 공유 가능합니다 (다른 에이전트나 사람이 작업을 이어갈 수 있음).

`sdd-state.md`가 상태 머신 파일로 존재하는 이유가 이것입니다. 컨텍스트 압축이나 새 세션 후 에이전트가 재개할 때, 파일을 읽고, "F003은 implement 단계, 태스크 4/7"을 보고, 거기서 계속합니다. 추측 없이, "우리가 뭘 하고 있었더라..."도 없이.

---

## 파일 아키텍처: 400개 이상의 파일이 컨텍스트 효율적으로 유지되는 방법

### 핵심 패턴

모든 스킬이 같은 구조를 따릅니다:

```
SKILL.md              — 항상 로드 (~200줄)
commands/             — 온디맨드 로드 (호출된 커맨드만)
reference/
  injection/          — 커맨드별 컨텍스트 조립 규칙
  state-schema.md     — 상태 머신 정의
  pipeline-integrity-guards.md
domains/
  _core.md            — 보편 규칙 (도메인과 함께 항상 로드)
  _resolver.md        — 모듈 로딩 로직
  interfaces/         — 9개 모듈 (gui, cli, http-api, grpc, tui, embedded, mobile, library, data-io)
  concerns/           — 48개 모듈 (auth, realtime, resilience, connection-pool, tls-management, ...)
  archetypes/         — 15개 모듈 (ai-assistant, microservice, network-server, ...)
  scenarios/          — 4개 모듈 (greenfield, rebuild, adoption, incremental)
  profiles/           — 15개 사전 빌드 프로필
```

### 이 구조가 동작하는 이유: 컨텍스트 예산

LLM 컨텍스트 윈도우는 크지만 무한하지 않습니다. 모든 것을 로드하면 에이전트가 작업을 시작하기도 전에 컨텍스트 예산을 소진합니다. spec-kit-skills는 **선택적 로딩** — 현재 태스크와 프로젝트 프로필에 맞는 모듈만 로드합니다.

일반적인 파이프라인 단계의 계산:

- **항상 로드:** ~200줄 (SKILL.md — 라우팅 + 필수 규칙)
- **커맨드별:** ~500줄 (특정 커맨드 파일, 예: pipeline.md)
- **도메인별:** ~400줄 (Domain Profile에 맞는 3~5개 모듈 x ~100줄)
- **Feature별:** ~200줄 (프리컨텍스트 + 현재 스펙)
- **합계:** ~1,300줄의 작업 컨텍스트

전부 로드하면: ~15,000줄 이상 — 에이전트가 작업 대신 지시를 읽는 데 컨텍스트 예산을 쓰게 됩니다. 선택적 로딩이 이것을 실용적으로 만듭니다.

### 도메인 모듈 로딩 순서

파이프라인이 실행될 때, 모듈은 특정 순서로 로드됩니다. 각 레이어가 이전 것을 확장할 수 있습니다:

1. **_core.md** — 모든 프로젝트에 적용되는 보편 규칙
2. **interfaces/{name}.md** — Interface 축에 특화된 규칙 (gui, cli, http-api, grpc 등)
3. **concerns/{name}.md** — 각 활성 Concern에 대한 규칙 (auth, realtime, resilience 등)
4. **archetypes/{name}.md** — 도메인 철학 규칙 (ai-assistant, microservice, network-server 등)
5. **foundations/{framework}.md** — 프레임워크 특화 규칙 (electron, fastapi, go 등)
6. **org-convention.md** — 조직 전체 규칙 (선택사항, 프로젝트 간 공유)
7. **scenarios/{name}.md** — 생명주기 규칙 (greenfield, rebuild, adoption)
8. **domain-custom.md** — 프로젝트 수준 오버라이드 (선택사항)

모듈은 표준화된 섹션 번호를 사용합니다. Interface와 Concern은 S0~S9. Archetype는 A0~A5 (충돌을 피하기 위한 별도 번호 체계). 여러 모듈이 활성화되면, 해당 섹션이 **병합**됩니다 — `gui.md`의 S1 (SC 생성 규칙)이 `realtime.md`의 S1, `ai-assistant`의 A2 (SC 확장)와 함께 누적됩니다.

병합 의미론은 append 기반입니다: `gui`가 "모든 인터랙티브 요소에 호버 상태 SC가 필요하다"고 하고 `realtime`이 "모든 스트리밍 디스플레이에 완료 표시기 SC가 필요하다"고 하면, 결합된 S1 섹션에 양쪽 규칙이 모두 포함됩니다. 규칙이 다른 도메인에서 동작하므로 충돌이 없습니다.

### Context Injection: 핵심 혁신

시스템의 아키텍처적 심장입니다. 각 파이프라인 단계마다 컨텍스트 조립을 오케스트레이션하는 **injection 파일**이 있습니다:

```
reference/injection/
  specify.md    — speckit-specify가 받는 컨텍스트
  plan.md       — speckit-plan이 받는 컨텍스트
  implement.md  — speckit-implement가 받는 컨텍스트
```

자연어 규칙을 위한 의존성 주입 컨테이너라고 생각하세요. injection 파일은 규칙을 담고 있지 않습니다 — 어떤 모듈을 로드할지, 어떤 GEL 아티팩트를 포함할지, 어떤 단계별 지시를 추가할지 선언합니다.

**예시: ai-assistant + gui + realtime 프로젝트에서 `speckit-specify`가 실행될 때:**

1. Injection 파일이 `_core.md` § S1 로드 — 보편 SC 생성 규칙
2. `gui.md` § S1 로드 — "모든 폼에 검증 피드백 SC, 모든 내비게이션에 라우트 가드 SC"
3. `realtime.md` § S1 로드 — "모든 스트리밍 디스플레이에: 시작 표시, 진행 업데이트, 완료 신호, 에러 폴백, 재연결 로직"
4. `ai-assistant` § A2 로드 — "프로바이더 추상화에: 멀티 프로바이더 SC, Rate Limit 처리 SC, 토큰 예산 관리 SC"
5. 단계별 규칙 추가: Brief → SC 매핑, 정교화 프로브, SC 번호 규칙
6. GEL 컨텍스트 포함: 기존 entity-registry.md, api-registry.md
7. Feature 컨텍스트 포함: 이 Feature의 pre-context.md

결과: speckit-specify가 이 특정 프로젝트의 필요를 반영하는 맞춤 컨텍스트를 받습니다. 다른 프로젝트 — 예를 들어 cli + resilience + microservice — 는 같은 injection 메커니즘을 통해 완전히 다른 규칙을 받게 됩니다.

---

## 확장성: Convention over Configuration

### 새 Concern 모듈 추가

기존 concern에 맞지 않는 횡단 패턴을 발견했다고 합시다 — 예를 들어 `rate-limiting`을 독립적인 concern으로. 하는 일은:

1. `domains/concerns/rate-limiting.md` 생성
2. 스키마에 따라 섹션 추가:
   - S0: Signal Keywords (코드에서 이 concern을 감지하는 방법)
   - S1: SC Generation Rules (이 concern이 활성화되면 어떤 SC를 생성할지)
   - S3: Verify Steps (이 concern이 활성화되면 추가할 검증)
   - S5: Elaboration Probes (Brief 상담 중 물어볼 질문)
   - S7: Bug Prevention Rules (이 concern의 흔한 안티패턴)
3. 끝입니다. 사용자의 Domain Profile에 `rate-limiting`이 포함되면 resolver가 자동으로 발견합니다.

코드 변경 없음. 등록 단계 없음. 설정 파일 업데이트 없음. 예상 경로에 파일이 존재하면 로드됩니다.

### 새 Foundation 추가

프레임워크 특화 규칙은 `domains/foundations/{framework}.md`에 두 가지 섹션으로 존재합니다:

- **F2** — Specify-time 규칙 (이 프레임워크가 스펙 생성에 부과하는 제약)
- **F3** — Implement-time 규칙 (프레임워크 관용구, 안티패턴, 도구 체인 설정)

예를 들어, `electron.md`의 F2에는 "메인 프로세스가 렌더러 크래시에서 살아남아야 한다"가 필수 아키텍처 원칙으로 포함됩니다. F3에는 "Playwright에 `_electron.launch()` 사용, 사용자 설정 보존을 위해 `--user-data-dir` 전달" 같은 내용이 있습니다.

### 커스텀 프로필 생성

프로필은 ~10줄의 매니페스트입니다:

```markdown
# Profile: my-ai-chat

interfaces: gui, http-api
concerns: auth, realtime, ai-assistants, external-sdk
archetype: ai-assistant
foundation: nextjs
scenario: greenfield
scale:
  project_maturity: mvp
  team_context: solo
```

`domains/profiles/my-ai-chat.md`에 저장하고, `/smart-sdd init --profile my-ai-chat`로 사용합니다. resolver가 프로필을 읽고 선언된 모든 모듈을 로드합니다.

### 3단계 규칙 계층

규칙은 세 가지 수준에서 올 수 있으며, 후순위가 선순위를 오버라이드합니다:

1. **스킬 수준** — `_core.md` + 도메인 모듈 (보편적, 프로젝트가 관리)
2. **조직 수준** — `org-convention.md` (조직의 프로젝트 전체에 공유)
3. **프로젝트 수준** — `domain-custom.md` (하나의 프로젝트에 특화)

이는 회사가 조직 전체 규칙(네이밍 패턴, API 설계 표준, 보안 요구사항)을 정의하면 spec-kit-skills를 사용하는 모든 프로젝트에 자동 적용되고, 개별 프로젝트는 특정 규칙을 오버라이드할 수 있다는 뜻입니다.

---

## Pipeline Integrity Guards

7개의 가드가 파이프라인의 정확성을 강제합니다. 각각 특정 전환 지점에서의 차단 검사입니다:

**Constitution Guard.** specify 전: 헌법이 정의되어 있는가? 없으면 스펙에 지도 원칙이 없습니다.

**Entity Registry Guard.** plan 전: 스펙의 모든 엔티티가 등록되었는가? 없으면 플랜이 기존 데이터 모델을 참조할 수 없습니다.

**API Registry Guard.** implement 전: 플랜의 모든 API가 등록되었는가? 없으면 구현이 계약을 추측합니다.

**Pre-Context Guard.** specify 전: 이 Feature의 프리컨텍스트가 존재하는가? 없으면 스펙의 근거가 없습니다.

**Dependency Order Guard.** pipeline 전: 이 Feature의 의존성이 완료되었는가? 없으면 구현이 아직 존재하지 않는 엔티티를 참조합니다.

**Augmentation Guard.** `add --to` 후: 파이프라인이 재실행되었는가? 없으면 스펙이 새 요구사항을 반영하지 않습니다.

**Regression Guard.** verify에서 이슈 발견 후: 회귀가 해결되었는가? 없으면 알려진 버그가 이월됩니다.

각 가드는 같은 패턴을 따릅니다: 조건 확인 → 실패하면 차단 메시지 표시 → 조건이 충족될 때까지 에이전트 진행 불가.

---

## 🤖 에이전트를 위한 글 — 아키텍처 참조

```
architecture:
  principles:
    P1 Context Continuity:
      P1-a: Domain Profile이 first-class (모듈 섹션을 통해 모든 파이프라인 단계를 형성)
      P1-b: Artifact Separation (스펙은 무엇을 기술, 어디서 왔는지는 기술하지 않음)
      P1-c: GEL 파일을 통한 Cross-Feature Memory (entity-registry, api-registry, sdd-state)

    P2 Enforce Don't Reference:
      요구사항: 모든 핵심 규칙에 3개 레이어 필요
        레이어 1: 실행 지점에 인라인 지시
        레이어 2: 차단 게이트 (경고가 아님 — 구조적 차단)
        레이어 3: 안티패턴 예시 (WRONG 다음 RIGHT)
      증거: HARD STOP 텍스트가 30회 이상 등장 (각각 다른 실행 지점)
      이유: 에이전트가 참조를 선택적 읽기로 취급
      따름정리: 에이전트 스킬에서 DRY는 컴플라이언스를 죽임

    P3 File over Memory:
      요구사항: 모든 상태를 파일에 (sdd-state.md, 레지스트리, 프리컨텍스트)
      이유: 컨텍스트 윈도우는 유한하고, 세션 범위이며, 검사 불가
      이점: git diff = 완전한 감사 추적, 세션 간 영속, 사람이 편집 가능

  파일 구조:
    SKILL.md: ~200줄, 항상 로드 (라우팅 + 필수 규칙)
    commands/: 호출별 로드 (~500줄)
    reference/injection/: 파이프라인 단계별 컨텍스트 조립 (자연어 규칙의 DI 컨테이너)
    domains/: Domain Profile별 로드 (3~5개 모듈에 ~400줄)

  도메인 모듈 시스템:
    로딩 순서: _core → interfaces → concerns → archetypes → foundations → org → scenarios → custom
    섹션 스키마:
      interfaces/concerns: S0 (키워드), S1 (SC 규칙), S3 (검증), S5 (프로브), S7 (버그), S8 (런타임)
      archetypes: A0 (키워드), A1 (철학), A2 (SC 확장), A3 (프로브), A4 (헌법), A5 (Brief 기준)
    병합 규칙: append 의미론 (누적, 오버라이드 아님)
    선택: 활성 Domain Profile에 맞는 모듈만

  컨텍스트 예산:
    일반적: ~1,300줄 (SKILL.md + 커맨드 + 3~5개 모듈 + Feature 컨텍스트)
    최악의 경우: ~15,000줄 전부 로드 시 (선택적 로딩으로 회피)

  파이프라인 가드: 7개 (constitution, entity_registry, api_registry, pre_context,
                   dependency_order, augmentation, regression)
    패턴: 조건 확인 → 실패 시 → 차단 메시지 → 진행 불가

  확장성:
    concern 추가: domains/concerns/{name}.md에 S0~S9 작성 → 자동 발견
    foundation 추가: domains/foundations/{name}.md에 F2~F3 작성 → 자동 로드
    profile 추가: domains/profiles/{name}.md → --profile로 사용
    규칙 계층: 스킬 수준 → 조직 수준 → 프로젝트 수준 (후순위가 선순위 오버라이드)
```

---

*다음 편: **4편 — 실패 패턴과 팁** — 19가지 갭 패턴과 50개 이상의 구체적 교훈. 실제 실패, 실제 수정, 그리고 자신만의 에이전트 워크플로우를 만드는 모든 사람을 위한 범용적 시사점.*
