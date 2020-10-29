#!/bin/bash

function rnd_music_icon {
  local status=$(playerctl status)

  if [ "$status" == "" ]; then
    echo "x"
    return 0
  fi

  if [ "$status" == "Paused" ]; then
    echo "🔈"
    return 0
  elif [ "$status" == "Playing" ]; then
    local rnd=$((1 + RANDOM % 12))
    if [ $rnd -lt 6 ]; then
      echo "🔉"
    else
      echo "🔊"
    fi
  fi

}

rnd_music_icon
