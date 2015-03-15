#!/bin/bash
# This script executes all scripts to filter out the most promising patterns
# it is usually started by the crond at midnight

logdir="/home/voellenk/.tronadorlog"
declare -a versions=( v1_2 v1_3 v1_4 v2_1 v2_2 )

display_usage() {
  echo -e "\nUsage:\n$0 [sampleN]"
	echo -e "runs all 4 nightlyRun Rscripts."
  echo -e "the time consuming nightlyRun_calculateStats.R scripts are parallelized."
  echo -e "the parameter sampleN determines the number of symbols to download.\n"
	echo -e "Example1: $0 20    only download 20 symbols for tests"
  echo -e "Example2: $0 all   donwload all symbols in targetSyms.Rdata"
}

# display usage when -h or --help is supplied
if [[ $# != 1 || $1 == "--help" || $1 == "-h" ]]
then
  display_usage
	exit 0
fi

# create log directory if not exists
mkdir -p $logdir

# retrieve current prices
echo -e "\nretrieving quotes from finance.yahoo.com"
./Rscript/nightlyRun_getQuotes.R -v --testSampleN=$1 --seed=$RANDOM >> $logdir/nightlyRun_getQuotes.R.log

# calculate last day constellation for each strategy -> symbol
# parallelize jobs
echo -e "\nStarting parallelized processing of all versions"
i=0
for version in "${versions[@]}"
do
	./Rscript/nightlyRun_calculateStats.R -v --version=$version >> $logdir/nightlyRun_calculateStats_$version.log &
	echo "version $version: PID=$!"
	pids[$i]=$!
	((i++))
done

# waiting for processes to end
for pid in ${pids[*]}
do
  echo "waiting for $pid"
  wait $pid
done

# find nuggets
echo -e "\nfinding nuggets"
./Rscript/nightlyRun_findNuggets.R -v >> $logdir/nightlyRun_findNuggets.R.log

# make knitr report
./Rscript/nightlyRun_makeKnitrReport.R -v >> $logdir/nightlyRun_makeKnitrReport.R.log

