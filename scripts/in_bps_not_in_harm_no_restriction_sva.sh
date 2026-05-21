#!/usr/bin/env bash

stages=("frontend.csv" "id_stage.csv" "issue_stage.csv" "ex_stage.csv" "commit_stage.csv")

for stage in "${stages[@]}"; do
	./compare.py "./csv/harm_no_restriction/${stage}" "./csv/bps/${stage}" --sva --invert >"./sva/in_bps_not_in_harm_no_restriction/${stage%.*}.sva"
done
