# ADR 0003: Two-Hundred-Day Refund Window

- **Status:** Accepted
- **Date:** 2026-07-28
- **Author:** Moonwalker-rgb

## Context

When a campaign fails to reach its funding goal by the deadline, donors must be able
to claim refunds. The question was: *how long should the refund window remain open?*

We evaluated:
- **30 days:** Standard for many crowdfunding platforms; risks donors missing the window.
- **90 days:** Longer grace period; still may not cover all scenarios.
- **200 days:** Approximately 6.5 months; generous enough for most donors to notice
  and act, even if they check infrequently.
- **Indefinite:** Simplest for donors but creates permanent storage bloat and
  complicates contract archival.

## Decision

The refund window is set to **200 days** (defined as a constant `REFUND_WINDOW` in
`campaign/src/lib.rs`). After the campaign ends unsuccessfully:

1. Donors have 200 days from the campaign end time to call `claim_refund`.
2. After the window closes, `is_refund_eligible` returns `false` and refund claims revert.
3. The contract may be archived once the refund window closes and all funds are disbursed.

## Consequences

- **Positive:** 200 days (~6.5 months) gives donors ample time to discover and claim refunds, even if they interact with the dApp infrequently.
- **Positive:** The fixed window allows the contract to eventually become immutable/archivable, reducing long-term storage costs on the Soroban ledger.
- **Negative:** Donors who completely disengage for >200 days lose their refund. Mitigated by off-chain notification systems (email, push) that alert donors when a campaign fails.
- **Negative:** The constant is hardcoded; changing it requires a contract upgrade. This is intentional — predictability is more important than flexibility for a refund window.
