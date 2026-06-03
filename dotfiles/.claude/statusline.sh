#!/bin/bash
# Read JSON data that Claude Code sends to stdin
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')

# 1M context feature flag
ONE_M=""
[[ "$MODEL" == *"[1m]"* || "$MODEL" == *"1M context"* ]] && ONE_M="/1m"

# Map inference profile ARNs to a family name. The ARN carries no version,
# so show only the family (opus/sonnet/haiku) to avoid a stale version label.
if [ -n "$ANTHROPIC_DEFAULT_OPUS_MODEL" ] && [[ "$MODEL" == *"${ANTHROPIC_DEFAULT_OPUS_MODEL##*/}"* ]]; then
  MODEL="opus"
elif [ -n "$ANTHROPIC_DEFAULT_SONNET_MODEL" ] && [[ "$MODEL" == *"${ANTHROPIC_DEFAULT_SONNET_MODEL##*/}"* ]]; then
  MODEL="sonnet"
elif [ -n "$ANTHROPIC_DEFAULT_HAIKU_MODEL" ] && [[ "$MODEL" == *"${ANTHROPIC_DEFAULT_HAIKU_MODEL##*/}"* ]]; then
  MODEL="haiku"
else
  MODEL="${MODEL#claude-}"
  MODEL="${MODEL%% \[1m\]}"
  MODEL="${MODEL%\[1m\]}"
  MODEL="${MODEL%% (1M context)}"
fi

PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Shorten CWD to the last 2 path levels, with $HOME as ~
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
if [[ "$DIR" == "$HOME"* ]]; then
  SHORT_DIR="~${DIR#$HOME}"
else
  SHORT_DIR="$DIR"
fi
if [[ "$SHORT_DIR" == */?*/* ]]; then
  base="${SHORT_DIR##*/}"
  parent="${SHORT_DIR%/*}"
  parent="${parent##*/}"
  SHORT_DIR="$parent/$base"
fi

# Git branch with starship's icon, trimmed to a max length
BRANCH_SEG=""
BRANCH=$(git -C "$DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
  MAXLEN=24
  [ ${#BRANCH} -gt $MAXLEN ] && BRANCH="${BRANCH:0:$MAXLEN}…"
  BRANCH_SEG=" | $(printf '') $BRANCH"
fi

echo "$SHORT_DIR$BRANCH_SEG | $MODEL ${PCT}%${ONE_M}"
