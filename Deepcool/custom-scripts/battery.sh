#!/usr/bin/env bash

devicesList=""
for item in $(upower --enumerate); do
    info=$(upower --show-info $item)
    model=$(echo "$info" | grep -e 'model')
    percentage=$(echo "$info" | grep -e 'percentage')

    if [[ "$model" == "" ]]; then
        # missing model
        continue
    fi

    if [[ "$percentage" == "" ]]; then
        # missing percentage
        continue
    fi

    # clean up
    model=$(echo "$model" | sed 's/model://' | xargs)
    percentage=$(echo "$percentage" | sed 's/percentage://')
    percentage=$(echo "$percentage" | sed 's/(should be ignored)//' | xargs)

    devicesList="${devicesList}${model}: ${percentage}\n"
done

lineCount=$(echo -e $devicesList | wc -l)
echo -e "$devicesList" | wofi -W 20% --line $lineCount --dmenu --cache-file /dev/null -j
