#!/bin/bash

function dst {
  local tz_abbr=$(TZ=US/Eastern date +%Z);
  [ $tz_abbr == "EDT" ] && echo "on" || echo "off"
}

dst
