# ADR 0002: Separate Campaign Contract from Core Contract

- **Status:** Accepted
- **Date:** 2026-07-28
- **Author:** Moonwalker-rgb

## Context

The original OrbitChain design had all campaign logic in a single "core" contract
(`crates/contracts/core`). As the feature set expanded — milestones, multi-asset
releases, refund windows, asset whitelisting — the core contract grew to over 1000
lines with tightly coupled concerns.

We considered two alternatives:
1. **Monolith:** Keep all logic in core, adding feature flags and conditional branches.
2. **Separation:** Extract campaign logic into its own contract (`campaign/`), with
   `core` handling only lifecycle registration and withdrawal workflows.

## Decision

We separated the campaign into its own crate (`orbitchain-campaign`) under `campaign/`.
The core contract (`crates/contracts/core`) retains:
- Campaign *registration* (creating a new campaign instance)
- Withdrawal request/approval lifecycle
- Basic event definitions shared across contracts

The campaign contract owns:
- Donations and milestone tracking
- Milestone release (single and multi-asset)
- Refund eligibility and claim logic
- Campaign status transitions (end, cancel, extend deadline)
- Admin operations (freeze, upgrade, asset block/unblock)

Shared types and versioning live in `common/` (`orbitchain-common`).

## Consequences

- **Positive:** Each contract has a clear, single responsibility; easier to audit and test independently.
- **Positive:** Campaign-specific changes (e.g., new milestone logic) can be deployed without touching core.
- **Positive:** The separation is reflected in the workspace structure: `campaign/`, `common/`, `crates/contracts/core/`.
- **Negative:** Cross-contract calls between core and campaign introduce a small latency overhead.
- **Negative:** Event topics differ between contracts; indexers must subscribe to both.
