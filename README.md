# linux-proton-drive

Back up folders from your **Linux PC** to [Proton Drive](https://proton.me/support/drive-cli)
using Proton’s **official** command-line tool.

> **Not affiliated with Proton AG.** See [`NOTICE`](NOTICE).  
> This is **backup on a schedule**, not Dropbox-style instant sync. That is
> intentional: safer if you delete a file by mistake or malware runs.

**French / guide grand public :** [`README.fr.md`](README.fr.md)

## You do not need to edit a blank config file

A **setup assistant** asks which folders to back up and writes the config for you:

```bash
proton-drive-sync setup
```

## Quick start (Mint / Ubuntu)

```bash
sudo apt update
sudo apt install -y curl ca-certificates libsecret-1-0 libsecret-tools util-linux

git clone https://github.com/al1138/linux-proton-drive.git
cd linux-proton-drive

./scripts/install-cli.sh      # official Proton CLI (SHA-512 verified)
./scripts/install-sync.sh     # installs the helper + a starter config

export PATH="$HOME/.local/bin:$PATH"

proton-drive-sync setup       # choose folders (Documents, Pictures, …)
proton-drive-sync login       # browser sign-in
proton-drive-sync doctor      # sanity check
proton-drive-sync --dry-run sync   # preview only
proton-drive-sync sync        # real backup
```

Optional automatic backup every 6 hours:

```bash
WITH_TIMER=1 ./scripts/install-sync.sh
```

## What the config is (plain language)

| | |
|--|--|
| **File** | `~/.config/proton-drive-sync/config` |
| **Who creates it** | `setup` (questions) or `init` (automatic defaults) |
| **What it stores** | Which PC folders to copy, and where they go in Proton Drive |
| **What it does *not* store** | Your Proton password (that stays in the system keyring) |

After `setup`, open it only if you are curious:

```bash
proton-drive-sync status
```

### How to read one line

```bash
PAIR_documents="/home/USER/Documents|/my-files/Linux/Documents|push"
```

Means: *take the Documents folder on this PC, and upload a copy into
`/my-files/Linux/Documents` on Proton Drive.*

| Piece | Meaning |
|-------|---------|
| `PAIR_documents` | A name for this backup job |
| Left path | Folder **on your computer** |
| Right path | Folder **inside Proton Drive** |
| `push` | PC → cloud (normal backup) |

Other modes (rarely needed at first): `pull` (cloud → PC), `both` (push then pull).  
Deleted local files are **not** deleted in the cloud.

### Change folders later

Just run the assistant again (it can replace the old file):

```bash
proton-drive-sync setup
```

### Advanced: edit by hand

Only if you prefer. Template with every option:
[`config/config.example`](config/config.example).

```bash
nano ~/.config/proton-drive-sync/config
chmod 600 ~/.config/proton-drive-sync/config
```

Add a line like:

```bash
PAIR_projects="/home/USER/Projects|/my-files/Linux/projects|push"
```

Use your real home directory (`echo $HOME`), not the word `USER`.

### Optional settings

| Key | Default | Meaning |
|-----|---------|---------|
| `PROTON_DRIVE_BIN` | set by setup | Path to the official `proton-drive` program |
| `CREDENTIALS_STORE` | `keychain` | System keyring (`pass` also allowed; `unsafe_file` refused) |
| `ALLOW_DELETE` | `0` | Keep at `0` unless you knowingly accept overwriting local files on pull |

## Everyday commands

```bash
proton-drive-sync status
proton-drive-sync doctor
proton-drive-sync sync
proton-drive-sync --dry-run sync
proton-drive-sync logout
```

Logs: `~/.local/state/proton-drive-sync/logs/`

## Principles (why it is built this way)

| Choice | Why |
|--------|-----|
| Official binary + SHA-512 check | Trust Proton’s release |
| Session in libsecret / `pass` | No secrets in the config file |
| Default `push` | Incremental backup |
| No automatic deletes | Safer against mistakes and ransomware |
| Timer / manual runs | No always-on sync daemon |

## Limits

- Not instant sync on every save (use the timer or run `sync` yourself).
- Local deletions stay on Drive on purpose.
- Proton Docs/Sheets are not downloaded as normal files (CLI limit).
- Follow Proton [fair use](https://proton.me/blog/proton-drive-cli) guidance.

## Upgrading the official CLI

1. Check <https://proton.me/download/drive/cli/>
2. Update version + checksums in `scripts/install-cli.sh`
3. `./scripts/install-cli.sh --force`

## Troubleshooting

| Symptom | What to try |
|---------|-------------|
| Not logged in | `proton-drive-sync login` (desktop session unlocked) |
| No folders in setup | Create Documents/Pictures in the file manager, run `setup` again |
| Want a safe preview | `proton-drive-sync --dry-run sync` |

## Contributing / security

[`CONTRIBUTING.md`](CONTRIBUTING.md) · [`SECURITY.md`](SECURITY.md)

## License

MIT — [`LICENSE`](LICENSE).  
The `proton-drive` binary is from Proton AG; this repo does not redistribute it.
