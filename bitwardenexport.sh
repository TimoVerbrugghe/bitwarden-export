#!/bin/bash

## Configuration variables ##

ENV_FILE=/environment.sh
APPDATAFOLDER=/appdata
EXPORTFOLDER="$APPDATAFOLDER"/export
EXPORTFILE="$EXPORTFOLDER"/vaultbackup.json
BACKUPFILE="$APPDATAFOLDER"/logs/bitwardenexport.log

## Emptying log ##
truncate -s 0 "$BACKUPFILE"

## Starting Backup ##
echo "Starting backup of bitwarden. Current date & time is $(date)."

## Loading Variables ##
echo "Loading Client ID, Client Secret, Server and Password variables."

source <(cat "$ENV_FILE" | grep "BW_CLIENTID")
source <(cat "$ENV_FILE" | grep "BW_CLIENTSECRET")
source <(cat "$ENV_FILE" | grep "BW_SERVER")
source <(cat "$ENV_FILE" | grep "BW_PASSWORD")

## Connecting to Bitwarden Server ##
echo "Connecting to bitwarden server $BW_SERVER."
bw config server "$BW_SERVER"
bw login --apikey

BW_SESSION=$(bw unlock --raw --passwordenv BW_PASSWORD)
bw sync

## Exporting vault ##
echo "Exporting user vault."
bw export --format json --session "$BW_SESSION" --output "$EXPORTFILE"

## Exporting organizations ##
echo "Getting list of all organizations."
ORGS=$(bw list organizations --session $BW_SESSION)
ORGLENGTH=$(echo "$ORGS" | jq '. | length');

if [[ $ORGLENGTH -gt 0 ]]
then
    for ((i = 0; i <= $ORGLENGTH - 1; i++)); do
        orgname=$(echo "$ORGS" | jq -r --argjson index $i '.[$index] | .name')
        echo "Exporting vault for organization $orgname"
        orgid=$(echo "$ORGS" | jq -r --argjson index $i '.[$index] | .id')
        bw export --format json --organizationid $orgid --session "$BW_SESSION" --output "$EXPORTFOLDER/orgbackup_$orgname_$(date '+%d%m%Y').json"
    done
else
    echo "No organizations found."
fi

## Cleanup ##

echo "Backup done. Locking vault & logging out."
bw lock
bw logout

exit