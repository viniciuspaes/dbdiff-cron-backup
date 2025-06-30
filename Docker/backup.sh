#!/bin/bash

TIMESTAMP_FORMAT="${TIMESTAMP_FORMAT:-+%Y-%m-%d_%H-%M-%S}"
timestamp=$(date "$TIMESTAMP_FORMAT")
DIRCURRENT="/backup/current"
DIRLAST="/backup/last"
DIRGZ="/backup/gz"
IFS=',' read -ra ARRAYUSER <<< "$DB_USERS"
IFS=',' read -ra ARRAYPASS <<< "$DB_PASSWORDS"
IFS=',' read -ra ARRAYDB <<< "$DB_DATABASES"

i=0
while [ $i -lt ${#ARRAYUSER[@]} ]; do
    echo "Processing USER - ${ARRAYUSER[$i]} and DATABASE ${ARRAYDB[$i]}"

# Mysql or Postgres Dump

    if [[ "$DB_TYPE" == "postgres" ]]; then
        PGPASSWORD=${ARRAYPASS[$i]} pg_dump \
            -h "${DB_HOST}" -p "${DB_PORT}" -U "${ARRAYUSER[$i]}" "${ARRAYDB[$i]}" \
            > "$DIRCURRENT/backup-${ARRAYDB[$i]}_$timestamp.sql"

    elif [[ "$DB_TYPE" == "mysql" ]]; then
        mysqldump --single-transaction --no-tablespaces \
            --host="${DB_HOST}" --port="${DB_PORT}" \
            --user="${ARRAYUSER[$i]}" --password="${ARRAYPASS[$i]}" \
            --databases "${ARRAYDB[$i]}" --skip-dump-date \
            > "$DIRCURRENT/backup-${ARRAYDB[$i]}_$timestamp.sql"

    else
        echo "Unsupported DB_TYPE: $DB_TYPE"
        exit 1
    fi



# Diff and creation of compressed gz if needed

        file="backup-${ARRAYDB[$i]}_.sql"

        if [ -f "$DIRLAST/$file" ]
        then
                echo "Previous backup of $file found. Comparing for changes..."
                if ! diff -q $DIRLAST/$file $DIRCURRENT/backup-${ARRAYDB[$i]}_$timestamp.sql > /dev/null ;
                then
                        echo "Changes found in the backup. Updating LAST folder and creating a new gz archive."
                        cp $DIRCURRENT/backup-${ARRAYDB[$i]}_$timestamp.sql $DIRLAST/$file
                        gzip -c $DIRCURRENT/backup-${ARRAYDB[$i]}_$timestamp.sql > $DIRGZ/backup-${ARRAYDB[$i]}_$timestamp.sql.gz
                else
                        echo "No changes detected — backup already up to date."
                fi
        else
                echo "First backup of $file. Copying to the LAST folder and generating gz archive."
                mv $DIRCURRENT/backup-${ARRAYDB[$i]}_$timestamp.sql $DIRCURRENT/backup-${ARRAYDB[$i]}_.sql
                cp $DIRCURRENT/$file $DIRLAST/
                gzip -c $DIRCURRENT/$file > $DIRGZ/backup-${ARRAYDB[$i]}_$timestamp.sql.gz
        fi

        echo "Process completed — removing contents from CURRENT directory."
        rm $DIRCURRENT/*

        let i++
done

chown ${BACKUP_OWNER}:${BACKUP_GROUP} /mnt/external-hd -R
