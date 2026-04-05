#!/usr/bin/env bash

woficmd="wofi --dmenu -k /dev/null"

word=$(wl-paste)

if [ -z "$word" ]; then
    echo "" | $woficmd -p "Enter a word"
fi

query=$(curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/$word")

if [ -z "$query" ]; then
    notify-send -h string:bgcolor:#bf616a -t 3000 "No word provided" && exit 0
fi

def=$(echo "$query" | jq -r '.[0].meanings[] | "\(.partOfSpeech): \(.definitions[0].definition)\n"')

notify-send -t 10000 "$word -" "$def"
