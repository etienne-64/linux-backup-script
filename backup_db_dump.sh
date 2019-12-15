#!/bin/bash

# ================================================
# EMPLOI: db_dump.sh backup_list_db.csv sql_dumps
# ================================================

# Dump directory
#  ./mysql/
#  ./pgsql/

# === CONSTANTS ===
BKP_LIST_FILE=$1
BKP_FOLDER=$2
TAMPON="+%Y%m%d_%H%M%S"
TAMPON_LOCAL="+%H:%M:%S"
# 0 = sortie fichier | 1 = sortie console avec couleur
CONSOLE=1

# === FUNCTIONS ===
# COLORS: Black	30/40	Red	31/41	Green 32/42	Brown	33/43	Blue 34/44	Purple 35/45	Cyan 36/46
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

print_color " === $(date +%Y/%m/%d\ %H:%M:%S) - DEBUT DES DUMPS === " 30\;42 $CONSOLE

# === TEST REPERTOIRES mysql & pgsql ===
if [ ! -d "$BKP_FOLDER/mysql" ];then
  mkdir $BKP_FOLDER/mysql
  print_color "[+] $(date $TAMPON_LOCAL) - Create '$BKP_FOLDER/mysql'" 32 $CONSOLE
else
  print_color "[i] $(date $TAMPON_LOCAL) - '$BKP_FOLDER/mysql' existe" 34 $CONSOLE
fi

if [ ! -d "$BKP_FOLDER/pgsql" ];then
  mkdir $BKP_FOLDER/pgsql
  print_color "[+] $(date $TAMPON_LOCAL) - Create '$BKP_FOLDER/pgsql'" 32 $CONSOLE
else
  print_color "[i] $(date $TAMPON_LOCAL) - '$BKP_FOLDER/pgsql' existe" 34 $CONSOLE
fi

# === TRAITEMENT LISTE ===
while read line
do
  if [ ${line:0:1 } != '#' ]; then
    run=$(echo $line | cut -d';' -f1)
    dbname=$(echo $line | cut -d';' -f5)

    if [ $run = 'X' ]; then
      host=$(echo $line | cut -d';' -f2)
      username=$(echo $line | cut -d';' -f3)
      password=$(echo $line | cut -d';' -f4)
      dbtype=$(echo $line | cut -d';' -f6)

      bkp_name=$dbname\_$(date $TAMPON)

      if [ "$dbtype" = "mysql" ]; then
        # === MYSQL DUMP === # @FIXME mysqldump: [Password Warning]
        print_color "[>] $(date $TAMPON_LOCAL) - Dump mysql db '$dbname'" 34 $CONSOLE
        mysqldump --single-transaction -h$host -u$username -p$password $dbname > $BKP_FOLDER/mysql/$bkp_name.sql
        print_color "[+] $(date $TAMPON_LOCAL) - Dump mysql db '$dbname'" 32 $CONSOLE
        # === MYSQL DUMP SIZE ===
        # print_color "[i] $(date +%H:%M:%S) - Dump '$dbname' | $dbtype | $size" 34 $CONSOLE
        # mysql -h$host -u$username -p$password -e "SELECT table_schema 'DB',round(sum(data_length+index_length)/1024/1024,1) 'Size (MB)' from information_schema.tables WHERE table_schema = '$dbname';"

        # === MYSQL DUMP COMPRESSION ===
        print_color "[>] $(date $TAMPON_LOCAL) - Compression dump '$bkp_name.sql'" 34 $CONSOLE
        tar -czf $BKP_FOLDER/mysql/$bkp_name.sql.tar.gz $BKP_FOLDER/mysql/$bkp_name.sql
        print_color "[+] $(date $TAMPON_LOCAL) - Compression dump '$bkp_name.sql'" 32 $CONSOLE
        # === MYSQL DUMP SUPPRESSION ===
        if [ -e "$BKP_FOLDER/mysql/$bkp_name.sql" ];then
          print_color "[+] $(date $TAMPON_LOCAL) - Suppression dump '$bkp_name.sql'" 32 $CONSOLE
          rm -f $BKP_FOLDER/mysql/$bkp_name.sql
        fi

      elif [ "$dbtype" = "psql" ]; then
        # === PGSQL DUMP ===
        print_color "[>] $(date $TAMPON_LOCAL) - Dump pgsql db '$dbname'" 34 $CONSOLE
        PGPASSWORD="$password" pg_dump -h $host -p 5432 -U $username  -c $dbname > $BKP_FOLDER/pgsql/$bkp_name.sql
        PGPASSWORD="$password" pg_dump -h $host -p 5432 -U $username -Fc -c $dbname > $BKP_FOLDER/pgsql/$bkp_name.pg_dump.sql
        print_color "[+] $(date $TAMPON_LOCAL) - Dump pgsql db '$dbname'" 32 $CONSOLE
        # === PGSQL DUMP COMPRESSION ===
        print_color "[>] $(date $TAMPON_LOCAL) - Compression dump '$bkp_name.sql'" 34 $CONSOLE
        tar -czf $BKP_FOLDER/pgsql/$bkp_name.sql.tar.gz $BKP_FOLDER/pgsql/$bkp_name.sql
        print_color "[+] $(date $TAMPON_LOCAL) - Compression dump '$bkp_name.sql'" 32 $CONSOLE
        # === PGSQL DUMP SUPPRESSION ===
        if [ -e "$BKP_FOLDER/pgsql/$bkp_name.sql" ];then
          print_color "[+] $(date $TAMPON_LOCAL) - Suppression dump '$bkp_name.sql'" 32 $CONSOLE
          rm -f $BKP_FOLDER/pgsql/$bkp_name.sql
        fi

        print_color "[>] $(date $TAMPON_LOCAL) - Compression dump '$bkp_name.pg_dump.sql'" 34 $CONSOLE
        tar -czf $BKP_FOLDER/pgsql/$bkp_name.pg_dump.sql.tar.gz $BKP_FOLDER/pgsql/$bkp_name.pg_dump.sql
        print_color "[+] $(date $TAMPON_LOCAL) - Compression dump '$bkp_name.pg_dump.sql'" 32 $CONSOLE

        if [ -e "$BKP_FOLDER/pgsql/$bkp_name.pg_dump.sql" ];then
          print_color "[+] $(date $TAMPON_LOCAL) - Suppression dump '$bkp_name.pg_dump.sql'" 32 $CONSOLE
          rm -f $BKP_FOLDER/pgsql/$bkp_name.pg_dump.sql
        fi
      fi
    else
      print_color "[!] $(date $TAMPON_LOCAL) - Omitted '$dbname'" 33 $CONSOLE
    fi
  fi
done < $BKP_LIST_FILE

print_color " --- $(date +%Y/%m/%d\ %H:%M:%S) - FIN DES DUMPS --- " 30\;42 $CONSOLE
