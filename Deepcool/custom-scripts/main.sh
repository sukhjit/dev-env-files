#!/bin/sh

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
    menu=" Project\n  Audio\n Keybindings\n󰎚 Note\n󱂩 NwgDock\n Screenshot\n Screenrecord\n Battery\n󰃭 Calendar\n Cancel"

    walinecount=$(echo -e $menu | wc -l)
    selected="$(echo -e $menu | walker --width 100 --height $walinecount --dmenu -p "Apps" | awk '{print tolower ($2)}')"

    case $selected in
    project)
        source $XDG_CONFIG_HOME/custom-scripts/tmux-repo.sh
        ;;
    audio)
        source $XDG_CONFIG_HOME/custom-scripts/audioswitch.sh
        ;;
    calculator)
        calculator
        ;;
    note)
        source $XDG_CONFIG_HOME/custom-scripts/notes.sh
        ;;
    nwgdock)
        pgrep -f nwg-dock-hyprland && pkill -f nwg-dock-hyprland || nwg-dock-hyprland -i 30 -x -c walker
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
    calendar)
        cal | walker --dmenu -p "Calendar"
        ;;
    cancel)
        exit 0
        ;;
    esac
}

show_main_menu
