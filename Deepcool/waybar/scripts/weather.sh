#!/bin/bash

WEATHER_API="https://api.bom.gov.au/apikey/v1/observations/latest/66214/atm/surf_air?include_qc_results=false"
WEATHER_URL="https://www.bom.gov.au/location/australia/new-south-wales/metropolitan/o18375402-chatswood"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0"

function open_url() {
    librewolf --kiosk --safe-mode --private-window $1
}

function get_weather() {
    local OBS=$(curl -s $WEATHER_API \
        -H 'User-Agent: ' $USER_AGENT |
        jq '.obs')

    local UTC_DATE=$(echo $OBS | jq -r '.datetime_utc')
    local SYD_DATE=$(TZ=Australia/Sydney date -d "$UTC_DATE" +"%Y-%m-%d %H:%M:%S %Z")

    local DRYCELL=$(echo $OBS | jq '.temp.dry_bulb_1min_cel' | xargs printf "%.1f°C")
    local APPARENT=$(echo $OBS | jq '.temp.apparent_1min_cel' | xargs printf "%.1f°C")

    echo "{\"text\": \"󰖨 ${DRYCELL}\", \"tooltip\": \"${SYD_DATE}: ${DRYCELL}, Feels like ${APPARENT}\"}"
}

if [[ ! -z "${1}" ]]; then
    open_url $WEATHER_URL
fi

get_weather
