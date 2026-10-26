#!/usr/bin/env bash
# Download official Proton Drive CLI and verify SHA-512 before install.
set -euo pipefail

readonly CLI_VERSION="${PROTON_DRIVE_CLI_VERSION:-0.9.0}"
readonly BASE_URL="https://proton.me/download/drive/cli/${CLI_VERSION}"
readonly DEFAULT_PREFIX="${HOME}/.local"

PREFIX="${PREFIX:-$DEFAULT_PREFIX}"
VARIANT="${VARIANT:-}" # auto | linux-x64 | linux-x64-musl | linux-arm64 | linux-arm64-musl
FORCE="${FORCE:-0}"

# Official checksums for ${CLI_VERSION} (from https://proton.me/download/drive/cli/)
declare -A CHECKSUMS=(
  [linux-x64]="3533025ba69ae112b64e3e01fbcc1ad0688136a4043f6cf6a72886967d85fdcd9ec235479c2e113171614be5225bfba93427509a05ca5aa6071d924fa7e91ca8"
  [linux-arm64]="c8d5a6b174e57f06d05cb5483400b9963faf58e743b6b33706bb73ecff718047ffce6b439994255b94b5b226b90d2e91bef7418ec96c1c3f5d8bf39b6cd01321"
  [linux-x64-musl]="8f99c3bc478ebc2948ca69c8576a48d83b3290d807ca61fac9b0f5d0a91c0d418e595232d67e2ae0173d2188963771afd4292aefafab3f64e808a61c4399d6ed"
  [linux-arm64-musl]="4b632e5e694f6d0825aaa57f39f99494aa6a46eac45e90d65daa10b2e46316046b627d3c1145cb9c7d58951735cc6e81c28cca44dda648b411315a28d04b2acf"
)

usage() {
  cat <<EOF
Install official Proton Drive CLI ${CLI_VERSION} with SHA-512 verification.

Usage: $0 [--prefix DIR] [--variant NAME] [--force]

  --prefix DIR     Install to DIR/bin/proton-drive (default: ~/.local)
  --variant NAME   linux-x64 | linux-arm64 | linux-x64-musl | linux-arm64-musl
  --force          Re-download even if binary exists

Env:
  PROTON_DRIVE_CLI_VERSION   Override version (must update CHECKSUMS map)
EOF
}

die() { echo "error: $*" >&2; exit 1; }
info() { echo "$*" >&2; }

detect_variant() {
  local arch libc
  arch=$(uname -m)
  case "$arch" in
    x86_64|amd64) arch=x64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) die "unsupported architecture: $arch" ;;
  esac
  if ldd --version 2>&1 | grep -qi musl; then
    libc=musl
  else
    libc=gnu
  fi
  if [[ "$libc" == "musl" ]]; then
    echo "linux-${arch}-musl"
  else
    echo "linux-${arch}"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --prefix) PREFIX="${2:?}"; shift 2 ;;
    --variant) VARIANT="${2:?}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    *) die "unknown argument: $1" ;;
  esac
done

command -v curl >/dev/null 2>&1 || die "curl is required"
command -v sha512sum >/dev/null 2>&1 || die "sha512sum is required"

[[ -n "$VARIANT" ]] || VARIANT=$(detect_variant)
[[ -n "${CHECKSUMS[$VARIANT]+x}" ]] || die "unknown variant '$VARIANT' (update CHECKSUMS for this release)"

BIN_DIR="$PREFIX/bin"
TARGET="$BIN_DIR/proton-drive"
URL="${BASE_URL}/${VARIANT}/proton-drive"
EXPECTED="${CHECKSUMS[$VARIANT]}"

if [[ -x "$TARGET" && "$FORCE" != "1" ]]; then
  info "already installed: $TARGET"
  info "run with --force to reinstall"
  "$TARGET" version || true
  exit 0
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

info "downloading $URL"
curl -fsSL --proto '=https' --tlsv1.2 -o "$tmpdir/proton-drive" "$URL"

actual=$(sha512sum "$tmpdir/proton-drive" | awk '{print $1}')
if [[ "$actual" != "$EXPECTED" ]]; then
  die "SHA-512 mismatch for $VARIANT
  expected: $EXPECTED
  actual:   $actual
Refuse to install. Check https://proton.me/download/drive/cli/"
fi
info "SHA-512 OK"

mkdir -p "$BIN_DIR"
install -m 0755 "$tmpdir/proton-drive" "$TARGET"
info "installed $TARGET"

if ! "$TARGET" version; then
  if [[ "$VARIANT" == "linux-x64" ]]; then
    info "hint: if you see Illegal instruction, try a baseline build if published, or linux-x64-musl on musl systems"
  fi
  die "binary failed to run"
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    info "add to PATH (e.g. ~/.profile):"
    info "  export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

info "next: apt install libsecret-1-0 libsecret-tools   # Mint/Cinnamon keyring"
info "then:  proton-drive-sync init && proton-drive-sync login"
