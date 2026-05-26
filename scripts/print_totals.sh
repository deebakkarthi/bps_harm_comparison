#!/usr/bin/env bash

stages=("frontend.csv" "id_stage.csv" "issue_stage.csv" "ex_stage.csv" "commit_stage.csv")

harm_dir="./csv/harm_no_restriction"
bps_dir="./csv/bps"

echo -ne "|STAGE|In HARM Not in BPS|In BPS Not in HARM|In Both|\n"
echo -ne "|-|-|-|-|\n"
for stage in "${stages[@]}"; do
	echo -ne "| ${stage}|"
	./compare.py "$harm_dir/${stage}" "$bps_dir/${stage}" --count | awk 'BEGIN{total=0}{total+=$2}END{printf total}'
	echo -ne "|"
	./compare.py "$harm_dir/${stage}" "$bps_dir/${stage}" --count --invert | awk 'BEGIN{total=0}{total+=$2}END{printf total}'
	echo -ne "|"
	./compare.py "$harm_dir/${stage}" "$bps_dir/${stage}" --count --common | awk 'BEGIN{total=0}{total+=$2}END{printf total}'
	echo -ne "|\n"
done
