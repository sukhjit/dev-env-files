#!/usr/bin/env bash

# list all projects
repoName="$(ls -1d "$HOME"/work/*/ 2>/dev/null | xargs -n1 basename)"

[ -n "$repoName" ] || exit 0

# select a project
chosen="$(printf '%s\n' $repoName | walker --dmenu -p 'Projects:')"

[ -n "$chosen" ] || exit 0

dir="$HOME/work/$chosen"

tmux new-window -n "$chosen" -t 0: -c "$dir"
