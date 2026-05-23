#!/bin/bash

function dst {
  local caldate minute cr_time cr_hour ny_hour ny_time_diff cmp_et

  caldate=$(date +%m.%d)
  minute=$(date +%M)

  cr_time=$(TZ=America/Costa_Rica date +%H)
  cr_hour=$(TZ=America/Costa_Rica date +%k) # %k is hour (0..23)
  ny_hour=$(TZ=US/Eastern date +%k)

  ny_time_diff=$(( 10#$ny_hour - 10#$cr_hour ))

  if [ $ny_time_diff -lt -12 ]; then
    ny_time_diff=$(( ny_time_diff + 24 ))
  elif [ $ny_time_diff -gt 12 ]; then
    ny_time_diff=$(( ny_time_diff - 24 ))
  fi

  cmp_et="#[fg=colour15,bold]+$ny_time_diff#[fg=colour15,none]"
  echo "#[fg=colour15]$caldate $cr_time$cmp_et:$minute"
}

dst
