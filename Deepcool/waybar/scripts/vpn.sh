#!/bin/bash

STATUS=$(mullvad status 2>/dev/null | head -1 | awk '{print $1}')

PREFIX="VPN"
if [[ $STATUS == "Disconnected" ]]; then
    echo ${PREFIX}
elif [[ $STATUS == "Connected" ]]; then
    LOCATION=$(mullvad status 2>/dev/null | head -2 | tail -1 | awk '{print $2}')
    echo "${PREFIX}: ${LOCATION}"
else
    echo "${PREFIX}: ${STATUS}"
fi
