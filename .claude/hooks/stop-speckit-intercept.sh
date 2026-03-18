#!/bin/bash
# Stop hook: Detect when agent stops with spec-kit raw output instead of Review
#
# Problem: spec-kit commands (specify, plan, tasks, analyze, implement) print
# their own "Next Actions" / "Proceed to /speckit.*" messages. smart-sdd MUST
# suppress these and continue to Review (MANDATORY RULE 3). When the agent
# stops with this output visible, Execute+Review continuity is broken.
#
# Solution: This hook checks last_assistant_message for spec-kit navigation
# patterns. If found, it blocks the stop and instructs the agent to continue
# to the Review step.
#
# Input: JSON on stdin with last_assistant_message and stop_hook_active fields
# Output: JSON with decision:"block" to force continuation, or exit 0 to allow stop

set -euo pipefail

INPUT=$(cat)

# Prevent infinite loop: if already continuing from a previous Stop hook, allow stop
STOP_ACTIVE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('stop_hook_active', False))
except:
    print('False')
" 2>/dev/null)

if [ "$STOP_ACTIVE" = "True" ] || [ "$STOP_ACTIVE" = "true" ]; then
    exit 0
fi

# Extract last assistant message
LAST_MSG=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('last_assistant_message', ''))
except:
    print('')
" 2>/dev/null)

# Check for spec-kit navigation patterns that should have been suppressed
if echo "$LAST_MSG" | grep -qiE \
    "(Next Actions|Recommendation:.*Proceed to /speckit|Ready for /speckit|Next phase:|Suggested commit:|Coverage:.*functional requirements|No \[NEEDS CLARIFICATION\]|Spec created and validated|Plan created|Tasks generated)"; then

    # Also check it's NOT already showing a Review (AskUserQuestion present = correct flow)
    if echo "$LAST_MSG" | grep -qiE "(AskUserQuestion|ReviewApproval|approve|Type \"continue\")"; then
        # Review is present — agent is doing the right thing, allow stop
        exit 0
    fi

    # Agent stopped with spec-kit raw output and no Review — force continuation
    cat <<'EOF'
{
    "decision": "block",
    "reason": "⚠️ MANDATORY RULE 3 VIOLATION: spec-kit raw output detected without Review. You MUST: (1) SUPPRESS the spec-kit navigation messages shown above, (2) Read the generated artifact file, (3) Display the Review content, (4) Call AskUserQuestion with ReviewApproval options. If context limit prevents this, show the fallback: '✅ [command] executed.\n💡 Type \"continue\" to review the results.' Do NOT stop with spec-kit output visible."
}
EOF
    exit 0
fi

# No spec-kit pattern detected — allow stop
exit 0
