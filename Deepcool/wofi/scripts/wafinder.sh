#!/bin/sh

menu=" Calculator\n󰎚 Note\n Cancel"

selected=$(echo -e $menu | wofi -W 10% --dmenu --line 4 --cache-file /dev/null -p "Apps" | awk '{print tolower ($2)}')

calculator () {
    notify-send $(wofi -W 10% --dmenu --line 1  -p "calc" | bc -l 2>/dev/null)
}

note () {
    source ~/.config/wofi/scripts/notes.sh
}

case $selected in
   calculator)
      calculator;;
   note)
      note;;
   cancel)
      exit 0;;
esac
