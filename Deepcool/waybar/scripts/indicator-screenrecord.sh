#!/bin/bash

if pgrep -x wl-screenrec >/dev/null || pgrep -x wf-recorder >/dev/null; then
  echo '{"text": "Stop recording", "class": "active"}'
else
  echo '{"text": "󰻂", "tooltip": "Start recording"}'
fi

