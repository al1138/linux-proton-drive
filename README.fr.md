# linux-proton-drive

Sauvegarder des dossiers de votre PC Linux vers **Proton Drive**, simplement,
avec le programme officiel de Proton.

> Projet indépendant (voir [`NOTICE`](NOTICE)).  
> Ce n’est **pas** une synchronisation instantanée comme Dropbox : c’est une
> **sauvegarde** que vous lancez de temps en temps (ou qui se lance toute seule
> toutes les quelques heures). C’est plus sûr.

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

## Sauvegarde automatique (optionnel)

Pour lancer la sauvegarde tout seul toutes les 6 heures :

```bash
cd ~/linux-proton-drive   # ou l'endroit où vous avez cloné le projet
WITH_TIMER=1 ./scripts/install-sync.sh
```

## En cas de problème

| Message / situation | Que faire |
|---------------------|-----------|
| « not logged in » / pas connecté | Relancer `proton-drive-sync login` (session graphique ouverte, trousseau déverrouillé) |
| L’assistant ne trouve aucun dossier | Créer d’abord Documents/Photos dans le gestionnaire de fichiers, puis relancer `setup` |
| Peur d’envoyer trop de choses | Utiliser d’abord `proton-drive-sync --dry-run sync` |

## Aller plus loin

Guide technique (anglais) : [`README.md`](README.md)  
Sécurité : [`SECURITY.md`](SECURITY.md)

## Licence

MIT — [`LICENSE`](LICENSE). Le programme `proton-drive` appartient à Proton AG.
