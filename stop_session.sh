#!/bin/bash

SESSION="session"

# If a session runs, this command will terminate it
if screen -list | grep -q "$SESSION";
then
	echo "The  screen session is going to be termineted: $SESSION"
	screen -S "$SESSION" -X quit
	echo "Session '$SESSION' has been closed"
else
	echo "There is no running sesion: $SESSION"
fi

# Exit
exit
