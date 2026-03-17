#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Download and visualize state/runtime-trace.jsonl from a ZeroClaw host."""

import argparse
import json
import os
import subprocess
import sys
import tempfile
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer

DEFAULT_WORKSPACE = "~/.zeroclaw/workspace"
TRACE_REL_PATH = "state/runtime-trace.jsonl"
DEFAULT_PORT = 7979


def fetch_trace(host: str, remote_path: str) -> list[dict]:
    with tempfile.NamedTemporaryFile(suffix=".jsonl", delete=False) as tmp:
        tmp_path = tmp.name
    try:
        result = subprocess.run(
            ["scp", f"{host}:{remote_path}", tmp_path],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            sys.exit(f"scp failed: {result.stderr.strip()}")
        events = []
        with open(tmp_path) as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        events.append(json.loads(line))
                    except json.JSONDecodeError as e:
                        print(f"skipping malformed line: {e}", file=sys.stderr)
        return events
    finally:
        os.unlink(tmp_path)


def build_html(events: list[dict]) -> str:
    events_json = json.dumps(events)
    count = len(events)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>runtime-trace ({count} events)</title>
<style>
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
body {{ font-family: 'SF Mono', 'Menlo', 'Consolas', monospace; font-size: 12px; background: #0f1117; color: #e2e8f0; }}
header {{
  padding: 14px 20px; background: #1a1d27; border-bottom: 1px solid #252836;
  display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
}}
header h1 {{ font-size: 13px; font-weight: 600; color: #64748b; white-space: nowrap; }}
header h1 span {{ color: #e2e8f0; }}
.filters {{ display: flex; gap: 8px; flex: 1; flex-wrap: wrap; }}
input[type=text], select {{
  background: #0f1117; border: 1px solid #252836; border-radius: 4px;
  color: #e2e8f0; padding: 5px 10px; font-family: inherit; font-size: 12px; outline: none;
}}
input[type=text] {{ flex: 1; min-width: 160px; }}
input[type=text]:focus, select:focus {{ border-color: #4f5d8a; }}
#count {{ color: #475569; font-size: 11px; white-space: nowrap; }}
table {{ width: 100%; border-collapse: collapse; }}
thead th {{
  padding: 7px 12px; text-align: left; color: #475569; font-weight: 500;
  border-bottom: 1px solid #1e2130; font-size: 10px; letter-spacing: 0.06em; text-transform: uppercase;
}}
tbody tr {{ border-bottom: 1px solid #141720; cursor: pointer; transition: background 0.1s; }}
tbody tr:hover {{ background: #1a1d27; }}
tbody tr.expanded {{ background: #1e2130; }}
td {{ padding: 6px 12px; vertical-align: middle; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }}
tr.payload-row td {{ padding: 0; background: #12141f; border-bottom: 1px solid #1e2130; }}
tr.payload-row pre {{
  padding: 10px 16px 10px 28px; font-size: 11px; color: #7c8db5;
  overflow-x: auto; border-left: 2px solid #2d3148; margin-left: 12px; line-height: 1.6;
}}
.badge {{
  display: inline-block; padding: 2px 6px; border-radius: 3px;
  font-size: 10px; font-weight: 600; letter-spacing: 0.03em; white-space: nowrap;
}}
.badge-agent   {{ background: #1e3a5f; color: #60a5fa; }}
.badge-llm     {{ background: #2e1b5f; color: #a78bfa; }}
.badge-tool    {{ background: #3d2a00; color: #fbbf24; }}
.badge-hand    {{ background: #0d3d3d; color: #2dd4bf; }}
.badge-channel {{ background: #0d3322; color: #4ade80; }}
.badge-cache   {{ background: #1e2333; color: #94a3b8; }}
.badge-error   {{ background: #3d1010; color: #f87171; }}
.badge-other   {{ background: #1e2333; color: #94a3b8; }}
.ok   {{ color: #4ade80; }}
.fail {{ color: #f87171; }}
.dim  {{ color: #334155; }}
.ts   {{ color: #334155; font-size: 11px; min-width: 100px; }}
.model {{ color: #7c8db5; max-width: 200px; }}
.ctx  {{ color: #475569; max-width: 180px; }}
.msg  {{ color: #cbd5e1; max-width: 380px; }}
.empty {{ padding: 60px; text-align: center; color: #334155; }}
</style>
</head>
<body>
<header>
  <h1>zeroclaw / <span>runtime-trace</span></h1>
  <div class="filters">
    <input type="text" id="search" placeholder="search…" />
    <select id="typeFilter"><option value="">all types</option></select>
  </div>
  <div id="count"></div>
</header>
<table>
  <thead>
    <tr>
      <th>time</th>
      <th>type</th>
      <th>context</th>
      <th>model</th>
      <th style="text-align:center">ok</th>
      <th>message</th>
    </tr>
  </thead>
  <tbody id="tbody"></tbody>
</table>
<div id="empty" class="empty" style="display:none">no matching events</div>
<script>
const EVENTS = {events_json};

const BADGE = t => {{
  if (t.startsWith('agent'))   return 'badge-agent';
  if (t.startsWith('llm'))     return 'badge-llm';
  if (t.startsWith('tool'))    return 'badge-tool';
  if (t.startsWith('hand'))    return 'badge-hand';
  if (t.startsWith('channel')) return 'badge-channel';
  if (t.startsWith('cache'))   return 'badge-cache';
  if (t === 'error')           return 'badge-error';
  return 'badge-other';
}};

const fmt = ts => {{
  const d = new Date(ts);
  return d.toLocaleTimeString('en-GB', {{hour12:false,hour:'2-digit',minute:'2-digit',second:'2-digit'}})
       + '.' + String(d.getMilliseconds()).padStart(3,'0');
}};

const esc = s => String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');

const PAYLOAD_SKIP = new Set(['event_type','timestamp','message','success','channel','provider','model','id','turn_id']);

const tbody   = document.getElementById('tbody');
const searchEl = document.getElementById('search');
const typeEl  = document.getElementById('typeFilter');
const countEl = document.getElementById('count');
const emptyEl = document.getElementById('empty');

[...new Set(EVENTS.map(e => e.event_type))].sort().forEach(t => {{
  const o = document.createElement('option');
  o.value = t; o.textContent = t;
  typeEl.appendChild(o);
}});

let openIdx = null;

function render() {{
  const q  = searchEl.value.toLowerCase();
  const tf = typeEl.value;

  const rows = EVENTS.filter(e => {{
    if (tf && e.event_type !== tf) return false;
    if (q) {{
      const hay = [e.event_type, e.message, e.channel, e.provider, e.model, e.turn_id, JSON.stringify(e.payload)]
        .filter(Boolean).join(' ').toLowerCase();
      if (!hay.includes(q)) return false;
    }}
    return true;
  }});

  countEl.textContent = rows.length + '\u2009/\u2009' + EVENTS.length + ' events';
  emptyEl.style.display = rows.length === 0 ? 'block' : 'none';
  tbody.innerHTML = '';
  openIdx = null;

  rows.forEach((e, idx) => {{
    const tr = document.createElement('tr');
    tr.dataset.idx = idx;

    const ctx = [e.channel, e.provider].filter(Boolean).join(' / ');
    const okCell = e.success === true  ? '<span class="ok">✓</span>'
                 : e.success === false ? '<span class="fail">✗</span>'
                 :                       '<span class="dim">–</span>';

    tr.innerHTML = `
      <td class="ts">${{fmt(e.timestamp)}}</td>
      <td><span class="badge ${{BADGE(e.event_type)}}">${{esc(e.event_type)}}</span></td>
      <td class="ctx">${{esc(ctx)}}</td>
      <td class="model">${{esc(e.model ?? '')}}</td>
      <td style="text-align:center">${{okCell}}</td>
      <td class="msg">${{esc(e.message ?? '')}}</td>
    `;

    tr.addEventListener('click', () => {{
      const existing = document.getElementById('pr-' + idx);
      if (existing) {{
        existing.remove();
        tr.classList.remove('expanded');
        openIdx = null;
        return;
      }}
      if (openIdx !== null) {{
        const old = document.getElementById('pr-' + openIdx);
        if (old) old.remove();
        const oldTr = tbody.querySelector(`[data-idx="${{openIdx}}"]`);
        if (oldTr) oldTr.classList.remove('expanded');
      }}
      openIdx = idx;
      tr.classList.add('expanded');

      const extra = Object.fromEntries(Object.entries(e).filter(([k]) => !PAYLOAD_SKIP.has(k)));
      const pr = document.createElement('tr');
      pr.className = 'payload-row';
      pr.id = 'pr-' + idx;
      const td = document.createElement('td');
      td.colSpan = 6;
      td.innerHTML = '<pre>' + esc(JSON.stringify(extra, null, 2)) + '</pre>';
      pr.appendChild(td);
      tr.after(pr);
    }});

    tbody.appendChild(tr);
  }});
}}

searchEl.addEventListener('input', render);
typeEl.addEventListener('change', render);
render();
</script>
</body>
</html>"""


def main() -> None:
    parser = argparse.ArgumentParser(description="Visualize ZeroClaw runtime-trace.jsonl")
    parser.add_argument("host", help="SSH host (e.g. user@myserver.com)")
    parser.add_argument(
        "--workspace",
        default=DEFAULT_WORKSPACE,
        metavar="PATH",
        help=f"remote workspace directory (default: {DEFAULT_WORKSPACE})",
    )
    parser.add_argument(
        "--remote-path",
        default=None,
        metavar="PATH",
        help=f"full remote path; overrides --workspace (default: WORKSPACE/{TRACE_REL_PATH})",
    )
    parser.add_argument("--port", type=int, default=DEFAULT_PORT, metavar="PORT")
    parser.add_argument("--no-open", action="store_true", help="don't open browser automatically")
    args = parser.parse_args()

    remote_path = args.remote_path or f"{args.workspace}/{TRACE_REL_PATH}"

    print(f"fetching {args.host}:{remote_path} …")
    events = fetch_trace(args.host, remote_path)
    print(f"loaded {len(events)} events")

    html = build_html(events)
    html_bytes = html.encode()

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self) -> None:
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(html_bytes)))
            self.end_headers()
            self.wfile.write(html_bytes)

        def log_message(self, *_) -> None:
            pass

    server = HTTPServer(("127.0.0.1", args.port), Handler)
    url = f"http://localhost:{args.port}"
    print(f"serving at {url}  (Ctrl-C to stop)")

    if not args.no_open:
        threading.Timer(0.3, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nstopped")


if __name__ == "__main__":
    main()
