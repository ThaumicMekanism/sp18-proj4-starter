#!/bin/bash
# by Stephan Kaminsky

PREV_TOTAL=0
PREV_IDLE=0
notime="false"
if [ ! -z $1 ]; then
	re='^[0-9]+$'
	if ! [[ $1 =~ $re ]] ; then
   		echo "[ERROR]: The first argumen should be left blank (For no end time) or be a number!" >&2; exit 1
	fi
	echo "[INFO]: Dispalying for $1 seconds..."
else
echo "[WARNING]: No ending time set..."
notime="true"
fi
t=0
echo "[INFO]: Here is the current cpu usage (Press ctrl+c to exit):";
echo ""
while [[ t -lt $1 || $notime == "true" ]]; do

  CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.

  # Calculate the total CPU time.
  TOTAL=0

  for VALUE in "${CPU[@]:0:4}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done

  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
  echo -en "\rCPU: $DIFF_USAGE%  \b\b"

  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"

  # Wait before checking again.
  t=$(($t + 1))
  sleep 1
done
