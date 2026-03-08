# Project Rules — spec-kit-skills

## Do NOT Modify (Permanent)

1. **HARD STOP 인라인 텍스트**: `**If response is empty → re-ask** (per MANDATORY RULE 1)` 같은 인라인 HARD STOP 재질문 텍스트를 축약하거나 센티널로 대체하지 마세요. 30+ 곳에 반복되더라도 그대로 유지해야 합니다. 에이전트가 reference 파일의 규칙을 무시하는 경향이 있어 의도적으로 인라인 처리한 것입니다.

2. **domains/data-science.md**: reverse-spec과 smart-sdd 양쪽 모두 TODO 스캐폴딩이 의도적으로 남아있습니다. 향후 구현 예정이므로 삭제하거나 placeholder로 축소하지 마세요.

## Design Principles

- **에이전트 워킹 메모리 대신 파일에 기록**: Phase 간 전달되는 중간 산출물은 에이전트 메모리에 보관하지 않고 반드시 파일로 저장합니다. 에이전트 메모리는 컨텍스트 윈도우 한계, 세션 단절, Phase 간 정보 손실에 취약합니다. 파일로 저장하면 언제든 다시 읽을 수 있고, 사용자가 내용을 직접 확인·수정할 수 있으며, 다른 세션에서도 활용 가능합니다.

## Language

- **All artifacts MUST be written in English.** This includes skill files (SKILL.md, commands/*.md, reference/*.md, domains/*.md, templates/*.md), TODO.md, history.md, MCP-GUIDE.md, and all other project files.
- **Exception**: `README.ko.md` is the only file written in Korean.
- User-facing AskUserQuestion option labels may use Korean if contextually appropriate for Korean-speaking users, but the surrounding documentation and comments must be in English.

## Conventions

- 변경 시 항상 `specs/history.md`에 이력을 기록합니다.
- README.md와 README.ko.md는 항상 동기화 상태를 유지합니다.
- README 수정 시 `Last updated:` 타임스탬프를 **반드시** 현재 시간으로 갱신합니다. `date '+%Y-%m-%d %H:%M KST'` 명령으로 실제 시간을 확인한 후 적용하세요. 추측하지 마세요.
- 스크립트(`scripts/*.sh`)는 dead code로 판단하지 말고, 사용처를 확인하거나 연결해야 합니다.
- Dead reference는 삭제가 아니라 연결(connect)하는 방향으로 처리합니다.

## Review Protocol

전체 파일 검토 시에는 우선 전체적인 flow 상의 이상이 없는지, 불일치하는지를 검토하고,
현재 활용되지 않는 부분은 원래 활용이 되야하는데 활용이 안되는건지 부터 검토하고 그 이후에 필요 없는 부분인지 검토해야하고
공통화나 스크립트화를 통해 context 효율성을 검토한다.
