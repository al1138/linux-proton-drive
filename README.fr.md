# linux-proton-drive

Synchronisation minimale et prudente de dossiers sous **Linux**, via le
[CLI officiel Proton Drive](https://proton.me/support/drive-cli).

> **Projet indépendant, non affilié à Proton AG.** Voir [`NOTICE`](NOTICE).
> Ce n’est **pas** un client desktop temps réel. Le CLI Proton exécute des
> commandes atomiques puis s’arrête — choix favorable à la sécurité.

La documentation complète (installation, config, limites) est en anglais dans
[`README.md`](README.md). Les principes clés :

- Binaire officiel + vérification **SHA-512**
- Session dans **libsecret** ou `pass` (jamais de secrets en clair)
- Mode par défaut **`push`** (sauvegarde locale → Drive)
- **Aucune suppression** automatique
- Timer systemd utilisateur optionnel

```bash
./scripts/install-cli.sh
./scripts/install-sync.sh
# éditer ~/.config/proton-drive-sync/config
proton-drive-sync login && proton-drive-sync doctor
proton-drive-sync --dry-run sync && proton-drive-sync sync
```

Licence MIT — [`LICENSE`](LICENSE).
