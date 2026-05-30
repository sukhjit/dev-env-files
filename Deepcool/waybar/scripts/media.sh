#!/bin/bash

function animation() {
    animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
    while :; do
        for frame in "${animation_frames[@]}"; do
            echo "$frame"
            sleep 0.1
        done
    done
}

function media_status() {
    local status=$(playerctl metadata --format '{{status}} {{duration(position)}}/{{duration(mpris:length)}}' 2>/dev/null)

    if [[ $status == Paused* ]]; then
        echo "$status" | sed 's/^Paused/󰐊/g'
    elif [[ $status == Playing* ]]; then
        echo "$status" | sed 's/^Playing//g'
    else
        echo ""
    fi
}

media_status
