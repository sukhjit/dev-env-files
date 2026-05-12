#!/bin/bash

menu() {
    local prompt="$1"
    local options="$2"
    local extra="$3"
    local preselect="$4"

    read -r -a args <<<"$extra"

    if [[ -n $preselect ]]; then
        local index
        index=$(echo -e "$options" | grep -nxF "$preselect" | cut -d: -f1)
        if [[ -n $index ]]; then
            args+=("-c" "$index")
        fi
    fi

    echo -e "$options" | walker --dmenu --width 295 --minheight 1 --maxheight 630 -p "$prompt…" "${args[@]}" 2>/dev/null
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

audio() {
    case $(menu "Audio output" "  Headphones\n  Speakers") in
    *Speakers*)
        pactl set-default-sink "alsa_output.pci-0000_01_00.1.hdmi-stereo" &&
            notify-send "Audio switched to speakers"
        ;;
    *Headphones*)
        pactl set-default-sink "alsa_output.pci-0000_10_00.6.analog-stereo" &&
            notify-send "Audio switched to headphones"
        ;;
    esac
}

battery() {
    local devicesList=""
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

    local lineCount=$(echo -e $devicesList | wc -l)
    echo -e "$devicesList" | walker --width 100 --height $lineCount --dmenu -n
}

selectednote() {
    local noteFolder="$HOME/Dropbox/Documents/Notes/"

    local curfiles=$(find $noteFolder -type f -printf '%T@ %P\n' | sort -nr | cut -d' ' -f2-)
    local choice=$(
        echo -e "New\n$curfiles" | walker --dmenu --height 10 -p "Choose note or create new: "
    )

    case $choice in
    New)
        name="$(echo "" | walker --dmenu -p "Enter new file name without extension")" || exit 0
        : "${name:=$(date +%F_%H-%M-%S)}"
        setsid -f "$TERMINAL" -e nvim $noteFolder$name".md" >/dev/null 2>&1
        ;;
    *.md)
        setsid -f "$TERMINAL" -e nvim "$noteFolder$choice" >/dev/null 2>&1
        ;;
    *)
        exit
        ;;
    esac
}

tmuxRepos() {
    # list all projects
    local repoName="$(ls -1d "$HOME"/work/*/ 2>/dev/null | xargs -n1 basename)"

    [ -n "$repoName" ] || exit 0

    local chosen=$(echo -e "$repoName" | walker --dmenu -p 'Projects:')

    [ -n "$chosen" ] || exit 0

    local dir="$HOME/work/$chosen"

    tmux new-window -n "$chosen" -t 0: -c "$dir"
}

show_main_menu() {
    case $(menu "Choose" "  Project\n  Audio\n  Keybindings\n󰎚  Notes\n󱂩  NwgDock\n  Screenshot\n  Screenrecord\n  Battery\n󰃉  Color") in
    *Project*) tmuxRepos ;;
    *Audio*) audio ;;
    *Keybindings*) source $XDG_CONFIG_HOME/custom-scripts/keybindings.sh ;;
    *Notes*) selectednote ;;
    *NwgDock*) pgrep -f nwg-dock-hyprland && pkill -f nwg-dock-hyprland || nwg-dock-hyprland -i 30 -x -c walker ;;
    *Screenshot*) screenshot ;;
    *Screenrecord*) source $XDG_CONFIG_HOME/custom-scripts/start-stop-screenrecord.sh ;;
    *Battery*) battery ;;
    *Color*)
        walker --close
        hyprpicker
        ;;
    *) exit 0 ;;
    esac
}

show_main_menu
