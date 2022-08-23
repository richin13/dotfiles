#!/bin/bash

function dst {
  local caldate, cr_time, ny_time_diff, minute
  caldate=$(date +%m.%d)
  cr_time=$(TZ=America/Costa_Rica date +%H)
  ny_time_diff=$((10#$(TZ=US/Eastern date +%H) - 10#$(date +%H)))
  minute=$(date +%M)

  local cmp_et="#[fg=#bd93f9,bold]+$ny_time_diff#[fg=#f8f8f2,none]"
  echo "#[fg=#f8f8f2]$caldate $cr_time$cmp_et:$minute"
}

dst
