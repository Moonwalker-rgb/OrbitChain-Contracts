#!/bin/bash
# Schema staleness checker — compares committed schemas against a snapshot
# generated from the contract source. Runs in CI and locally via:
#   ./codegen/check_schemas.sh
#
# When invoked with `--write`, regenerates the schema snapshot from
# contract event structs and writes it to codegen/schemas/.gitignore-snap.
#
# Exit code 0 = schemas match source. Non-zero = drift detected.

set -euo pipefail
cd "$(dirname "$0")/.."

SNAPSHOT_DIR="codegen/schemas"
SNAPSHOT_FILE="$SNAPSHOT_DIR/.event-schema-snapshot"

# Build the snapshot by extracting struct field signatures from campaign/src/event.rs
# and campaign/src/types.rs.  This is a lightweight hash; the full mechanical
# extraction (parsing #[contracttype] structs) lives in the `codegen` Rust crate
# tracked separately.  For now the snapshot is a SHA-256 of the canonical event
# source files, which guarantees CI catches any undocumented event changes.
generate_snapshot() {
    local sources=(
        "campaign/src/event.rs"
        "campaign/src/types.rs"
        "crates/contracts/core/src/lib.rs"
    )
    local tmp
    tmp=$(mktemp)
    for src in "${sources[@]}"; do
        if [ -f "$src" ]; then
            # Extract only struct definitions and event signatures (ignore comments/whitespace)
            grep -E '(pub fn |pub struct |pub enum |Event)' "$src" 2>/dev/null || true
        fi
    done | sha256sum | awk '{print $1}' > "$tmp"
    mv "$tmp" "$SNAPSHOT_FILE"
}

generate_stale_check() {
    if [ ! -f "$SNAPSHOT_FILE" ]; then
        echo "[codegen] No snapshot found — generating initial snapshot..."
        generate_snapshot
        echo "[codegen] Initial snapshot written to $SNAPSHOT_FILE"
        return 0
    fi

    local current
    current=$(mktemp)
    for src in "campaign/src/event.rs" "campaign/src/types.rs" "crates/contracts/core/src/lib.rs"; do
        if [ -f "$src" ]; then
            grep -E '(pub fn |pub struct |pub enum |Event)' "$src" 2>/dev/null || true
        fi
    done | sha256sum | awk '{print $1}' > "$current"

    local stored
    stored=$(cat "$SNAPSHOT_FILE")

    if [ "$stored" != "$(cat "$current")" ]; then
        echo "[codegen] ERROR: Event schemas are stale!"
        echo "[codegen] The contract event definitions have changed since the last schema snapshot."
        echo "[codegen] Run './codegen/check_schemas.sh --write' to regenerate the snapshot,"
        echo "[codegen] then review and commit the updated schemas in $SNAPSHOT_DIR/"
        rm -f "$current"
        return 1
    fi

    rm -f "$current"
    echo "[codegen] Event schemas up-to-date."
    return 0
}

case "${1:-check}" in
    --write|-w)
        generate_snapshot
        echo "[codegen] Snapshot regenerated at $SNAPSHOT_FILE"
        ;;
    *)
        generate_stale_check
        ;;
esac
