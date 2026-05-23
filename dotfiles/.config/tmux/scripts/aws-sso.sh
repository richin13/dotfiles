#!/bin/bash

function aws_sso_status {
  if [[ "$DISTRO" != "ubuntu" ]]; then
    return
  fi
  local cache_dir="$HOME/.aws/sso/cache"
  local now
  now=$(date -u +%s)

  for f in "$cache_dir"/*.json; do
    [ -f "$f" ] || continue
    local expires_at
    expires_at=$(python3 -c "
import json, sys
with open('$f') as fh:
    data = json.load(fh)
if 'expiresAt' in data and 'startUrl' in data:
    print(data['expiresAt'])
" 2>/dev/null)

    [ -z "$expires_at" ] && continue

    local exp_epoch
    exp_epoch=$(date -u -d "${expires_at}" +%s 2>/dev/null)
    [ -z "$exp_epoch" ] && continue

    if [ "$exp_epoch" -gt "$now" ]; then
      return
    fi
  done

  echo "#[fg=colour1,strikethrough]SSO#[default]"
}

aws_sso_status
