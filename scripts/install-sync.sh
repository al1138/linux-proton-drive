#!/usr/bin/env bash
# Install proton-drive-sync, enable auto backup timer, and desktop launcher.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
# Auto backup every 5 minutes (+ shortly after login). Set WITH_TIMER=0 to skip.
WITH_TIMER="${WITH_TIMER:-1}"
# Desktop icon + app menu entry. Set WITH_DESKTOP=0 to skip.
WITH_DESKTOP="${WITH_DESKTOP:-1}"

die() { echo "error: $*" >&2; exit 1; }
info() { echo "$*" >&2; }

mkdir -p "$PREFIX/bin"
install -m 0755 "$ROOT/bin/proton-drive-sync" "$PREFIX/bin/proton-drive-sync"
install -m 0755 "$ROOT/bin/proton-drive-backup-now" "$PREFIX/bin/proton-drive-backup-now"
info "installed $PREFIX/bin/proton-drive-sync"
info "installed $PREFIX/bin/proton-drive-backup-now"

# Starter config with Documents/Pictures if present (no empty file).
"$PREFIX/bin/proton-drive-sync" init

if [[ "$WITH_TIMER" == "1" ]]; then
  unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  mkdir -p "$unit_dir"
  install -m 0644 "$ROOT/systemd/proton-drive-sync.service" "$unit_dir/"
  install -m 0644 "$ROOT/systemd/proton-drive-sync.timer" "$unit_dir/"
  systemctl --user daemon-reload
  systemctl --user enable --now proton-drive-sync.timer
  info "auto backup enabled: at login (~1 min) then every 5 minutes"
  info "  check: systemctl --user list-timers | grep proton"
  info "  logs:  journalctl --user -u proton-drive-sync.service -n 50"
else
  info "timer skipped (WITH_TIMER=0)"
fi

if [[ "$WITH_DESKTOP" == "1" ]]; then
  apps_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  mkdir -p "$apps_dir"
  sed "s|@BINDIR@|$PREFIX/bin|g" \
    "$ROOT/desktop/proton-drive-backup.desktop.in" \
    >"$apps_dir/proton-drive-backup.desktop"
  chmod 644 "$apps_dir/proton-drive-backup.desktop"

  # Desktop shortcut (Linux Mint / Cinnamon / XDG)
  desktop_dir="${XDG_DESKTOP_DIR:-}"
  if [[ -z "$desktop_dir" && -f "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" ]]; then
    # shellcheck disable=SC1090
    source "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"
    desktop_dir="${XDG_DESKTOP_DIR:-}"
  fi
  desktop_dir="${desktop_dir:-$HOME/Desktop}"
  # Expand $HOME if still literal from user-dirs.dirs
  desktop_dir="${desktop_dir/#\$HOME/$HOME}"

  if [[ -d "$desktop_dir" ]]; then
    cp "$apps_dir/proton-drive-backup.desktop" "$desktop_dir/proton-drive-backup.desktop"
    chmod 755 "$desktop_dir/proton-drive-backup.desktop"
    # Mark as trusted on glib/Cinnamon when possible (double-click without warning)
    if command -v gio >/dev/null 2>&1; then
      gio set "$desktop_dir/proton-drive-backup.desktop" metadata::trusted true 2>/dev/null || true
    fi
    info "desktop icon: $desktop_dir/proton-drive-backup.desktop"
  else
    info "no Desktop folder found; menu entry only: $apps_dir/proton-drive-backup.desktop"
  fi
  info "menu entry: Sauvegarde Proton Drive"
else
  info "desktop launcher skipped (WITH_DESKTOP=0)"
fi

info ""
info "Next steps (if not done yet):"
info "  export PATH=\"$PREFIX/bin:\$PATH\""
info "  proton-drive-sync setup"
info "  proton-drive-sync login"
info "  # or click the desktop icon « Sauvegarde Proton Drive »"
info ""
info "Disable auto backup: systemctl --user disable --now proton-drive-sync.timer"
info "Reinstall without timer: WITH_TIMER=0 $0"
