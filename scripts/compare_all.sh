#!/usr/bin/env bash
#
# This script takes in two folder and runs compare.py on JOIN product of them
# It also takes args that are passed to compare.py

PROGNAME=$(basename "$0")

usage() {
	cat <<-EOF
		Usage: $PROGNAME DIR_1 DIR_2 [opts...]
		 DIR_1, DIR_2 Directory with <stages>.csv files
		 opts          Arguments to pass to compare.py
	EOF
}

all_files_exist() {
	for stage in "${STAGES[@]}"; do
		if [[ ! -f "$1/$stage" ]]; then
			false
			return
		fi
	done
	true
	return
}

if [[ $# -lt 2 ]]; then
	usage
	exit 1
fi

if [[ ! -d $1 ]]; then
	echo -ne "$PROGNAME: $1 doesn't exist\n"
	exit 1
fi

dir1=$1
shift

if [[ ! -d $1 ]]; then
	echo -ne "$PROGNAME: $1 doesn't exist\n"
	exit 1
fi

dir2=$1
shift

STAGES=(frontend.csv id_stage.csv issue_stage.csv ex_stage.csv commit_stage.csv)

if ! all_files_exist "$dir1"; then
	echo -ne "$PROGNAME: Some files are missing in $dir1\n"
fi

if ! all_files_exist "$dir2"; then
	echo -ne "$PROGNAME: Some files are missing in $dir2\n"
fi

for stage in "${STAGES[@]}"; do
	python3 ./compare.py "$dir1/$stage" "$dir2/$stage" "$@"
done
