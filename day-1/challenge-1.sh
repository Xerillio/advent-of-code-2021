#!/bin/bash

prev_depth=$(((1<<63)-1)) # Max integer value on a typical 64-bit system
result=0

while read line
do
    if [ $line -gt $prev_depth ]; then
        ((result++))
    fi
    prev_depth=$line
done < "${1:-/dev/stdin}"

echo
echo "How many measurements are larger than the previous measurement?"
echo "$result"
