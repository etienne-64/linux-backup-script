# **Backup databases & directories**

## Set parameters
```bash
# backup.config
TAMPON_LONG="+%Y%m%d_%H%M%S"
TAMPON_SHORT="+%H:%M:%S"
# Affichage en couleur (1), Affichage neutre (0) pour sortie log (à faire)
CONSOLE_ACTIVE=1
# Local Borg repository
REPO_LOCAL="./backup_repo"
# Remote Borg repository
REPO_REMOTE="ssh://<user>@<host>:<ssh_port>/<path_to_remote_rep>/backup_repo_remote"
# Borg passphrase
PASSPHRASE="cW37pFCt"
# Borg archive format
# borg create --compression lzma $LOCAL_REPO::{now:$BORG_ARCHIVE_FORMAT} $FOLDER_LIST
BORG_ARCHIVE_FORMAT="%Y-%m-%d-%H"
```

## Create repository
```bash
  $ source ./backup.config
  $ borg init --encryption=repokey $REPO_LOCAL
```
