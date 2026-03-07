#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Create a GitHub Projects draft item and move it to a single-select status option.

Usage:
  create_backlog_item.sh \
    --owner <OWNER> \
    --project <PROJECT_NUMBER> \
    --title "<TITLE>" \
    --body "<BODY>" \
    [--status-field "Status"] \
    [--status-option "Backlog"]

Required:
  --owner         GitHub user or org login
  --project       Project number (not node ID)
  --title         Draft item title
  --body          Draft item body

Optional:
  --status-field  Single-select field name (default: Status)
  --status-option Single-select option name (default: Backlog)
  --help          Show this help
EOF
}

fail() {
  echo "Error: $*" >&2
  exit 1
}

OWNER=""
PROJECT_NUMBER=""
TITLE=""
BODY=""
STATUS_FIELD="Status"
STATUS_OPTION="Backlog"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner)
      OWNER="${2-}"
      shift 2
      ;;
    --project)
      PROJECT_NUMBER="${2-}"
      shift 2
      ;;
    --title)
      TITLE="${2-}"
      shift 2
      ;;
    --body)
      BODY="${2-}"
      shift 2
      ;;
    --status-field)
      STATUS_FIELD="${2-}"
      shift 2
      ;;
    --status-option)
      STATUS_OPTION="${2-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$OWNER" ]] || fail "--owner is required"
[[ -n "$PROJECT_NUMBER" ]] || fail "--project is required"
[[ -n "$TITLE" ]] || fail "--title is required"
[[ -n "$BODY" ]] || fail "--body is required"

command -v gh >/dev/null 2>&1 || fail "gh CLI is required but not found in PATH"

PROJECT_ID="$(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.id')"
[[ -n "$PROJECT_ID" ]] || fail "Could not resolve project ID"

STATUS_FIELD_ID="$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq ".fields[] | select(.name==\"$STATUS_FIELD\") | .id" | head -n1)"
[[ -n "$STATUS_FIELD_ID" ]] || fail "Could not find field '$STATUS_FIELD' in project $PROJECT_NUMBER"

STATUS_OPTION_ID="$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq ".fields[] | select(.name==\"$STATUS_FIELD\") | .options[] | select(.name==\"$STATUS_OPTION\") | .id" | head -n1)"
[[ -n "$STATUS_OPTION_ID" ]] || fail "Could not find option '$STATUS_OPTION' in field '$STATUS_FIELD'"

ITEM_ID="$(gh project item-create "$PROJECT_NUMBER" --owner "$OWNER" --title "$TITLE" --body "$BODY" --format json --jq '.id')"
[[ -n "$ITEM_ID" ]] || fail "Could not create draft item"

gh project item-edit \
  --id "$ITEM_ID" \
  --project-id "$PROJECT_ID" \
  --field-id "$STATUS_FIELD_ID" \
  --single-select-option-id "$STATUS_OPTION_ID" >/dev/null

echo "item_id=$ITEM_ID"
echo "project_id=$PROJECT_ID"
echo "status_field_id=$STATUS_FIELD_ID"
echo "status_option_id=$STATUS_OPTION_ID"
