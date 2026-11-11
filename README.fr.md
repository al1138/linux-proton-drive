# linux-proton-drive

Sauvegarder des dossiers de votre PC Linux vers **Proton Drive**, simplement,
avec le programme officiel de Proton.

> Projet indépendant (voir [`NOTICE`](NOTICE)).  
> Ce n’est **pas** une synchronisation instantanée comme Dropbox : c’est une
> **sauvegarde** automatique (au démarrage, puis toutes les **5 minutes**) et
> aussi manuelle via une **icône sur le bureau**. Les fichiers inchangés ne
> sont pas renvoyés. Les suppressions locales ne sont pas reprises sur le cloud.

## En deux mots

1. Vous choisissez quels dossiers sauvegarder (Documents, Photos, …).
2. Vous vous connectez une fois avec votre compte Proton (dans le navigateur).
3. Le programme envoie une copie de ces dossiers vers Proton Drive.
4. Si vous effacez un fichier sur le PC, **il reste** sur Proton Drive
   (protection contre les erreurs et les virus).

**Vous n’avez pas besoin d’éditer un fichier technique à la main.**  
Un assistant pose des questions et crée la configuration pour vous.

## Installation (Linux Mint / Ubuntu)

Ouvrez un terminal, puis copiez-collez ces commandes **une par une** :

```bash
sudo apt update
sudo apt install -y curl ca-certificates libsecret-1-0 libsecret-tools util-linux

git clone https://github.com/al1138/linux-proton-drive.git
cd linux-proton-drive

./scripts/install-cli.sh
./scripts/install-sync.sh

export PATH="$HOME/.local/bin:$PATH"
```

## Choisir les dossiers (assistant)

```bash
proton-drive-sync setup
```

L’assistant demande, par exemple :

- sauvegarder Documents ? **O** ou **n**
- sauvegarder Photos / Images ? **O** ou **n**
- … et éventuellement un autre dossier

Il crée ensuite tout seul le fichier de réglages.  
Vous n’avez rien à écrire dedans.

Pour revoir ce qui a été choisi :

```bash
proton-drive-sync status
```

## Se connecter et sauvegarder

```bash
proton-drive-sync login
```

→ une page s’ouvre dans le navigateur : connectez-vous à Proton, puis revenez au terminal.

```bash
proton-drive-sync doctor
```

→ vérifie que tout est prêt (doit indiquer que la connexion est OK).

```bash
proton-drive-sync --dry-run sync
```

→ **essai à blanc** : montre ce qui serait envoyé, sans rien copier. Utile la première fois.

```bash
proton-drive-sync sync
```

→ lance la vraie sauvegarde vers Proton Drive.

## Sauvegarde automatique (installée par défaut)

`./scripts/install-sync.sh` active un minuteur systemd utilisateur :

- environ **1 minute** après la connexion / le démarrage de session
- puis **toutes les 5 minutes**

Vérifier :

```bash
systemctl --user list-timers | grep proton
```

Désactiver :

```bash
systemctl --user disable --now proton-drive-sync.timer
```

Réinstaller sans minuteur : `WITH_TIMER=0 ./scripts/install-sync.sh`

## Icône sur le bureau (manuel)

L’installation place aussi :

- une icône **« Sauvegarde Proton Drive »** sur le Bureau
- la même entrée dans le menu des applications

Un double-clic lance une sauvegarde immédiate et affiche une notification
(« en cours… » / « terminée » / erreur).

Sur Mint, si le système demande de « faire confiance » au lanceur, acceptez
(ou clic droit → Autoriser le lancement).

Équivalent en terminal :

```bash
proton-drive-backup-now
```

## Que contient le fichier de configuration ?

Emplacement : `~/.config/proton-drive-sync/config`

Ce fichier est **créé par l’assistant**. Il ressemble à ceci (exemple) :

```bash
PROTON_DRIVE_BIN="/home/USER/.local/bin/proton-drive"
CREDENTIALS_STORE="keychain"
ALLOW_DELETE=0

# Dossier Documents → copie sur Proton Drive
PAIR_documents="/home/USER/Documents|/my-files/Linux/Documents|push"
```

### Comment le lire (sans être informaticien)

| Élément | Signification |
|---------|----------------|
| `PAIR_documents=...` | « Sauvegarde le dossier Documents » |
| Première partie du chemin | Le dossier **sur votre PC** |
| Partie après le `|` | L’endroit **dans Proton Drive** (le cloud) |
| `push` à la fin | Envoyer du PC vers le cloud (c’est ce qu’il faut pour une sauvegarde) |

### Faut-il le modifier ?

**Non**, si l’assistant vous convient.

Pour changer la liste des dossiers plus tard, relancez simplement :

```bash
proton-drive-sync setup
```

(Répondez **O** quand il propose de remplacer l’ancienne config.)

### Si vous voulez vraiment ajouter une ligne à la main

1. Ouvrez le fichier : `nano ~/.config/proton-drive-sync/config`
2. Copiez une ligne `PAIR_...` existante
3. Changez le nom (`PAIR_travail`) et le chemin PC
4. Enregistrez (`Ctrl+O`, Entrée, puis `Ctrl+X` dans nano)

Exemple pour un dossier `Projets` :

```bash
PAIR_projets="/home/USER/Projets|/my-files/Linux/projets|push"
```

Remplacez `/home/USER` par votre vrai dossier personnel (celui affiché par la commande `echo $HOME`).

## Connexion : trousseau verrouillé

Si `login` affiche `locked collection` / `ERR_SECRETS_PLATFORM_ERROR` :

```bash
sudo apt install -y gnome-keyring libsecret-1-0 libsecret-tools seahorse
```

1. Restez dans la **session graphique** Mint (pas seulement SSH).
2. Ouvrez **Mots de passe et clés** (Seahorse) → déverrouillez le trousseau **Connexion**.
3. Relancez : `proton-drive-sync login`

Autre option : stocker la session avec `pass` (chiffré GPG) :

```bash
sudo apt install -y pass gnupg
# dans ~/.config/proton-drive-sync/config :
# CREDENTIALS_STORE="pass"
pass init VOTRE_EMAIL_GPG
proton-drive-sync login
```

## En cas de problème

| Message / situation | Que faire |
|---------------------|-----------|
| « not logged in » / pas connecté | Relancer `proton-drive-sync login` (session graphique ouverte, trousseau déverrouillé) |
| `Cannot create an item in a locked collection` / `ERR_SECRETS_PLATFORM_ERROR` | Le **trousseau** (mots de passe système) est verrouillé. Déverrouillez-le (Seahorse / session Mint), installez `gnome-keyring`, puis `proton-drive-sync login`. Ou utilisez `CREDENTIALS_STORE="pass"` (voir ci-dessous) |
| L’assistant ne trouve aucun dossier | Créer d’abord Documents/Photos dans le gestionnaire de fichiers, puis relancer `setup` |
| Peur d’envoyer trop de choses | Utiliser d’abord `proton-drive-sync --dry-run sync` |
| `Node not found : Linux` | Ancien bug : le dossier cloud `/my-files/Linux` n’existait pas. Mettez à jour le script (`git pull` puis `./scripts/install-sync.sh`) puis relancez `sync` — les dossiers distants manquants sont créés automatiquement |
| Vous avez déplacé le dépôt sur le disque | Sans impact sur la config (`~/.config/...`). Réinstallez juste la commande : `./scripts/install-sync.sh` depuis le nouvel emplacement |
| Plusieurs questions O/n d’un coup | Corrigé dans les versions récentes : une question à la fois. Mettez à jour et relancez `setup` |

## Aller plus loin

Guide technique (anglais) : [`README.md`](README.md)  
Sécurité : [`SECURITY.md`](SECURITY.md)

## Licence

MIT — [`LICENSE`](LICENSE). Le programme `proton-drive` appartient à Proton AG.
