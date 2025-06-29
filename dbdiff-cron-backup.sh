#!/bin/bash

#====================================================================================================
# Title          : backup-cron.sh
# Description    : This script performs a database backup for MySQL and/or PostgreSQL.
# Author         : viniciuspaes
# Date           : 2016-03-04
# Version        : 1.2
# Usage          : ./backup-cron.sh
#
# Configuration:
#   - Create 3 folders: current, last, and gz.
#   - Edit the script to set folder paths: DIRCURRENT, DIRLAST, DIRGZ.
#   - Edit the script to set the user, password, and database name in the arrays.
#   - Comment out line 45 (PostgreSQL) or line 46 (MySQL) to disable one of the backups.
#
# How it works:
#   This script performs a database dump for backup purposes.
#   It compares the current dump with the previous one.
#   If they differ, it compresses the current dump and stores it.
#   If it is the first dump, it just save the compressed dump in gz folder.
#
# Directory structure:
#   1. current – contains the latest dump file.
#   2. last    – contains the previous dump file.
#   3. gz      – stores compressed versions of dumps that differ from the previous one.
#                This folder can be easily synced (e.g., with rsync) to the cloud,
#                a USB drive, or an external hard drive — enabling multi-layer backup strategies.
#
# Ownership:
#   The last line of the script uses the `chown` command to set ownership of the backup files.
#   You must edit this line to specify the correct username and group owner for your system,
#   as well as the correct path where your backup files are stored.
#
#   Example:
#     chown youruser:yourgroup /mnt/external-hd -R
#
#   This ensures proper permissions and access rights to the backup files,
#   which is essential for security and proper script operation.
#====================================================================================================

#BEGIN EDIT HERE

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
DIRCURRENT="/mnt/external-hd/current"
DIRLAST="/mnt/external-hd/pendrive/last"
DIRGZ="/mnt/external-hd/pendrive/gz"

ARRAYUSER=("user1" "user2" "user3" "user4" "user5")
ARRAYPASS=("pass1" "pass2" "pass3" "pass4" "pass5")
ARRAYDB=("db1" "db2" "db3" "db4" "db5")

#END EDIT HERE

#=======================================================================================
i=0
while [ $i -lt ${#ARRAYUSER[@]} ]; do
        echo "Processing USER - ${ARRAYUSER[$i]} and DATABASE ${ARRAYDB[$i]}"
#=======================================================================================
# Mysql or Postgres Backup - set # for line comment

#BEGIN EDIT HERE

        #Postgree Dump
        #PGPASSWORD=${ARRAYPASS[$i]} pg_dump -h 127.0.0.1 -p 5432 -U ${ARRAYUSER[$i]} ${ARRAYDB[$i]} | gzip > $DIRCURRENT/backup-${ARRAYUSER[$i]}_$timestamp.sql

        #MySQL Dump
        mysqldump --single-transaction --no-tablespaces --user=${ARRAYUSER[$i]} --password=${ARRAYPASS[$i]} --databases ${ARRAYDB[$i]} --skip-dump-date > $DIRCURRENT/backup-${ARRAYUSER[$i]}_$timestamp.sql

#END EDIT HERE
#=======================================================================================

        file="backup-${ARRAYUSER[$i]}_.sql"

        if [ -f "$DIRLAST/$file" ]
        then
                echo "Previous backup of $file found. Comparing for changes..."
                if ! diff -q $DIRLAST/$file $DIRCURRENT/backup-${ARRAYUSER[$i]}_$timestamp.sql > /dev/null ;
                then
                        echo "Changes found in the backup. Updating LAST folder and creating a new gz archive."
                        cp $DIRCURRENT/backup-${ARRAYUSER[$i]}_$timestamp.sql $DIRLAST/$file
                        gzip -c $DIRCURRENT/backup-${ARRAYUSER[$i]}_$timestamp.sql > $DIRGZ/backup-${ARRAYUSER[$i]}_$timestamp.sql.gz
                else
                        echo "No changes detected — backup already up to date."
                fi
        else
                echo "First backup of $file. Copying to the LAST folder and generating gz archive."
                mv $DIRCURRENT/backup-${ARRAYUSER[$i]}_$timestamp.sql $DIRCURRENT/backup-${ARRAYUSER[$i]}_.sql
                cp $DIRCURRENT/$file $DIRLAST/
                gzip -c $DIRCURRENT/$file > $DIRGZ/backup-${ARRAYUSER[$i]}_$timestamp.sql.gz
        fi

        echo "Process completed — removing contents from CURRENT directory."
        rm $DIRCURRENT/*

        let i++
done

#BEGIN EDIT HERE

chown youruser:yourgroup /mnt/external-hd -R

#END EDIT HERE
