---
name: update-pr
description: This skill should be used when the user asks to "update the PR", "update PR body", "update PR title", "sync PR description", "update pull request", or wants the pull request title and body to reflect the actual changes on the current branch.
---

# Update PR

Analyze the current branch's changes and update the associated pull request's title and body to accurately reflect what was done.

## Prerequisites

- The current branch must have an open PR (both `gh pr view` and `gh pr edit` work without a PR number when on the associated branch)
- `gh` CLI is authenticated

## Workflow

### 1. Gather Context

Run these commands in parallel to understand the current state:

```bash
gh pr view --json number,title,body,headRefName,baseRefName
```

```bash
gh pr diff
```

```bash
git log <baseRefName>..HEAD --oneline
```

Use `baseRefName` from the PR view output as the base branch for the log and diff commands.

### 2. Analyze Changes

Review ALL commits and the full diff, not just the latest commit. Identify:

- The nature of each change (new feature, bug fix, refactor, cleanup, etc.)
- Group related changes into coherent bullet points
- Note any files or areas of the codebase affected

### 3. Draft Title and Body

**Title rules:**
- Under 70 characters
- Summarize the overall intent, not individual changes
- Use imperative mood ("Add X" not "Added X")
- Accurate verb choice: "add" for new features, "fix" for bugs, "update" for enhancements, "remove" for deletions, "refactor" for restructuring

**Body format:**

```markdown
## Summary
- <bullet points describing changes>

## Test plan
- [ ] <verification steps>

---
> Created by Claude Code 🤖
```

Keep bullet points concise. The summary should focus on "why" not "what" when possible. Test plan items should be actionable verification steps.

### 4. Present and Confirm

Show the drafted title and body to the user. Wait for explicit approval before applying.

### 5. Apply

Use the REST API directly to avoid a known GraphQL error where `gh pr edit` fails because it queries the deprecated "Projects (classic)" `projectCards` field:

```bash
gh api repos/<owner>/<repo>/pulls/<number> -X PATCH -f title="<title>" -f body="$(cat <<'EOF'
<body>
EOF
)" --jq '.html_url'
```

Always use a HEREDOC for the body to preserve formatting. Extract owner/repo from `gh repo view --json nameWithOwner --jq .nameWithOwner`.

After applying, return the PR URL from the output.
