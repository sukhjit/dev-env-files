#!/bin/bash

CON_ICON=""
DIS_ICON=""

STATUS=$(mullvad status 2> /dev/null | head -1 | awk '{print $1}')

if [[ $STATUS == "Disconnected" ]]; then
    echo "D $DIS_ICON"
elif [[ $STATUS == "Connected" ]]; then
    echo "C $CON_ICON"
else
    echo "$STATUS"
fi
