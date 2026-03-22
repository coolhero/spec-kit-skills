# Medium 발행 가이드

> Medium 하루 발행 한도: 2편. 발행 순서대로 진행하되, 앞 편의 URL을 다음 편에 반영해야 함.

## 발행 현황

| # | 언어 | 파일 | 상태 | Medium URL |
|---|------|------|------|------------|
| 1 | EN | `articles/medium/part1-en.md` | ✅ 발행 완료 | https://medium.com/@thejihoonchoi/taming-the-ai-coder-why-your-agent-needs-a-harness-not-just-a-prompt-0869fa51da34 |
| 2 | EN | `articles/medium/part2-en.md` | 📝 Import 완료, Publish 대기 (하루 한도 소진) | — |
| 3 | EN | `articles/medium/part3-en.md` | 대기 (Part 2 URL 필요) | — |
| 4 | EN | `articles/medium/part4-en.md` | 대기 (Part 3 URL 필요) | — |
| 5 | KO | `articles/medium/part1-ko.md` | 대기 | — |
| 6 | KO | `articles/medium/part2-ko.md` | 대기 (KO Part 1 URL 필요) | — |
| 7 | KO | `articles/medium/part3-ko.md` | 대기 (KO Part 2 URL 필요) | — |
| 8 | KO | `articles/medium/part4-ko.md` | 대기 (KO Part 3 URL 필요) | — |

## 발행 절차 (편당 반복)

### Step 1: 이전 편 URL 반영

다음 편의 마크다운 파일에서 placeholder를 실제 URL로 교체:

```
# 예시: Part 3에 Part 2 URL 반영
파일: articles/medium/part3-en.md
찾기: (link to Part 2 on Medium)
교체: (https://medium.com/@thejihoonchoi/실제URL)
```

한국어도 동일한 패턴:
```
파일: articles/medium/part3-ko.md
찾기: (Medium 2편 링크로 교체)
교체: (https://medium.com/@thejihoonchoi/실제URL)
```

### Step 2: Gist 생성

1. https://gist.github.com 접속
2. Filename: `part{N}-{en|ko}.md`
3. 해당 마크다운 파일 내용 전체 붙여넣기
4. **Create public gist** 클릭

### Step 3: Medium Import

1. https://medium.com/p/import 접속
2. Gist URL 붙여넣기
3. Import 클릭

### Step 4: Medium 에디터에서 확인

- 제목/부제목이 정상 표시되는지
- 이미지가 로드됐는지 (안 됐으면 수동 드래그앤드롭)
- 코드 블록이 정상인지

### Step 5: 발행 설정

- **Title**: 마크다운의 `#` 제목 (자동 인식됨)
- **Subtitle**: `##` 부제목 (자동 인식됨)
- **Topics** (EN): `Artificial Intelligence`, `Software Engineering`, `Claude`, `Developer Tools`, `Coding`
- **Topics** (KO): `AI`, `소프트웨어개발`, `Claude`, `개발도구`, `Coding`
- **Set as pre-release**: 체크 안 함 (정식 발행)
- **Publish** 클릭

### Step 6: URL 기록

발행 후 URL을 이 파일의 발행 현황 테이블에 기록.

## 일정 계획 (하루 2편 한도)

| 날짜 | 발행 대상 |
|------|----------|
| Day 1 (완료) | EN Part 1 ✅, EN Part 2 (Import 완료, Publish 대기) |
| Day 2 | EN Part 2 Publish + EN Part 3 |
| Day 3 | EN Part 4, KO Part 1 |
| Day 4 | KO Part 2, KO Part 3 |
| Day 5 | KO Part 4 |

## Claude Code에서 작업 시 지시

새 세션에서 다음과 같이 요청:

```
Medium 아티클 발행을 이어서 진행해줘.
articles/PUBLISH-GUIDE.md를 읽고 다음 발행 대상의 placeholder를 교체하고 안내해줘.
```

## 주의사항

- Gist에 이미지는 직접 포함 불가 → 마크다운에 GitHub raw URL 사용 (이미 반영됨)
- Medium이 이미지를 못 가져오면 에디터에서 수동 드래그앤드롭
- 기존 발행 글 수정: Medium에서 해당 글 → Edit → 수정 → Save (URL 유지됨)
- Part 1 EN 하단에 Part 2 URL을 추가하려면 Medium에서 직접 Edit
