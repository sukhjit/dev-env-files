#!/usr/bin/env bash

headphones() {
    pactl set-default-sink "alsa_output.pci-0000_10_00.6.analog-stereo" &&
        notify-send "Audio switched to headphones"
}

speakers() {
    pactl set-default-sink "alsa_output.pci-0000_01_00.1.hdmi-stereo" &&
        notify-send "Audio switched to speakers"
}

choosespeakers() {
    options="Headphones\nSpeakers"
    choice=$(echo -e "$options" | wofi --dmenu --cache-file /dev/null -W 10% -i -L 3 -p "Choose audio:")

    case "$choice" in
    Speakers) speakers ;;
    Headphones) headphones ;;
    esac
}

choosespeakers
