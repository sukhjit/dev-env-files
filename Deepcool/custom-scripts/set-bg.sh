#!/bin/bash

if [[ -z $1 ]]; then
  echo "Usage: $0 <path-to-image>" >&2
  exit 1
fi

BACKGROUND="$(realpath "$1")"

if [[ ! -f "$BACKGROUND" ]]; then
  echo "File does not exist: $BACKGROUND" >&2
  exit 1
fi

# Kill existing swaybg and start new one
pkill -x swaybg
setsid uwsm-app -- swaybg -i "$BACKGROUND" -m fill >/dev/null 2>&1 &
