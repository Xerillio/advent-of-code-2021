#!/bin/bash

# "2D" array - actually it's an "associative" array
declare -A floor

regex="([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)"
x_max=-1
y_max=-1

set_xy_increments () {
    [ $x1 -lt $x2 ] && x_inc=1
    [ $x1 -gt $x2 ] && x_inc=-1
    [ $x1 -eq $x2 ] && x_inc=0

    [ $y1 -lt $y2 ] && y_inc=1
    [ $y1 -gt $y2 ] && y_inc=-1
    [ $y1 -eq $y2 ] && y_inc=0
}

set_xy_maxes () {
    [ $x_max -lt $x1 -a $x2 -le $x1 ] && x_max=$x1
    [ $x_max -lt $x2 -a $x1 -lt $x2 ] && x_max=$x2
    [ $y_max -lt $y1 -a $y2 -le $y1 ] && y_max=$y1
    [ $y_max -lt $y2 -a $y1 -lt $y2 ] && y_max=$y2
}

while IFS=$' \t\r\n' read line
do
    [[ ! $line =~ $regex ]] && continue
    x1=${BASH_REMATCH[1]}
    y1=${BASH_REMATCH[2]}
    x2=${BASH_REMATCH[3]}
    y2=${BASH_REMATCH[4]}

    set_xy_increments
    set_xy_maxes

    x=$x1-$x_inc
    y=$y1-$y_inc
    while
        ((x+=$x_inc))
        ((y+=$y_inc))
        new_val=$(( ${floor["${x}_${y}"]} + 1 ))
        floor["${x}_${y}"]=$new_val
        [ $x != $x2 -o $y != $y2 ]
    do true; done
done < "${1:-/dev/stdin}"

overlap_count=0
for (( y=0; y<=$y_max; y++ )); do
    for (( x=0; x<=$x_max; x++)); do
        value=${floor["${x}_${y}"]}
        [[ $value -gt 1 ]] && ((overlap_count++))
        # Uncomment to print out the see floor map - may take a while (also the one echo below)
        # [ -z "$value" ] && value="."
        # printf "%2s" "$value"
    done
    # echo
done

echo
echo "At how many points do at least two lines overlap?"
echo "Overlap: $overlap_count"
