# **Backup databases & directories**

## Goals
- **dump & compress postgresql and mysql databases** ( backup_list_db.csv )
- **Borg backup sql dumps and directories** ( backup_list_dir.csv )

## Set parameters

### Script configuration
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

### Databases
**file:** _backup_list_db.csv_
```bash
< X |- >;<host>;<username>;<password>;<dbname>;< mysql | pgsql >
```

### directories
**file:** _backup_list_dir.csv_
```bash
< X |- >;<dir_path>
```

## Create repository
```bash
  $ source ./backup.config
  $ borg init --encryption=repokey $REPO_LOCAL
```

## Run backup
```bash
# $ ./backup_all.sh <db list> <db dump dir> <dir list>
$ ./backup_all.sh backup_list_db.csv sql_dumps backup_list_dir.csv
```
