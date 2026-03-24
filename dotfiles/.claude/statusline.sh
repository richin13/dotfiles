#!/bin/bash
# Read JSON data that Claude Code sends to stdin
input=$(cat)

# Extract fields using jq
MODEL=$(echo "$input" | jq -r '.model.display_name')

# Check if 1M context feature is enabled
ONE_M=""
[[ "$MODEL" == *"[1m]"* ]] && ONE_M=" +1M"

# Translate inference profile ARNs to friendly names using env vars if set
if [ -n "$ANTHROPIC_DEFAULT_OPUS_MODEL" ] && [[ "$MODEL" == *"${ANTHROPIC_DEFAULT_OPUS_MODEL##*/}"* ]]; then
  MODEL="opus 4.6"
elif [ -n "$ANTHROPIC_DEFAULT_SONNET_MODEL" ] && [[ "$MODEL" == *"${ANTHROPIC_DEFAULT_SONNET_MODEL##*/}"* ]]; then
  MODEL="sonnet 4.6"
elif [ -n "$ANTHROPIC_DEFAULT_HAIKU_MODEL" ] && [[ "$MODEL" == *"${ANTHROPIC_DEFAULT_HAIKU_MODEL##*/}"* ]]; then
  MODEL="haiku 4.5"
else
  MODEL="${MODEL#claude-}"
  MODEL="${MODEL%% \[1m\]}"
  MODEL="${MODEL%\[1m\]}"
fi

MODEL="${MODEL}${ONE_M}"
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
# The "// 0" provides a fallback if the field is null
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Output the status line - ${DIR##*/} extracts just the folder name
echo "📁 ${DIR##*/} | [$MODEL (${PCT}% context)]"
