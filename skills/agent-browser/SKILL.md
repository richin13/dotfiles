---
name: agent-browser
description: This skill should be used when the user asks to "open a browser", "navigate to a URL", "test the UI", "check a page", "browse a website", "take a screenshot", "fill a form", "click a button", or any browser automation task. Also triggered by CLAUDE.md directives like "Use 'agent-browser' when navigating".
---

# Agent Browser

Browser automation CLI for AI agents. Uses Chrome/Chromium via CDP.

## Session Strategy

Derive a session name from the current working directory basename to automatically persist and reuse browser state (cookies, localStorage) across invocations:

```bash
agent-browser --session-name "$(basename "$PWD")" open <url>
```

This avoids re-authenticating on every interaction. The session auto-saves on close and auto-restores on next open.

When a fresh session is needed (e.g., testing unauthenticated flows, clearing corrupted state):

```bash
agent-browser --session-name "$(basename "$PWD")-fresh" open <url>
```

## Core Loop

Every browser interaction follows this pattern:

1. Open a URL (reuses existing session)
2. Snapshot to discover interactive elements and their `@ref` handles
3. Interact (click, fill, select)
4. Snapshot again after any navigation or DOM change

```bash
agent-browser --session-name "$(basename "$PWD")" open https://example.com
agent-browser snapshot -i
agent-browser fill @e1 "user@example.com"
agent-browser click @e3
agent-browser snapshot -i
```

## Batching

Use `batch` for 2+ commands that don't need intermediate output:

```bash
agent-browser batch "fill @e1 \"email\"" "fill @e2 \"pass\"" "click @e3" "wait 2000"
agent-browser batch --bail "open https://example.com" "click @e1" "screenshot"
```

Run commands separately only when you need to read output before deciding the next step.

## Snapshots and Screenshots

```bash
agent-browser snapshot -i                   # interactive elements + @refs
agent-browser snapshot -i -s "#main"        # scope to CSS selector
agent-browser snapshot -i --urls            # include href URLs
agent-browser screenshot                    # save to temp dir
agent-browser screenshot /tmp/page.png      # save to specific path
agent-browser screenshot --full             # full page
agent-browser screenshot --annotate         # numbered labels on elements
```

Annotated screenshots show `[N]` labels mapped to `@eN` refs. Use when elements are unlabeled icons or visual-only.

## Interacting with Elements

```bash
agent-browser fill @e1 "text"              # fill input
agent-browser click @e3                    # click element
agent-browser get text @e1                 # read text content
agent-browser get value @e1                # read input value
agent-browser get attr @e1 href            # read attribute
```

## Semantic Locators (when refs are unavailable)

```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find placeholder "Search" type "query"
agent-browser find testid "submit-btn" click
```

## Waiting

```bash
agent-browser wait 2000                          # fixed delay (ms)
agent-browser wait "#spinner" --state hidden      # element disappears
agent-browser wait @e1                           # element appears
agent-browser wait --text "Results loaded"       # text appears
agent-browser wait --url "**/dashboard"          # URL pattern
```

Avoid `wait --load networkidle` as it hangs on sites with persistent websockets.

## Closing the Session

```bash
agent-browser close
```

State auto-saves when using `--session-name`. Next open with the same session name restores it.

## Additional Resources

### Reference Files

For advanced features (network mocking, viewport emulation, debugging, multiple sessions, JS eval, diffing, video recording):
- **`references/advanced-features.md`** - Complete command reference for all advanced capabilities
