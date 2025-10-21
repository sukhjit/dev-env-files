#!/usr/bin/env bash

menu=" Calculator\n Cancel"

selected=$(echo -e $menu | wofi -W 10% --dmenu --line 4 --cache-file /dev/null -p "Apps" | awk '{print tolower ($2)}')

calculator () {
    notify-send $(wofi -W 10% --dmenu --line 1  -p "calc" | bc -l 2>/dev/null)
}

case $selected in
   calculator)
      calculator;;
   cancel)
      exit 0;;
esac
