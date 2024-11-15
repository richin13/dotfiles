#!/bin/bash

function dst {
  local caldate, cr_time, ny_time_diff, minute
  caldate=$(date +%m.%d)
  cr_time=$(TZ=America/Costa_Rica date +%H)
  ny_time_diff=$((10#$(TZ=US/Eastern date +%H) - 10#$(date +%H)))
  minute=$(date +%M)

  local cmp_et="#[fg=colour15,bold]+$ny_time_diff#[fg=colour15,none]"
  echo "#[fg=colour15]$caldate $cr_time$cmp_et:$minute"
}

dst
