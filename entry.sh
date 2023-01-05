#!/bin/sh

echo "Setting up environment after container restart (folders, crontab file creation, etc...)"

# Create export & log folders
mkdir -p /appdata/export

# create crontab file
touch /crontab.txt
truncate -s 0 /crontab.txt
echo "$CRON_SCHEDULE /bitwardenexport.sh" >> /crontab.txt

# Put crontab file in place
/usr/bin/crontab /crontab.txt

# Create environment file
printenv | sed 's/^\(.*\)$/export \1/g' > /environment.sh
chmod +x /environment.sh

echo "Starting cron"

# start cron
/usr/sbin/crond -f -l 8