#!/usr/bin/env bash

stages=("frontend.csv" "id_stage.csv" "issue_stage.csv" "ex_stage.csv" "commit_stage.csv")

for stage in "${stages[@]}"; do
	./compare.py "./harm/${stage}" "./bps/${stage}" --sva >"./sva/in_harm_not_in_bps/${stage%.*}.sva"
done
