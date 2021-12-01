#!/bin/bash

WND_SIZE=3
sliding_wnd=()
result=0

# For return value of the func, use a global variable to
# avoid slow subshells in the while loop below
LAST_SUM=0
get_sum () {
    arr=("$@")
    sum=0
    for i in "${arr[@]}"; do
        let sum+=$i
    done
    LAST_SUM=$sum
}

# Exclude leading and trailing whitespace (incl. line break)
# when reading each line to parse numbers properly
while IFS=$' \t\r\n' read line
do
    sliding_wnd+=($line)
    if [ ${#sliding_wnd[@]} -le $WND_SIZE ]; then
        continue # Wait until we have WND_SIZE + 1 elements
    fi

    # '${sliding_wnd[*]:0:$WND_SIZE}' returns a section of an array
    # starting from index 0 and length $WND_SIZE.
    get_sum "${sliding_wnd[@]:0:$WND_SIZE}"
    prev_wnd_sum=$LAST_SUM
    get_sum "${sliding_wnd[@]:1:$WND_SIZE}"
    this_wnd_sum=$LAST_SUM

    if [ $this_wnd_sum -gt $prev_wnd_sum ]; then
        ((result++))
    fi

    # Shift array 1 position up (losing the value at index 0)
    sliding_wnd=(${sliding_wnd[@]:1})
done < "${1:-/dev/stdin}"

echo
echo "How many sums are larger than the previous sum?"
echo "$result"
