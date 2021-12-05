#!/bin/bash

FINISHED_BOARDS=()
LAST_FINISHED_BOARD=-1
find_last_finished_board () {
    for (( board=0; board<$board_count; board++ )); do
        [[ " ${FINISHED_BOARDS[@]} " =~ " $board " ]] && continue # Board has already won

        cols_all_x=( ${DEFAULT_COLS_ALL_X[@]} )
        for (( row=0; row<$rows; row++)); do
            row_all_x=1
            for (( col=0; col<$cols; col++)); do
                idx=$(( $board*$rows*$cols + $row*$rows + $col ))
                [ "${board_numbers[$idx]}" != "$MARK" ] && row_all_x=0 && cols_all_x[$col]=0
            done
            # Board finished by row, stop searching this board
            [ "$row_all_x" == "1" ] && FINISHED_BOARDS+=( $board ) && break
        done
        # Board finished by column
        [ "$row_all_x" != "1" ] && [[ " ${cols_all_x[@]} " =~ " 1 " ]] && FINISHED_BOARDS+=( $board )
        # This is the last board to finish, stop searching
        [ "${#FINISHED_BOARDS[@]}" -eq "$board_count" ] && LAST_FINISHED_BOARD=$board && return 0
    done
}

MARK="X"
lines=()

while IFS=$'\r\n' read line
do
    lines+=("$line")
done < "${1:-/dev/stdin}"

draw_bag=${lines[0]}
IFS=$',' # To split the draw bag into individual numbers
draw_bag=(${draw_bag[@]})
IFS=$' \t\r\n' # Split on whitespaces
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
    find_last_finished_board
    if [ "$LAST_FINISHED_BOARD" -ne "-1" ]; then
        sIdx=$(( $LAST_FINISHED_BOARD*$rows*$cols ))
        len=$(( $rows*$cols ))
        remaining_nums=( $( grep -oE "[0-9]+" <<< ${board_numbers[@]:$sIdx:$len} ) )
        remaining_sum=$( IFS=+; echo "$(( ${remaining_nums[*]} ))" )
        break
    fi
done

echo
echo "Once it wins, what would its final score be?"
echo "Last number drawn: $drawn_num"
echo "Last finished board ($(( $LAST_FINISHED_BOARD + 1 ))):"
for (( r=0; r<$rows; r++ )); do
    for (( c=0; c<$cols; c++ )); do
        printf "%3s" "${board_numbers[$(( $LAST_FINISHED_BOARD*$rows*$cols + $r*$rows + $c ))]}"
    done
    echo
done
echo "Sum of unmarked numbers: $remaining_sum"
echo "Final score: $(( $remaining_sum*$drawn_num ))"
