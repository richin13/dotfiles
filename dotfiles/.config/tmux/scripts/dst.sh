#!/bin/bash

function dst {
  local caldate=$(date +%m.%d)
  local cr_time=$(TZ=America/Costa_Rica date +%H)
  local ny_time=$(TZ=US/Eastern date +%H);
  local minute=$(date +%M)

  local cmp_et="#[fg=#bd93f9,bold]$ny_time#[fg=#f8f8f2,none]"
  echo "#[fg=#f8f8f2]$caldate $cr_time($cmp_et):$minute"
}

dst
