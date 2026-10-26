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

info "done. Next:"
info "  1) scripts/install-cli.sh"
info "  2) edit ~/.config/proton-drive-sync/config"
info "  3) proton-drive-sync login"
info "  4) proton-drive-sync doctor"
info "  5) proton-drive-sync --dry-run sync"
info "  6) proton-drive-sync sync"
info "Optional timer: WITH_TIMER=1 $0"
