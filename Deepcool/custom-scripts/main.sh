#!/bin/sh

calculator() {
    notify-send $(wofi -W 10% --dmenu --line 1 -p "calc" | bc -l 2>/dev/null)
}

screenshot() {
    hyprshot -m region --raw |
        satty --filename - \
            --output-filename "$HOME/screenshots/$(date +'%Y-%m-%d-%H%M%S').png" \
            --early-exit \
            --actions-on-enter save-to-clipboard \
            --save-after-copy \
            --copy-command 'wl-copy'
}

show_main_menu() {
    menu="  Audio\n Calculator\n Keybindings\n󰎚 Note\n Screenshot\n Screenrecord\n Battery\n Cancel"

    walinecount=$(echo -e $menu | wc -l)

    selected=$(echo -e $menu | wofi -W 10% --dmenu --line $walinecount --cache-file /dev/null -p "Apps" | awk '{print tolower ($2)}')

    case $selected in
    audio)
        source $XDG_CONFIG_HOME/custom-scripts/audioswitch.sh
        ;;
    calculator)
        calculator
        ;;
    note)
        source $XDG_CONFIG_HOME/custom-scripts/notes.sh
        ;;
    screenshot)
        screenshot
        ;;
    screenrecord)
        source $XDG_CONFIG_HOME/custom-scripts/start-stop-screenrecord.sh
        ;;
    keybindings)
        source $XDG_CONFIG_HOME/custom-scripts/keybindings.sh
        ;;
    battery)
        source $XDG_CONFIG_HOME/custom-scripts/battery.sh
        ;;
    cancel)
        exit 0
        ;;
    esac
}

show_main_menu
