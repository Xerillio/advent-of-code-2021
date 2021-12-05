#!/bin/bash

LAST_SUM=0
get_sum_by_col () {
    LAST_SUM=0
    args=("$@")
    pos=${args[0]}
    strings=${args[@]:1}

    for string in ${strings[@]}; do
        ((LAST_SUM+=${string:$pos:1}))
    done
}

FILTERED_ARRAY=()
filter () {
    FILTERED_ARRAY=()
    args=("$@")
    pattern=${args[0]}
    strings=${args[@]:1}

    for string in ${strings[@]}; do
        if [[ $string == $pattern ]]; then
            FILTERED_ARRAY+=($string)
        fi
    done
}

line_count=0
lines=()

while IFS=$' \t\r\n' read line
do
    lines+=($line)
    ((line_count++))
done < "${1:-/dev/stdin}"

cols=${#lines[0]}
oxy_gen_lines=(${lines[@]})
co2_scrub_lines=(${lines[@]})

for (( i=0; i<$cols; i++ )); do
    if (( ${#oxy_gen_lines[@]} > 1 )); then
        thresh=$(( (${#oxy_gen_lines[@]}+1)/2 ))
        get_sum_by_col $i ${oxy_gen_lines[@]};
        oxy_sum=$LAST_SUM
        oxy_bit+=$(( ($oxy_sum+1)/($thresh+1) ))
        filter "$oxy_bit*" ${oxy_gen_lines[@]};
        unset oxy_gen_lines;
        oxy_gen_lines=(${FILTERED_ARRAY[@]})
    fi

    if (( ${#co2_scrub_lines[@]} > 1 )); then
        thresh=$(( ${#co2_scrub_lines[@]}/2 + 1 ))
        get_sum_by_col $i ${co2_scrub_lines[@]};
        co2_sum=$LAST_SUM
        co2_bit+=$(( (${#co2_scrub_lines[@]}-$co2_sum)/($thresh) ))
        filter "$co2_bit*" ${co2_scrub_lines[@]};
        unset co2_scrub_lines;
        co2_scrub_lines=(${FILTERED_ARRAY[@]})
    fi
done

oxy_gen_rating=${oxy_gen_lines[0]}
co2_scrub_rating=${co2_scrub_lines[0]}

echo
echo "What is the life support rating of the submarine?"
echo "Oxygen generator rating: $oxy_gen_rating - $((2#$oxy_gen_rating))"
echo "CO2 scrubber rating:     $co2_scrub_rating - $((2#$co2_scrub_rating))"
echo "Life support rating:     $((2#$oxy_gen_rating * 2#$co2_scrub_rating))"
