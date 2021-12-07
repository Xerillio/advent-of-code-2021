#!/bin/bash

TARGET_DAYS=40

read input < "${1:-/dev/stdin}"

IFS=, # Split input by comma
fish_list=( $input )

for (( day=0; day<$TARGET_DAYS; day++ )); do
    daily_count=${#fish_list[@]} # Keep count at start of day
    for (( i=0; i<$daily_count; i++ )); do
        int_count=${fish_list[$i]}
        if [ "$int_count" == "0" ]; then
            int_count=6
            fish_list+=( 8 ) # Add new fish
        else
            (( int_count-- ))
        fi
        fish_list[$i]=$int_count
    done
    # Uncomment to print out numbers at the end of each day
    # printf "%s %2d %s %s\n" "After" $(($day+1)) "day:" "$( tr " " "," <<< ${fish_list[@]} )"
    tr " " "," <<< ${fish_list[@]}
done

echo
echo "How many lanternfish would there be after 80 days?"
echo "Fish count: ${#fish_list[@]}"
