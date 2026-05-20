#!/usr/bin/env bash

stages=("frontend.csv" "id_stage.csv" "issue_stage.csv" "ex_stage.csv" "commit_stage.csv")

for stage in "${stages[@]}"; do
	./compare.py "./harm/${stage}" "./bps/${stage}" --sva --common >"./sva/in_both/${stage%.*}.sva"
done
