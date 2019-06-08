#!/usr/bin/env bash
#
# This simple script uses bash to set a random wallpaper
# by using feh, seamlessly spanning it across monitors.
#
# usage: feh-slideshow [minutes] [--restore]
#
# Original source (for nitrogen) available at:
# https://github.com/SvenPM/bits-and-pieces/blob/master/wallpaperrandomizer/nitrogenium-basic.sh

# set wallpapers path #

WP_PATH="/home/$USER/Pictures/Wallpapers/"

# set script vars #

CONFIG="/home/$USER/.fehbg" # feh background configuration file

ARGUMENT="$(echo "$1" | sed s:-::g)"
NUM_SCREENS=$(xrandr | grep -c "*") # $(xrandr | grep -c connected -w)

# set functions #

help() {
    head -n 7 "$0" | tail -n 1 | sed 's/# //'; }

set_restore() {
    # set last wallpaper from feh or nitrogen
    CURRENT=`tail -n 1 "$CONFIG" | sed "s/feh --bg-fill //;s/feh --bg-tile //;s:' ::g;s:'::g"`
    [[ $NUM_SCREENS = 1 ]] && feh --bg-fill "${CURRENT}" || feh --bg-tile "${CURRENT}"; }

set_random() {
    # check if folder exists, otherwise return last wallpaper set
    if [[ ! -d "$WP_PATH" ]]; then
        set_restore; fi
    # make sure there are enough wallpapers available
    # randomizing doesn't make a lot of sense with only a few wallies
    COUNT=`ls $WP_PATH | grep -Eic ".*\.(png|jpe?g|bmp)"`
    # pick a random wallpaper from these directories
    CURRENT=`tail -n 1 "$CONFIG" | sed "s/feh --bg-fill //;s/feh --bg-tile //;s:' ::g;s:'::g"`
    NEW="$(ls $WP_PATH | grep -Ei ".*\.(png|jpe?g|bmp)" | shuf -n 1)"
    # make sure it's different from the current wallpaper
    while [[ "$NEW" = "$CURRENT" || "${WP_PATH}${NEW}" = "$CURRENT" ]]; do
        NEW="$(ls $WP_PATH | grep -Ei ".*\.(png|jpe?g|bmp)" | shuf -n 1)"; done
    # apply wallpaper according to screens connected
    [[ $NUM_SCREENS = 1 ]] && feh --bg-fill "${WP_PATH}${NEW}" || feh --bg-tile "${WP_PATH}${NEW}"; }

# execute #

if [[ "$ARGUMENT" = "restore" ]]; then
    set_restore

elif [[ "$ARGUMENT" != "" && "$ARGUMENT" > 0 ]]; then
    # set seconds to sleep
    SECONDS=$(( $ARGUMENT * 60 ))
    [[ "$SECONDS" = 0 ]] && set_random ||
    while true; do
        # keep changing wallpaper
        set_random
        sleep $SECONDS
    done #; fi

else # change wallpaper once only
    set_random; fi
