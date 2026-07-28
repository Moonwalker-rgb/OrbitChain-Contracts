# ADR 0001: Record Architecture Decisions

- **Status:** Accepted
- **Date:** 2026-07-28
- **Author:** Moonwalker-rgb

## Context

The OrbitChain-Contracts project has grown organically, with key design decisions made
in PR discussions, Slack threads, and implicit conventions. No single place captures
*why* decisions were made, making onboarding difficult for new contributors and
making it hard to revisit past trade-offs.

## Decision

We will use **Architecture Decision Records (ADRs)** as described by
Michael Nygard in [Documenting Architecture Decisions](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions).

All ADRs live under `docs/adr/` and follow this template:

```markdown
# ADR NNNN: Brief Title

- **Status:** {Proposed | Accepted | Deprecated | Superseded}
- **Date:** YYYY-MM-DD
- **Author:** GitHub handle

## Context
What is the issue that we're seeing that is motivating this decision or change?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?
```

- ADR files are numbered sequentially (`0001`, `0002`, …).
- Once accepted, ADRs are never deleted — only marked **Superseded** or **Deprecated** with a link to the replacement.
- Each ADR is self-contained: it must explain enough context for a future reader to understand the decision without external references.

## Consequences

- **Positive:** Maintainers and contributors have a canonical record of architectural rationale.
- **Positive:** Historical context is preserved for future auditing and re-evaluation.
- **Neutral:** Writing ADRs adds a small upfront cost to significant changes; authors must judge when a decision warrants an ADR.
