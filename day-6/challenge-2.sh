#!/bin/bash

TARGET_DAYS=256

read input < "${1:-/dev/stdin}"

IFS=, # Split input by comma
fish_list=( $input )
tracked_fish=( $input )
# How many fish are giving birth on each weekday
prod_by_weekday=( 0 0 0 0 0 0 0 )
# How many fish, starting from next week, will give birth on each weekday
# (a new fish takes one week and 2 days to give birth and shouldn't count
# in 'prod_by_weekday' before next week)
prod_increase_next_week=( 0 0 0 0 0 0 0 )
fish_count=${#fish_list[@]}
IFS=$' '

echo "prod_by_weekday[0]=${prod_by_weekday[0]}"

# Calculate 'prod_by_weekday' for the initial fish
for fish in ${fish_list[@]}; do
    (( prod_by_weekday[$fish]++ ))
done

for (( day=0; day<$TARGET_DAYS; day++ )); do
    weekday=$(( $day%7 ))
    weekday_plus_2=$(( ($weekday+2)%7 ))
    daily_production=${prod_by_weekday[$weekday]}
    (( fish_count+=$daily_production ))
    # New fish just given birth will themselves give birth next week (in 9 days)
    (( prod_increase_next_week[$weekday_plus_2]+=$daily_production ))
    # We've already counted the daily production, so next week we should include
    # the fish from 'prod_increase_next_week'
    (( prod_by_weekday[$weekday]+=${prod_increase_next_week[$weekday]} ))
    prod_increase_next_week[$weekday]=0 # And reset it
    printf "Day %3d (%d/7) count: %6d - prod_by_weekday=( %4d %4d %4d %4d %4d %4d %4d )\n" $(( $day+1 )) $(( $weekday+1 )) $fish_count ${prod_by_weekday[@]}
done

echo
echo "How many lanternfish would there be after 256 days?"
echo "Fish count: $fish_count"
