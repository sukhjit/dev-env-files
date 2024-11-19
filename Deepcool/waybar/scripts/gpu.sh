#!/bin/bash

UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

echo "GPU: ${UTIL}% ${TEMP}°C"
