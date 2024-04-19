#!/bin/bash

# inputs:
# ${MYSQL_USER} - mysql user of DB to be backed up (eg. root)
# ${MYSQL_PASSWORD} - password of user above

date_suffix="$(date +%FT%H-%M-%S)"

# here the dump is created and compressed
sqldump_dir='/mnt/cache'

# and here it is later moved
archive_dir='/mnt/archive/mariadbBackup'

sqldump_filename="alldb_backup_${date_suffix}.sql"

cd ${sqldump_dir}

/usr/bin/mysqldump -u ${MYSQL_USER} --password=${MYSQL_PASSWORD}  --all-databases > ${sqldump_filename}

# use single thread to not peak resources at sql server..
zstd --ultra --single-thread --rm ${sqldump_filename} --output-dir-flat ${archive_dir}

cd ${archive_dir}/

# ensure max 5 sql dumps are kept. as we backup servers time-by time, it should be enough..
find . -maxdepth 1 -type f | xargs -x ls -t | awk 'NR>5' | xargs -L1 rm
