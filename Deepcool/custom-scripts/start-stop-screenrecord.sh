#!/bin/bash

OUTPUT_DIR="${HOME}/Videos"

if [[ ! -d "$OUTPUT_DIR" ]]; then
  notify-send "Screen recording directory missing: $OUTPUT_DIR" -u critical -t 3000
  exit 1
fi

start_screenrecording() {
  local filename="$OUTPUT_DIR/screenrecording-$(date +'%Y%m%d_%H%M%S').mp4"
  wf-recorder --audio -f "$filename" -c libx264 -p crf=23 -p preset=medium -p movflags=+faststart "$@" &
  toggle_screenrecording_indicator
}

stop_screenrecording() {
  pkill -x wf-recorder

  notify-send "Screen recording saved to $OUTPUT_DIR" -t 5000

  sleep 0.2 # ensures the process is actually dead before we check
  toggle_screenrecording_indicator
}

toggle_screenrecording_indicator() {
  pkill -RTMIN+8 waybar
}

screenrecording_active() {
  pgrep -x wf-recorder >/dev/null
}

if screenrecording_active; then
  stop_screenrecording
else
  region=$(slurp) || exit 1
  start_screenrecording -g "$region"
fi
