#!/bin/bash

display_usage() {
	echo -e "\nUsage:\n$0 [version]"
	echo -e "calculates calc_all_combinations.R for all quantified files in folder"
	echo -e "Example: $0 v2_3"
}

calc_one_seed() {
	for period in 3 5 10 20
	do
		echo "...period $period"
		for group in {1..25}
		do
			./calc_all_combinations.R --version=$1 --future_periods=$period --seed=$2 --group=$group
		done
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

# start all calc_all_combination processes
# dont let the cores get bored
for seed in 1 2 3 4
do
	echo "doing seed $seed. The output is redirected to log file $1_$seed.log"
	calc_one_seed $1 $seed > "$1_$seed.log" &
done

