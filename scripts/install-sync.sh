#!/usr/bin/env bash
# Install proton-drive-sync wrapper + optional systemd user timer.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
WITH_TIMER="${WITH_TIMER:-0}"

die() { echo "error: $*" >&2; exit 1; }
info() { echo "$*" >&2; }

mkdir -p "$PREFIX/bin"
install -m 0755 "$ROOT/bin/proton-drive-sync" "$PREFIX/bin/proton-drive-sync"
info "installed $PREFIX/bin/proton-drive-sync"

# Starter config with Documents/Pictures if present (no empty file).
"$PREFIX/bin/proton-drive-sync" init

if [[ "$WITH_TIMER" == "1" ]]; then
  unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  mkdir -p "$unit_dir"
  install -m 0644 "$ROOT/systemd/proton-drive-sync.service" "$unit_dir/"
  install -m 0644 "$ROOT/systemd/proton-drive-sync.timer" "$unit_dir/"
  systemctl --user daemon-reload
  systemctl --user enable --now proton-drive-sync.timer
  info "enabled user timer: systemctl --user list-timers | grep proton"
  info "logs: journalctl --user -u proton-drive-sync.service -n 50"
fi

info ""
info "Next steps (simple):"
info "  export PATH=\"$PREFIX/bin:\$PATH\""
info "  proton-drive-sync setup    # choose folders by answering O/n (recommended)"
info "  proton-drive-sync login    # sign in with the browser"
info "  proton-drive-sync sync     # back up"
info ""
info "Optional auto backup every 6h: WITH_TIMER=1 $0"
