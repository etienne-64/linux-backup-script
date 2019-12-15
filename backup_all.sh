#!/bin/bash
#===============================================================================
# FILE: backup_all.sh
# USAGE:
# ./backup_all.sh <backup_list_db.csv> <sql_dumps> <backup_list_dir.csv>
# DESCRIPTION:
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: stéphane
# ORGANIZATION: Greenglade
# CREATED: 10/12/2019 16:02
# REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an errorbash

source ./backup.config

# === CONSTANTES & VARIABLES SCRIPT ==
LOCAL_REPO=$REPO_LOCAL
REMOTE_REPO=$REPO_REMOTE
TAMPON=$TAMPON_LONG
TAMPON_LOCAL=$TAMPON_SHORT
CONSOLE=$CONSOLE_ACTIVE

# === CONSTANTES BORG ===
export BORG_REPO=$LOCAL_REPO
export BORG_PASSPHRASE=$PASSPHRASE

# === FUNCTIONS ===
# COLORS:
# Black	30/40	Red	31/41	Green 32/42	Brown	33/43	Blue 34/44	Purple 35/45
# USAGE: print_color <message> <color> <0|1> | print_color "Message test" 32m 1
print_color(){
  MESSAGE=$1
  COLOR=$2
  YES=$3
  if [ $YES = 1 ]; then
    echo -e "\e[$COLOR;1m$MESSAGE\e[0m"
  else
    echo "$MESSAGE"
  fi
}

#===============================================================================
# Constitution liste des répertoires à sauvergarder à partir .csv passé en $1
# USAGE :
# list=$(get_dir_list $1)
#===============================================================================
get_dir_list(){
  DIR_LIST=''

  while read line
  do
    if [ ${line:0:1 } != '#' ]; then
      run=$(echo $line | cut -d';' -f1)
      if [ $run = 'X' ]; then
        path=$(echo $line | cut -d';' -f2)
        # backup_name=$(echo $line | cut -d';' -f3)
        # echo "$run | $path | $backup_name"
        DIR_LIST="$DIR_LIST $path"
      # else
        # echo "omitted > $line"
      fi
    fi

  done < $1

  echo $DIR_LIST
}

print_color " === $(date +%Y/%m/%d\ %H:%M:%S) - DEBUT BACKUP === " 37\;44 $CONSOLE

# === DUMP BD ===
./backup_db_dump.sh $1 $2

print_color "[i] $(date $TAMPON_LOCAL) - Folder list" 34 $CONSOLE
FOLDER_LIST=$(get_dir_list "$3")
print_color "[i] Liste = $FOLDER_LIST" 34 $CONSOLE

# echo -e "[+] $(date +%H:%M:%S) - Backup ssh repertoires et dumps"
# borg create -v --progress --compression lzma $REMOTE_REPO::{now} $FOLDER_LIST

print_color "[+] $(date $TAMPON_LOCAL) - Backup local repertoires et dumps [$LOCAL_REPO]" 32 $CONSOLE
borg create --compression lzma $LOCAL_REPO::{now:$BORG_ARCHIVE_FORMAT} $FOLDER_LIST
print_color "[+] $(date $TAMPON_LOCAL) - Purge des repertoires inutiles (période de rétention)" 32 $CONSOLE
# borg prune -v --list --dry-run --keep-daily=7 --keep-weekly=4 --keep-monthly=-1 $LOCAL_REPO
borg prune --list --keep-daily=7 --keep-weekly=4 --keep-monthly=-1 $LOCAL_REPO

print_color "[+] $(date $TAMPON_LOCAL) - Suppression des dumps" 32 $CONSOLE
rm -rf sql_dumps/mysql/*
rm -rf sql_dumps/pgsql/*

print_color " --- $(date +%Y/%m/%d\ %H:%M:%S) - FIN DU BACKUP --- " 37\;44 $CONSOLE

export BORG_PASSPHRASE=""

exit 0
