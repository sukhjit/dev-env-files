#!/bin/sh

if fuser /dev/video* >/dev/null 2>&1; then
    echo '{"text": " ", "class": "active"}' # Using a Nerd Font icon
else
    echo '{"text": "", "class": "inactive"}'
fi
