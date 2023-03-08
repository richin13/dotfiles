#!/bin/zsh
# Source: https://github.com/Townk/tmux-config/blob/master/scripts/window-flags
# Replace tmux window flag for a unicode character:
# *: current window flag removed
# -: last window flag replaced by (⦁)
# #: window activity flag replaced by ()
# ~: window silence flag replaced by ()
# !: window bell flag replaced by ()
# Z: window zoomed flag replaced by ()
#
# Example:
#    1:Window⦁

FLAGS=${${${${${${1//\!/}//\~/}//\#/}//Z/ }//\-/}//\*/}

# And then, if needed, we prepend the "last window" flag since
# I want it to be right after the window title
if [[ "$1" =~ "-" ]]; then
    FLAGS="${FLAGS}"
fi

echo "${FLAGS}"
