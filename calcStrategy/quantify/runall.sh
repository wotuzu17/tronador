#!/bin/bash

display_usage() {
	echo -e "\nUsage:\n$0 [version]"
	echo -e "calculates quantify_groups_universal.R for periods 3,5,10,20\n"
	echo -e "Example: $0 v1_3"
}

quantify_one_seed() {
	for period in 3 5 10 20
	do
		echo "...period $period"
		./quantify_groups_universal.R --version=$1 --future_periods=$period --seed=$2
	done
}

# if less than one argument supplied, display usage
if [ $# != 1 ]
then
	display_usage
	exit 1
fi

# display usage when -h or --help is supplied
if [[ ($1 == "--help") || $1 == "-h" ]]
then
	display_usage
	exit 0
fi

# start all quantify_groups processes
# dont let the cores get bored

for seed in 1 2 3 4
do
	echo "doing seed $seed. The output is redirected to log file $1_$seed.log"
	quantify_one_seed $1 $seed > "$1_$seed.log" &
done

