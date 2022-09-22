#!/bin/sh

# Create export & log folders
mkdir -p /appdata/logs
mkdir -p /appdata/export

# create crontab file
echo "$CRON_SCHEDULE /bitwardenexport.sh >> /appdata/logs/bitwardenexport.log" >> /crontab.txt

# Put crontab file in place
/usr/bin/crontab /crontab.txt

# Create environment file
printenv | sed 's/^\(.*\)$/export \1/g' > /environment.sh
chmod +x /environment.sh

# start cron
/usr/sbin/crond -f -l 8