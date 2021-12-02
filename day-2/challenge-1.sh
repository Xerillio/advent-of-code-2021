#!/bin/bash

line_regex="(forward|down|up) (-?[0-9]+)"
horz_pos=0
vert_pos=0
line_count=0

while IFS=$' \t\r\n' read line
do
    ((line_count++))
    if [[ $line =~ $line_regex ]]; then
        direction=${BASH_REMATCH[1]}
        distance=${BASH_REMATCH[2]}
        
        case "$direction" in
            forward ) ((horz_pos+=$distance)) ;;
            down    ) ((vert_pos+=$distance)) ;;
            up      ) ((vert_pos-=$distance)) ;;
            *       )
                echo "Unexpected direction on line $line_count: $line"
                exit 3
                ;;
        esac
    else
        echo "Unexpected input on line $line_count. Expected matching regex '$line_regex' but was: '$line'"
        exit 3
    fi
done < "${1:-/dev/stdin}"

echo
echo "What do you get if you multiply your final horizontal position by your final depth?"
echo "Horizontal position: $horz_pos"
echo "Depth: $vert_pos"
echo "Resulting product: $((horz_pos*vert_pos))"
