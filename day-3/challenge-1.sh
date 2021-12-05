#!/bin/bash

gamma=()
line_count=0

while IFS=$' \t\r\n' read line
do
    for (( i=0; i<${#line}; i++ )); do
        char=${line:$i:1}
        ((gamma[$i]+=$char))
    done
    ((line_count++))
done < "${1:-/dev/stdin}"

epsilon=()
threshold=$((line_count/2))
for (( i=0; i<${#gamma[@]}; i++)); do
    gamma[$i]=$((${gamma[$i]}/$threshold))
    epsilon[$i]=$((${gamma[$i]}*-1+1))
done

gamma=$(printf %s "${gamma[@]}")
epsilon=$(printf %s "${epsilon[@]}")

echo
echo "What is the power consumption of the submarine?"
echo "gamma:   $gamma"
echo "epsilon: $epsilon"
echo "Power: $((2#$gamma * 2#$epsilon))"
