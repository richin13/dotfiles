#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Promote a GitHub Projects draft item into a real repository issue.

Workflow:
1) Read draft title/body from project item ID
2) Create issue in target repo
3) Add issue back to the same project
4) Optionally set status for the new project item
5) Archive original draft item (default)

Usage:
  promote_draft_to_issue.sh \
    --owner <OWNER> \
    --project <PROJECT_NUMBER> \
    --item-id <DRAFT_ITEM_ID> \
    --repo <OWNER/REPO> \
    [--title-override "<TITLE>"] \
    [--body-file <PATH>] \
    [--status-field "Status"] \
    [--status-option "Todo"] \
    [--labels "bug,help wanted"] \
    [--assignees "@me,octocat"] \
    [--keep-draft] \
    [--dry-run]

Required:
  --owner       GitHub user or org login owning the project
  --project     Project number (not node ID)
  --item-id     Draft item ID in the project
  --repo        Target repository (OWNER/REPO)

Optional:
  --title-override Use this title instead of the draft title
  --body-file      Read issue body from file instead of draft body
  --status-field  Single-select field name used when status option is provided (default: Status)
  --status-option Single-select option to set on the new item (skip by default)
  --labels        Comma-separated labels for issue creation
  --assignees     Comma-separated assignees for issue creation
  --keep-draft    Do not archive the original draft item
  --dry-run       Print planned actions without creating/updating anything
  --limit         Max items to scan for item lookup (default: 200)
  --help          Show this help
EOF
}

fail() {
  echo "Error: $*" >&2
  exit 1
}

OWNER=""
PROJECT_NUMBER=""
ITEM_ID=""
REPO=""
TITLE_OVERRIDE=""
BODY_FILE=""
STATUS_FIELD="Status"
STATUS_OPTION=""
LABELS=""
ASSIGNEES=""
ARCHIVE_DRAFT=true
DRY_RUN=false
LIST_LIMIT=200

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
    --item-id)
      ITEM_ID="${2-}"
      shift 2
      ;;
    --repo)
      REPO="${2-}"
      shift 2
      ;;
    --title-override)
      TITLE_OVERRIDE="${2-}"
      shift 2
      ;;
    --body-file)
      BODY_FILE="${2-}"
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
    --labels)
      LABELS="${2-}"
      shift 2
      ;;
    --assignees)
      ASSIGNEES="${2-}"
      shift 2
      ;;
    --keep-draft)
      ARCHIVE_DRAFT=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --limit)
      LIST_LIMIT="${2-}"
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
[[ -n "$ITEM_ID" ]] || fail "--item-id is required"
[[ -n "$REPO" ]] || fail "--repo is required"
[[ "$LIST_LIMIT" =~ ^[0-9]+$ ]] || fail "--limit must be an integer"
if [[ -n "$BODY_FILE" && ! -f "$BODY_FILE" ]]; then
  fail "--body-file does not exist: $BODY_FILE"
fi

command -v gh >/dev/null 2>&1 || fail "gh CLI is required but not found in PATH"

DRAFT_TITLE="$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --limit "$LIST_LIMIT" --format json --jq ".items[] | select(.id==\"$ITEM_ID\") | .title // empty" | head -n1)"
[[ -n "$DRAFT_TITLE" ]] || fail "Draft item not found (or not loaded within --limit $LIST_LIMIT): $ITEM_ID"

CONTENT_URL="$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --limit "$LIST_LIMIT" --format json --jq ".items[] | select(.id==\"$ITEM_ID\") | .content.url // empty" | head -n1 || true)"
[[ -z "$CONTENT_URL" ]] || fail "Item $ITEM_ID is already linked (content URL present), not a draft"

DRAFT_BODY="$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --limit "$LIST_LIMIT" --format json --jq ".items[] | select(.id==\"$ITEM_ID\") | .body // \"\"")"

ISSUE_TITLE="$DRAFT_TITLE"
if [[ -n "$TITLE_OVERRIDE" ]]; then
  ISSUE_TITLE="$TITLE_OVERRIDE"
fi

ISSUE_BODY="$DRAFT_BODY"
if [[ -n "$BODY_FILE" ]]; then
  ISSUE_BODY="$(cat "$BODY_FILE")"
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "dry_run=true"
  echo "owner=$OWNER"
  echo "project_number=$PROJECT_NUMBER"
  echo "draft_item_id=$ITEM_ID"
  echo "repo=$REPO"
  echo "title=$ISSUE_TITLE"
  if [[ -n "$STATUS_OPTION" ]]; then
    echo "status_field=$STATUS_FIELD"
    echo "status_option=$STATUS_OPTION"
  fi
  if [[ -n "$LABELS" ]]; then
    echo "labels=$LABELS"
  fi
  if [[ -n "$ASSIGNEES" ]]; then
    echo "assignees=$ASSIGNEES"
  fi
  echo "archive_draft=$ARCHIVE_DRAFT"
  exit 0
fi

create_issue_cmd=(gh issue create --repo "$REPO" --title "$ISSUE_TITLE")
if [[ -n "$BODY_FILE" ]]; then
  create_issue_cmd+=(--body-file "$BODY_FILE")
else
  create_issue_cmd+=(--body "$ISSUE_BODY")
fi
if [[ -n "$LABELS" ]]; then
  create_issue_cmd+=(--label "$LABELS")
fi
if [[ -n "$ASSIGNEES" ]]; then
  create_issue_cmd+=(--assignee "$ASSIGNEES")
fi

ISSUE_URL="$("${create_issue_cmd[@]}" | tail -n1)"
[[ -n "$ISSUE_URL" ]] || fail "Failed to create issue in $REPO"

NEW_ITEM_ID="$(gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$ISSUE_URL" --format json --jq '.id')"
[[ -n "$NEW_ITEM_ID" ]] || fail "Issue created but failed to add it to project"

if [[ -n "$STATUS_OPTION" ]]; then
  PROJECT_ID="$(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.id')"
  [[ -n "$PROJECT_ID" ]] || fail "Could not resolve project ID"

  STATUS_FIELD_ID="$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq ".fields[] | select(.name==\"$STATUS_FIELD\") | .id" | head -n1)"
  [[ -n "$STATUS_FIELD_ID" ]] || fail "Could not find field '$STATUS_FIELD'"

  STATUS_OPTION_ID="$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq ".fields[] | select(.name==\"$STATUS_FIELD\") | .options[] | select(.name==\"$STATUS_OPTION\") | .id" | head -n1)"
  [[ -n "$STATUS_OPTION_ID" ]] || fail "Could not find option '$STATUS_OPTION' in field '$STATUS_FIELD'"

  gh project item-edit \
    --id "$NEW_ITEM_ID" \
    --project-id "$PROJECT_ID" \
    --field-id "$STATUS_FIELD_ID" \
    --single-select-option-id "$STATUS_OPTION_ID" >/dev/null
fi

if [[ "$ARCHIVE_DRAFT" == true ]]; then
  gh project item-archive "$PROJECT_NUMBER" --owner "$OWNER" --id "$ITEM_ID" >/dev/null
fi

echo "draft_item_id=$ITEM_ID"
echo "issue_url=$ISSUE_URL"
echo "new_item_id=$NEW_ITEM_ID"
echo "archived_draft=$ARCHIVE_DRAFT"
