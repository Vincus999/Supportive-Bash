#!/bin/bash

# Set default nap time (in minutes)
DEFAULT_NAP=20

# Nap time function
usage() {
	echo -e "Usage: $0 [nap_time_minute]"
	echo -e "Example: $0 15 (15 minute nap)"
	echo -e "Running with no arguments will use the ${DEFAULT_NAP} minute nap"
}

# Check the help argument
if [[ "$1" == "-h" || "$1" == "--help" ]];
then
	usage
	exit 0
fi

# Set nap time
NAP=${1:-$DEFAULT_NAP}

# Validate input is a number
if ! [[ "$NAP" =~ ^[0-9]+$ ]];
then
	echo -e "Error: Nap time must be a number (minutes)"
	usage
	exit 1
fi

# Converting to seconds
SECONDS=$((NAP * 60))

echo -e "\n\033[1;34m Nap time activated\033[0m"
echo -e "You have chosen a \033[1;34m ${NAP} minute\033[0m nap."
echo -e "\033[1;35m Rest well! Your work will be there when you rested yourself. \033[0m\n"

# Display countdown timer in the background
(
	for ((i=SECONDS; i>=0; i--));
	do
		printf "\r\033[1;36m Time remaining: %02d:%02d\033[0m" $((i/60)) $((i%60))
		sleep 1
	done
) &

# Store the PID of the countdown process
PID=$!

# Sleep
sleep ${SECONDS}s

# Terminate countdown process
kill $PID 2>/dev/null
wait $PID 2>/dev/null

# Wake up message with visual effects
echo -e "\n\n\033[1;32m* * * * * * * * * * * * * * * * * * * *\033[0m"
echo -e "\033[1;32m*                                     *\033[0m"
echo -e "\033[1;32m*   \033[1;37m Your ${NAP} minute nap is over!       \033[1;32m*\033[0m"
echo -e "\033[1;32m*   \033[1;37m It is time to get back to work!  \033[1;32m*\033[0m"
echo -e "\033[1;32m*                                     *\033[0m"
echo -e "\033[1;32m* * * * * * * * * * * * * * * * * * * *\033[0m\n"

# Exit
exit
