#!/bin/bash

OBS=$(curl -s 'https://api.bom.gov.au/apikey/v1/observations/latest/66214/atm/surf_air?include_qc_results=false' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0' |
    jq '.obs')

UTC_DATE=$(echo $OBS | jq -r '.datetime_utc')
SYD_DATE=$(TZ=Australia/Sydney date -d "$UTC_DATE" +"%Y-%m-%d %H:%M:%S %Z")

DRYCELL=$(echo $OBS | jq '.temp.dry_bulb_1min_cel' | xargs printf "%.1f°C")
APPARENT=$(echo $OBS | jq '.temp.apparent_1min_cel' | xargs printf "%.1f°C")

echo "{\"text\": \"󰖨 ${DRYCELL}\", \"tooltip\": \"${SYD_DATE}: ${DRYCELL}, Feels like ${APPARENT}\"}"
