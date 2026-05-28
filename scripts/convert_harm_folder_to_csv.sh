#!/usr/bin/env bash
#
# Convert a given folder under which each stage has it own folder with a file
# called "assertion_list.log" to .csv in a specified folder

PROGNAME=$(basename "$0")

usage() {
	cat <<-EOF
		Usage: $PROGNAME INPUT_DIR OUTPUT_DIR
		 INPUT_DIR  a directory with each stage as its own folder and an assertion_list.log file
		 OUTPUT_DIR to place the <stage>.csv files under
	EOF
}

if [[ "$#" -ne "2" ]]; then
	usage
	exit 1
fi

if [[ ! -d $1 ]]; then
	echo "$PROGNAME: $1 doesn't exit"
	exit 1
fi

if [[ ! -d $2 ]]; then
	mkdir -p "$2"
fi

find "$1"  -depth -maxdepth 1 -mindepth 1 -type d \
	-exec sh -c 'i=$(basename "$1").csv;\
	./scripts/convert_harm_to_csv.sh $1/assertion_list.log > "$2"/"$i"'\
	shell {} "$2" \;
