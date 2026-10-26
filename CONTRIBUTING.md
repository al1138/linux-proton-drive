# Contributing

## Scope

Keep the project **minimal**: thin orchestration around the official
`proton-drive` CLI. Prefer documentation and safer defaults over new features.

## Privacy

Do not include personal names, emails, home-directory usernames, hostnames,
screenshots of private files, or account identifiers in commits, issues, PRs,
or examples. Use placeholders such as `__HOME__` or `/home/USER`.

### Publishing this repository anonymously

Git commits permanently record `user.name` / `user.email`. Before the first
public commit:

1. Use a forge account that does **not** contain your legal name.
2. Set an identity **local to this clone only** (example):

   ```bash
   git config --local user.name "linux-proton-drive contributors"
   git config --local user.email "contributors@users.noreply.github.com"
   ```

3. Point `origin` at the intended public repository (`git remote -v`).
4. Never commit real configs, logs, or `.tmp-*` directories.

## Development

```bash
bash -n bin/proton-drive-sync
bash -n scripts/install-cli.sh
bash -n scripts/install-sync.sh
./bin/proton-drive-sync --help
```

Target platform: Linux (Debian/Ubuntu/Mint and similar) with Bash 4+,
`curl`, `sha512sum`, and `flock` (util-linux).

## Pull requests

- One logical change per PR.
- Update `README.md` / `config/config.example` when behaviour changes.
- When bumping the pinned Proton Drive CLI version, update **both**
  `PROTON_DRIVE_CLI_VERSION` and the `CHECKSUMS` map in `scripts/install-cli.sh`
  from https://proton.me/download/drive/cli/

## License

Contributions are accepted under the MIT License (`LICENSE`).
