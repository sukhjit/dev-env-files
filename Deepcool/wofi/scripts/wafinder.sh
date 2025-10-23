#!/bin/sh

menu="  Audio\n Calculator\n󰎚 Note\n Screenshot\n Battery\n Cancel"

walinecount=$(echo -e $menu | wc -l)

selected=$(echo -e $menu | wofi -W 10% --dmenu --line $walinecount --cache-file /dev/null -p "Apps" | awk '{print tolower ($2)}')

calculator() {
    notify-send $(wofi -W 10% --dmenu --line 1 -p "calc" | bc -l 2>/dev/null)
}

note() {
    source ~/.config/wofi/scripts/notes.sh
}

screenshot() {
    hyprshot -m region
}

battery() {
    source ~/.config/wofi/scripts/battery.sh
}

audioswitch() {
    source ~/.config/wofi/scripts/audioswitch.sh
}

case $selected in
audio) audioswitch ;;
calculator) calculator ;;
note) note ;;
screenshot) screenshot ;;
battery) battery ;;
cancel) exit 0 ;;
esac
