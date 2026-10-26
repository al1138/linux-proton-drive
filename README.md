# linux-proton-drive

Minimal, safety-first folder sync for **Linux** using the
[official Proton Drive CLI](https://proton.me/support/drive-cli).

> **Not affiliated with Proton AG.** See [`NOTICE`](NOTICE).
> This is **not** a real-time desktop sync client. Proton’s CLI runs atomic
> upload/download commands and exits. That design is intentional for security.

## Principles

| Choice | Why |
|--------|-----|
| Official binary + **SHA-512** verify | Trust Proton’s release, not a reimplementation |
| Session in **libsecret** or `pass` | No password/token in config files |
| Default mode **`push`** | Incremental local → Drive backup |
| Push conflicts: `create-new-revision` | Keep Drive history; unchanged files skipped by CLI |
| Pull conflicts: `skip` | Never overwrite local files silently |
| **No automatic deletes** | Local `rm` / ransomware does not wipe Drive |
| `flock` + systemd user timer | One run at a time, reliable schedule |
| `--dry-run` / `doctor` | Inspect before writing |

This is **not** a bidirectional mirror with deletions (unlike `rclone sync`).
That behaviour is refused by default on purpose.

## Requirements

- Linux (Mint, Ubuntu, Debian, Fedora, …)
- Bash 4+, `curl`, `sha512sum`, `flock` (util-linux)
- Desktop session with a secret store (GNOME Keyring / KWallet) **or** [`pass`](https://www.passwordstore.org/)

```bash
# Debian / Ubuntu / Linux Mint
sudo apt update
sudo apt install -y curl ca-certificates libsecret-1-0 libsecret-tools util-linux
```

## Install

```bash
git clone https://github.com/al1138/linux-proton-drive.git
cd linux-proton-drive

./scripts/install-cli.sh      # official CLI + SHA-512 check
./scripts/install-sync.sh     # wrapper + config skeleton

# Edit folder pairs, then lock down permissions
${EDITOR:-nano} ~/.config/proton-drive-sync/config
chmod 600 ~/.config/proton-drive-sync/config

export PATH="$HOME/.local/bin:$PATH"
proton-drive-sync login
proton-drive-sync doctor
proton-drive-sync --dry-run sync
proton-drive-sync sync
```

Optional systemd user timer (every 6 hours):

```bash
WITH_TIMER=1 ./scripts/install-sync.sh
systemctl --user list-timers | grep proton
journalctl --user -u proton-drive-sync.service -n 50
```

## Configuration

File: `~/.config/proton-drive-sync/config` (see `config/config.example`).

```bash
PAIR_documents="__HOME__/Documents|/my-files/Linux/Documents|push"
PAIR_pictures="__HOME__/Pictures|/my-files/Linux/Pictures|push"
```

`proton-drive-sync init` replaces `__HOME__` with your `$HOME`.

| Mode | Effect |
|------|--------|
| `push` | Local → Drive (recommended default) |
| `pull` | Drive → local (won’t overwrite existing local files) |
| `both` | Push then pull |

Drive paths must be absolute (typically under `/my-files/...`).

## Commands

```bash
proton-drive-sync status
proton-drive-sync doctor
proton-drive-sync push
proton-drive-sync pull <pair>
proton-drive-sync sync
proton-drive-sync --dry-run sync
proton-drive-sync logout
```

CLI JSON logs: `~/.local/state/proton-drive-sync/logs/`.

## Limits

- No instant sync on every file save (use the timer, cron, or a manual run).
- Locally deleted files **remain** on Drive by design.
- Proton Docs / Sheets are not downloaded as regular files (CLI limitation).
- Respect Proton [fair use](https://proton.me/blog/proton-drive-cli) guidance.
- An official Linux desktop app remains on Proton’s [roadmap](https://proton.me/drive/roadmap); this project only bridges the gap with the CLI.

## Upgrading the official CLI

1. Check version + checksums at <https://proton.me/download/drive/cli/>
2. Update `CLI_VERSION` and `CHECKSUMS` in `scripts/install-cli.sh`
3. Re-run: `./scripts/install-cli.sh --force`

## Troubleshooting

| Symptom | Hint |
|---------|------|
| Auth fails | Unlock the graphical keyring; install `secret-tool`; run `login` again |
| `Illegal instruction` | CPU without AVX2 — check Proton’s download page for a baseline build |
| Interactive conflict prompts | Wrapper always passes `--json` + explicit strategies |
| Parallel runs | Blocked by `flock` on `~/.local/state/proton-drive-sync/sync.lock` |

## Contributing / security

See [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`SECURITY.md`](SECURITY.md).

## License

MIT — see [`LICENSE`](LICENSE).
The `proton-drive` binary is provided by Proton AG under Proton’s terms; this
repository does not vendor that binary.
