#!/bin/bash

WINNING_BOARD=-1
get_winning_board () {
    for (( board=0; board<$board_count; board++ )); do
        cols_all_x=( ${DEFAULT_COLS_ALL_X[@]} )
        for (( row=0; row<$rows; row++)); do
            row_all_x=1
            for (( col=0; col<$cols; col++)); do
                idx=$(( $board*$rows*$cols + $row*$rows + $col ))
                [ "${board_numbers[$idx]}" != "$MARK" ] && row_all_x=0 && cols_all_x[$col]=0
            done
            [ "$row_all_x" == "1" ] && WINNING_BOARD=$board && return 0 # Found winner, stop searching
        done
        [[ " ${cols_all_x[@]} " =~ " 1 " ]] && WINNING_BOARD=$board && return 0 # Found winner, stop searching
    done
}

MARK="X"
line_count=0
lines=()

while IFS=$'\r\n' read line
do
    lines+=("$line")
    ((line_count++))
done < "${1:-/dev/stdin}"

draw_bag=${lines[0]}
IFS=$',' # To split the draw bag into individual numbers
draw_bag=(${draw_bag[@]})
IFS=$' \t\r\n'
lines=("${lines[@]:2}")

rows=0
for line in "${lines[@]}"; do [[ -z "$line" ]] && break || ((rows++)); done
cols=$( grep -oE "\S+" <<< ${lines[0]} | wc -l )
board_count=0
for line in "${lines[@]}"; do [[ -n "$line" ]] && ((board_count++)); done
board_count=$(( $board_count/$rows ))
DEFAULT_COLS_ALL_X=( $(for i in $(seq 1 $cols); do echo 1; done) ) # = ( 1 1 1 1 1 )

board_numbers=(${lines[@]})

for drawn_num in ${draw_bag[@]}; do
    for (( i=0; i<${#board_numbers[@]}; i++ )); do
        if (( $drawn_num == ${board_numbers[$i]} )); then
            board_numbers[$i]=$MARK
        fi
    done
    get_winning_board
    if [ "$WINNING_BOARD" != "-1" ]; then
        sIdx=$(( $WINNING_BOARD*$rows*$cols ))
        len=$(( $rows*$cols ))
        remaining_nums=( $( grep -oE "[0-9]+" <<< ${board_numbers[@]:$sIdx:$len} ) )
        remaining_sum=$( IFS=+; echo "$(( ${remaining_nums[*]} ))" )
        break
    fi
done

echo
echo "What will your final score be if you choose that board?"
echo "Last number drawn: $drawn_num"
echo "Winning board ($(( $WINNING_BOARD + 1 ))):"
for (( r=0; r<$rows; r++ )); do
    for (( c=0; c<$cols; c++ )); do
        printf "%3s" "${board_numbers[$(( $WINNING_BOARD*$rows*$cols + $r*$rows + $c ))]}"
    done
    echo
done
echo "Sum of unmarked numbers: $remaining_sum"
echo "Final score: $(( $remaining_sum*$drawn_num ))"
