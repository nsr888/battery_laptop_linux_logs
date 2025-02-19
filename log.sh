#!/bin/bash

# Battery Status Logger
# Logs detailed battery information for specified batteries
# Usage: ./log.sh
# Creates dated logs in battery-specific directories

set -euo pipefail # Enable strict error handling

# Constants
SCRIPT_NAME=$(basename "$0")
readonly DATE_FORMAT="%Y%m%d"
readonly BATTERIES=("BAT0" "BAT1")
readonly UPOWER_PATH="/org/freedesktop/UPower/devices"

log() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[${timestamp}] ${SCRIPT_NAME} ${level}: ${message}"
}

INFO() { log "INFO" "$1"; }
WARN() { log "WARN" "$1" >&2; }
ERROR() { log "ERROR" "$1" >&2; }
DEBUG() { [[ "${DEBUG}" == "true" ]] && log "DEBUG" "$1"; }

get_battery_info() {
  local battery=$1
  upower -i "${UPOWER_PATH}/battery_${battery}" || return 1
}

extract_field() {
  local info=$1
  local field=$2
  echo "$info" | grep "$field" | cut -d ':' -f 2 | tr -d '[:space:]'
}

# Main execution
date=$(date +"$DATE_FORMAT")
INFO "Logging battery info for $date for batteries: ${BATTERIES[*]}"

for battery in "${BATTERIES[@]}"; do
  if ! battery_info=$(get_battery_info "$battery"); then
    ERROR "Failed to get info for battery $battery"
    continue
  fi

  # Extract battery details
  wh=$(extract_field "$battery_info" "energy-full-design" | cut -c1-2)
  serial=$(extract_field "$battery_info" "serial")
  capacity=$(extract_field "$battery_info" "capacity")

  # Display battery information
  INFO "Battery: $battery | energy-full-design: $wh | serial: $serial | capacity: $capacity"

  if [ -z "$wh" ]; then
    WARN "Battery $battery not found, skipping..."
    continue
  fi

  # Create log directory and save data
  battery_log_dir="${battery}_${wh}wh_${serial}"
  if ! mkdir -p "$battery_log_dir"; then
    ERROR "Failed to create directory $battery_log_dir"
    continue
  fi

  filename="${date}_${battery}_${wh}wh.txt"
  if ! echo "$battery_info" >"$battery_log_dir/$filename"; then
    ERROR "Failed to write to $filename"
    continue
  fi

  INFO "Successfully logged data for $battery"
done
