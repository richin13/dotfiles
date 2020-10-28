#!/bin/bash

function rnd_music_icon {
  local status=$(playerctl status)
  local rnd=$((1 + RANDOM % 12))

  if [ "$status" != "Playing" ]; then
    echo "🔈"
    return 0
  fi

  if [ $rnd -lt 6 ]; then
    echo "🔉"
  else
    echo "🔊"
  fi
}

rnd_music_icon
