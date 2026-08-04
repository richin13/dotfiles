---
name: new-feature
description: Explicit-only workflow for deep feature exploration. Use only when the user explicitly names `new-feature`.
disable-model-invocation: true
---

# Feature Exploration

Perform architectural exploration and requirement grilling for: **$ARGUMENTS**

You are about to implement a feature. Before writing any code or committing to an approach, you MUST complete two phases: exploration and grilling. Do not skip or abbreviate these phases. The goal is to surface hidden constraints, challenge the current architecture, and reach shared understanding with the user before any implementation begins.

## Phase 1: Architectural Exploration

Explore the codebase to answer these questions. Use tool calls (read files, grep, search) to gather real evidence. Do not guess or rely on memory alone.

### 1.1 Locate the seams

- Where in the existing code does this feature naturally attach?
- What modules, types, and interfaces will it touch?
- What are the public API boundaries it must respect?

### 1.2 Stress-test the fit

For each attachment point, ask yourself:
- Does the current abstraction accommodate this feature, or does it need to be bent/hacked to fit?
- Are there existing patterns in the codebase that handle something similar? If so, follow them. If not, why not?
- What would a developer unfamiliar with this codebase expect the feature's entry point to look like?

### 1.3 Surface alternatives

Identify at least two viable approaches. For each, note:
- Which existing code it reuses vs. what it adds
- What it makes easy and what it makes awkward
- Whether it creates future obligations (new abstractions callers must respect, new invariants to maintain)

### 1.4 Identify risks

- What existing tests will break or need updating?
- What assumptions in the current code does this feature violate?
- Are there performance, security, or compatibility concerns?
- Does this feature introduce a new dependency? Is that dependency justified?

### 1.5 Produce a brief

Write a short exploration summary (NOT a plan) covering:
- Attachment points found
- Tensions discovered (where the feature doesn't fit cleanly)
- Alternatives identified (with tradeoffs in one sentence each)
- Open questions for the user

Present this brief to the user before moving to Phase 2.

## Phase 2: Requirement Grilling

After presenting the exploration brief, interview the user to resolve ambiguity. Follow the grill-me protocol:

- Ask questions ONE AT A TIME using the AskUserQuestion tool when available.
- For each question, provide your recommended answer based on what you found in the codebase.
- If a question can be answered by further codebase exploration, do that instead of asking.
- Resolve dependencies between decisions in order (don't ask about error handling before the happy path is clear).

### What to grill on

Focus questions on:
- **Scope boundaries**: What is explicitly NOT part of this feature?
- **Architecture choices**: Which of the alternatives from Phase 1 does the user prefer, and why?
- **Edge cases**: What happens when inputs are invalid, services are unavailable, or state is unexpected?
- **Integration points**: How should this feature interact with existing features the user hasn't mentioned?
- **Naming and API surface**: What should the public interface look like from a caller's perspective?

### When to stop

Stop grilling when:
- You have enough information to write a concrete implementation plan with no TBDs
- The user signals they're satisfied with the shared understanding
- All alternatives have been narrowed to one clear path

## Phase 3: Handoff

Once exploration and grilling are complete, present a concise summary:

1. **Decided approach** (one sentence)
2. **Key constraints** surfaced during grilling
3. **Scope** (what's in, what's explicitly out)
4. **Risks acknowledged** (and how they'll be mitigated)

Then ask: "Ready to plan the implementation?" Do not begin implementation until the user confirms.

## Rules

- Never skip Phase 1. Even if the feature seems obvious, explore first. Your confidence that something is straightforward is exactly when hidden assumptions bite.
- Do not write code during this skill. The output is understanding, not implementation.
- If the exploration reveals the feature is trivial (< 20 lines, obvious attachment point, no alternatives worth considering), say so and ask if the user wants to skip the grilling and go straight to implementation.
- Prefer concrete evidence from the codebase over abstract reasoning. Show file paths and line numbers when discussing attachment points.
