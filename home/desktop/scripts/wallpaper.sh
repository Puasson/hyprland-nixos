#!/usr/bin/env bash

set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
INTERVAL=600

pgrep -x awww-daemon >/dev/null || {
  awww-daemon &
  sleep 1
}

last_wallpaper=""

while true; do
  mapfile -t wallpapers < <(
    find "$WALLPAPER_DIR" -type f \
      \( \
      -iname "*.jpg" -o \
      -iname "*.jpeg" -o \
      -iname "*.png" -o \
      -iname "*.webp" \
      \)
  )

  ((${#wallpapers[@]} == 0)) && sleep "$INTERVAL" && continue

  while :; do
    wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"

    [[ "$wallpaper" != "$last_wallpaper" ]] && break

    ((${#wallpapers[@]} == 1)) && break
  done

  transition=$(shuf -e \
    grow \
    outer \
    wipe \
    wave \
    random \
    any \
    center \
    top \
    bottom \
    left \
    right \
    simple \
    --head-count=1)

  awww img "$wallpaper" \
    --transition-type "$transition" \
    --transition-duration 0.5 \
    --transition-fps 60

  last_wallpaper="$wallpaper"

  sleep "$INTERVAL"
done