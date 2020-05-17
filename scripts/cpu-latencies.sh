#!/bin/bash

NETPERF="netperf"
NETPERF_ARGS="-H localhost -t TCP_RR -l 1"
NETSERV="netserver"
CPUS=$(grep ^processor /proc/cpuinfo  | wc -l)
WIDTH=$(grep ^processor /proc/cpuinfo | tail --lines=1  | awk '{print $NF}' | tr -d [:cntrl:] | wc -c)
if [ $WIDTH -lt 2 ]; then
	WIDTH=2
fi
FMT="%"$WIDTH"d"
TMP=$(mktemp)

killall -q -9 netserver

set -e

for i in $(seq 1 $WIDTH); do
	echo -n " "
done
echo -n "|"
for CPU in $(seq 1 $CPUS); do
	printf " $FMT" $(grep ^processor /proc/cpuinfo | head --lines=$CPU | tail --lines=1 | awk '{print $NF}')
done
echo

for i in $(seq 1 $WIDTH); do
	echo -n "-"
done
echo -n "+"
for CPU in $(seq 1 $CPUS); do
	for i in $(seq 0 $WIDTH); do
		echo -n "-"
	done
done
echo

for CPU in $(seq 1 $CPUS); do
	NUM=$(grep ^processor /proc/cpuinfo | head --lines=$CPU | tail --lines=1 | awk '{print $NF}')
	printf "$FMT|" $NUM
	taskset -c $NUM $NETSERV 2>&1 > /dev/null
	taskset -c $NUM $NETPERF $NETPERF_ARGS > $TMP
	LOCAL=$(tail --lines=2 $TMP | head --lines=1 | awk '{print $NF}' | cut -f 1 -d '.')
	for TEST in $(seq 1 $CPUS); do
		if [ $CPU -eq $TEST ]; then
			printf " $FMT" 10
			continue
		fi
		NUM2=$(grep ^processor /proc/cpuinfo | head --lines=$TEST | tail --lines=1 | awk '{print $NF}')
		taskset -c $NUM2 $NETPERF $NETPERF_ARGS > $TMP
		CUR=$(tail --lines=2 $TMP | head --lines=1 | awk '{print $NF}' | cut -f 1 -d '.')
		VAL=$(echo "scale=1;($CUR*10)/$LOCAL" | bc)
		VAL=$(echo $VAL | awk '{print int($1+0.5)}')
		printf " $FMT" $VAL
	done
	echo
	killall -9 netserver
done
rm $TMP
