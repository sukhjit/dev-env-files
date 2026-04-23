#!/usr/bin/env bash

folder="$HOME/Dropbox/Documents/Notes/"
walkercmd="walker --dmenu"

newnote() {
    name="$(echo "" | $walkercmd -p "Enter a name")" || exit 0
    : "${name:=$(date +%F_%H-%M-%S)}"
    setsid -f "$TERMINAL" -e nvim $folder$name".md" >/dev/null 2>&1
}

selected() {
    curfiles=$(find $folder -type f -printf '%T@ %P\n' | sort -nr | cut -d' ' -f2-)
    choice=$(
        echo -e "New\n$curfiles" | $walkercmd --dmenu --height 10 -p "Choose note or create new: "
    )

    case $choice in
    New) newnote ;;
    *.md) setsid -f "$TERMINAL" -e nvim "$folder$choice" >/dev/null 2>&1 ;;
    *) exit ;;
    esac
}

selected
