#!/bin/bash

STATUS=$(mullvad status 2> /dev/null | head -1 | awk '{print $1}')

if [[ $STATUS == "Disconnected" ]]; then
    echo "Off"
elif [[ $STATUS == "Connected" ]]; then
    LOCATION=$(mullvad status 2> /dev/null | head -2 | tail -1 | awk '{print $2}')
    echo "${LOCATION}"
else
    echo "$STATUS"
fi
