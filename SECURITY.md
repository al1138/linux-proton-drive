# Security Policy

## Supported versions

Security fixes are applied on the default branch of this repository.

## What this project does and does not do

- This project wraps the **official** Proton Drive CLI. Cryptography and
  cloud protocol handling are Proton's responsibility.
- This project **does not** store Proton passwords. Authentication uses the
  official CLI browser login and the OS secret store (`keychain` / `pass`).
- Default sync modes **do not** delete remote or local files.

## Reporting a vulnerability

Please open a **private** security advisory on the project's hosting forge
(GitHub Security Advisories, or equivalent), or email the address listed in
the forge profile for this repository — if none is listed, open a minimal
public issue titled `security` without exploit details and wait for a
maintainer contact channel.

Do not attach credentials, session dumps, or personal file listings to reports.

## Hardening expectations for operators

- Keep `~/.config/proton-drive-sync/config` mode `600`.
- Never set `CREDENTIALS_STORE=unsafe_file`.
- Verify CLI checksums when installing or upgrading (`scripts/install-cli.sh`).
- Review `--dry-run` output before enabling timers on new pairs.
