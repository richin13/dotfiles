---
name: incremental-discovery
description: This skill should be used when the user asks to "investigate something incrementally", "start a discovery journal", "journal my findings", "explore this step by step and write it down", "create a research journal", or wants to build understanding of a problem through guided, step-by-step investigation with findings persisted to a journal file.
---

# Incremental Discovery

Begin an incremental discovery investigation for: **$ARGUMENTS**

Incremental discovery is a workflow for approaching complex problems through guided, step-by-step investigation. Findings from each step are persisted to a markdown journal file, building a cumulative knowledge base that survives context and can be referenced later.

## Workflow

### 1. Initialize the Journal

Using the problem statement above:

1. Derive a short, descriptive kebab-case filename from the topic (e.g., `api-auth-flow.journal.md`, `database-schema.journal.md`). Always use the `.journal.md` extension.
2. Create the journal file in the current working directory with a brief preamble:

```markdown
<!-- Journal: {topic} -->
<!-- Created: {date} -->
```

3. Inform the user of the journal filename and confirm the first area to investigate.

### 2. Investigate a Step

For each step the user requests:

1. Perform the investigation using available tools (reading files, searching code, fetching docs, etc.)
2. Synthesize findings into clear, structured markdown
3. Append findings to the journal using the append script

### 3. Append to Journal

Use the bundled script to append entries. The script reads content from stdin and handles header nesting automatically.

```bash
python3 {skill_dir}/scripts/append_journal.py <journal_file> "<entry_title>" <<'JOURNAL_EOF'
# Section heading
Content goes here...
JOURNAL_EOF
```

Replace `{skill_dir}` with the absolute path to this skill's directory.

**What the script does:**
- Prepends an H1 heading: `# Journal Entry #{n} - {entry_title}` (auto-incremented)
- Increments all markdown headers in the content by 1 level (H1 becomes H2, H2 becomes H3, etc.)
- Appends the entry to the journal file, creating it if it does not exist

### 4. Continue or Conclude

After each step:
- Summarize what was found
- Suggest logical next steps based on current findings
- Wait for the user to direct the next area of investigation

The user drives the process. Do not investigate ahead without direction.

## Writing Journal Entries

Each journal entry should be:

- **Self-contained**: Readable without needing to re-read prior entries
- **Structured**: Use headers, lists, and code blocks for clarity
- **Factual**: Record what was found, not speculation
- **Concise**: Include relevant details, skip noise

When writing content for journal entries, use H1 (`#`) for top-level sections within the entry. The append script will automatically nest these under the timestamped entry heading.

## Scripts

### `scripts/append_journal.py`

Appends a timestamped, header-adjusted entry to a journal file. Accepts content via stdin or file argument. See "Append to Journal" above for usage.
