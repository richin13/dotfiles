#!/bin/bash

function dst {
  local ny_time=$(TZ=US/Eastern date +%R);
  echo "#[fg=#bd93f9,bold]$ny_time"

  # local tz_abbr=$(TZ=US/Eastern date +%Z);
  # [ $tz_abbr == "EDT" ] && echo "#[fg=#50fa7b,bold]dst" || echo "#[fg=#ff5555,bold]dst"
}

dst
