# Agent Browser Advanced Features

## Persistent Sessions (alternatives to --session-name)

### Profile (persists everything including IndexedDB, cache)

```bash
agent-browser --profile ~/.myapp-profile open https://localhost:3000/login
agent-browser --profile ~/.profiles/admin open https://localhost:3000
```

### State file (explicit save/load)

```bash
agent-browser state save ./auth.json
agent-browser state load ./auth.json && agent-browser open https://localhost:3000/dashboard
```

### Import from running Chrome

```bash
agent-browser --auto-connect state save ./auth.json
agent-browser --state ./auth.json open https://localhost:3000
```

### Auth vault (encrypted credential store)

```bash
echo "$PASSWORD" | agent-browser auth save myapp \
  --url https://localhost:3000/login \
  --username admin \
  --password-stdin

agent-browser auth login myapp
```

State files contain session tokens in plaintext. Add to `.gitignore`. Set `AGENT_BROWSER_ENCRYPTION_KEY` for encryption at rest.

## Viewport and Device Emulation

```bash
agent-browser set viewport 1280 720         # default
agent-browser set viewport 375 812          # mobile
agent-browser set viewport 1920 1080 2      # retina (2x pixel density)
agent-browser set device "iPhone 14"        # sets viewport + user agent
agent-browser --color-scheme dark open url  # dark mode
```

## Inspecting Elements

```bash
agent-browser get styles @e1               # computed CSS (font, color, bg, etc.)
agent-browser get box @e1                  # bounding box
agent-browser highlight @e1                # visually highlight element
```

## Diff (verify changes)

```bash
agent-browser snapshot -i                  # take baseline
agent-browser click @e2                    # perform action
agent-browser diff snapshot                # shows +/- changes in accessibility tree

agent-browser screenshot baseline.png
# ... make changes ...
agent-browser diff screenshot --baseline baseline.png  # pixel diff

agent-browser diff url https://staging.example.com https://prod.example.com
```

## Network Inspection and Mocking

```bash
agent-browser network requests                   # all tracked requests
agent-browser network requests --type xhr,fetch  # filter by type
agent-browser network requests --method POST     # filter by method
agent-browser network requests --status 4xx      # filter by status
agent-browser network route "**/api/users" --abort          # block requests
agent-browser network route "**/api/users" --body '{"data":[]}'  # mock response
agent-browser network har start && agent-browser network har stop ./capture.har
```

## Video Recording

```bash
agent-browser record start ./debug.webm
# ... interact ...
agent-browser record stop
```

## JavaScript Eval

```bash
agent-browser eval 'document.title'

# Complex JS via stdin to avoid shell escaping
agent-browser eval --stdin <<'EOF'
Array.from(document.querySelectorAll("img")).filter(i => !i.alt).map(i => i.src)
EOF
```

## Multiple Isolated Sessions

```bash
agent-browser --session user1 open https://localhost:3000
agent-browser --session user2 open https://localhost:3000
agent-browser session list
agent-browser --session user1 close
```

## Debugging

```bash
agent-browser --headed open https://localhost:3000  # show browser window
agent-browser console                               # view console logs
agent-browser errors                                # view page errors
agent-browser inspect                               # open Chrome DevTools
agent-browser --cdp 9222 snapshot                   # connect to existing Chrome via CDP
agent-browser --auto-connect snapshot               # auto-discover running Chrome
```

## JSON Output (for scripting)

```bash
agent-browser snapshot -i --json
agent-browser get url --json
```

## Config File

Place `agent-browser.json` in project root:

```json
{
  "headed": true,
  "profile": "./browser-data"
}
```

## Environment Variables

```
AGENT_BROWSER_HEADED=1               show browser window
AGENT_BROWSER_SESSION_NAME=myapp     auto-save/restore state by name
AGENT_BROWSER_DEFAULT_TIMEOUT=30000  action timeout in ms (default: 25000)
AGENT_BROWSER_ENCRYPTION_KEY=<hex>   64-char hex key for AES-256-GCM state encryption
AGENT_BROWSER_SCREENSHOT_DIR=./shots default screenshot directory
AGENT_BROWSER_COLOR_SCHEME=dark      dark/light/no-preference
```
