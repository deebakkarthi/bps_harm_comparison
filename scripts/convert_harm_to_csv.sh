#!/usr/bin/env bash
#
# Convert from the HARM format to a .csv format
# The HARM format looks as follows
# ==============================================================================
# proven:
#
#   * assert property (@(posedge clk_i) disable iff (!rst_ni)  fence_i_o |-> ##1 commit_lsu_ready_i);
#   * assert property (@(posedge clk_i) disable iff (!rst_ni)  fence_o |-> ##1 commit_lsu_ready_i);
#   * assert property (@(posedge clk_i) disable iff (!rst_ni)  no_st_pending_i |-> ##1 commit_lsu_ready_i);
#   ...
#
# cex:
#
#   * assert property (@(posedge clk_i) disable iff (!rst_ni)  commit_ack_o[0] |-> ##1 commit_lsu_ready_i);
#   * assert property (@(posedge clk_i) disable iff (!rst_ni)  commit_ack_o[1] |-> ##1 commit_instr_i[1].use_imm);
#   ...
# undetermined:
#
#  * (none)
# ==============================================================================

PROGNAME=$(basename "$0")
echoerr() { echo "$@" 1>&2; }

if [[ "$#" -lt 1 ]]; then
	input_file="/dev/stdin"
else
	if [[ ! -f "$1" ]]; then
		echoerr "$PROGNAME: $1 doesn't exist"
		exit 1
	fi
	input_file="$1"
fi

declare state
while IFS= read -r line; do
	if [[ ! -z $line ]]; then
		# Check if we are in a category line or assertion line
		if [[ $line =~ ^[a-zA-Z]+: ]]; then
			# set state
			state="${BASH_REMATCH[0]%:*}"
		else
			# If we encounter '* (none)' then clear the state
			if [[ $line =~ \*\ \(none\) ]]; then
				state=""
			fi
			# Only print if we are in a valid state
			if [[ ! -z $state ]]; then
				line=${line#* assert property (@(posedge clk_i) disable iff (!rst_ni)}
				line=${line%);}
				line=$(echo "$line" | \
					# Split Antecendent and Consequent
					awk -F'\\|-> ##1' '{print $1 $2}' |\
					# Strip trailing whitespace and quote
					awk '{$1=$1; printf "\"%s\",\"%s\"", $1, $2}')
				echo "\"$state\",$line"
			fi
		fi
	fi
done <"$input_file"
