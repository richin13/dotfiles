---
name: github-projects
description: Knowledge on how to work with Github projects. To be used when asked to "create a task in github project" or "add ticket to gh project" or similar.
---

# GitHub Projects Skill

## Prerequisites
- You know the project owner (`<OWNER>`) and project number (`<PROJECT_NUMBER>`).
- Helper scripts exist in `skills/github-projects/scripts/`.

## Execution Environment Rule
- Default behavior: run `gh` commands with escalation (`sandbox_permissions: "require_escalated"`).
- Reason: this environment often lacks the same auth/session context as the host shell, and escalated execution uses the user's loaded credentials.
- If a `gh` command works in sandbox, escalation is still preferred for consistency.
- When asking for approval, include a short justification that mentions accessing GitHub Projects with the user's authenticated `gh` session.
- Assume `gh` is configured correctly.

## Core Actions

### Create draft backlog item (default)

```bash
skills/github-projects/scripts/create_backlog_item.sh \
  --owner <OWNER> \
  --project <PROJECT_NUMBER> \
  --title "<TITLE>" \
  --body "<BODY>"
```

Optional status overrides:

```bash
skills/github-projects/scripts/create_backlog_item.sh \
  --owner <OWNER> \
  --project <PROJECT_NUMBER> \
  --title "<TITLE>" \
  --body "<BODY>" \
  --status-field "Status" \
  --status-option "Backlog"
```

### Promote draft to repository issue
Use when a draft task is ready to become implementation work in a repo.

```bash
skills/github-projects/scripts/promote_draft_to_issue.sh \
  --owner <OWNER> \
  --project <PROJECT_NUMBER> \
  --item-id <DRAFT_ITEM_ID> \
  --repo <OWNER/REPO>
```

Optional flags:
- `--status-option "<OPTION>"` (also supports `--status-field`)
- `--labels "bug,help wanted"`
- `--assignees "@me,octocat"`
- `--keep-draft` (default is archive draft)
- `--title-override "<TITLE>"`
- `--body-file /tmp/spec.md`
- `--dry-run`

## Workflow: Draft -> Discovery -> Issue
Use this when the draft is a quick todo and the real issue is written later with full context.

1. Read the project draft item (`title` + `body`).
2. Identify missing context and ask targeted questions.
3. Iterate with the user until the specification is implementation-ready.
4. Summarize and get explicit approval to create the issue.
5. Run `promote_draft_to_issue.sh` with final title/body (prefer `--body-file` for long specs).

### Discovery checklist
Gather these before creating the issue:
- Problem statement and desired outcome
- Scope in / scope out
- Technical approach and constraints
- Acceptance criteria
- Testing and validation plan
- Rollout, migration, or observability notes
- Dependencies, risks, and open questions

### Definition of ready
Only create/link the issue when:
- Required checklist sections are complete
- Open questions are either resolved or clearly captured
- Target repo is confirmed
- User explicitly approves issue creation

## Notes
- This skill is for effective GitHub Projects operation, not only draft promotion.
- Keep raw `gh project ...` commands out of responses unless explicitly requested.
- Prefer scripts for repeatable actions and consistent outputs.

## Ticket Style
Tickets contain little information, they precede an issue linked to them that contain all the implementation information.

- Title format: short, descriptive, no issue numbers or prefixes.
- Body sections required: brief description of what the feature or bug is about.
- Default status on creation: Backlog
