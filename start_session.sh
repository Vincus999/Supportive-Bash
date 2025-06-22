#!/bin/bash
# To run this script you should download "screen" to your server 
SESSION="session"

# Starting new screen session (detach mode)
screen -dmS "$SESSION"

# 0. process
screen -S "$SESSION" -p 0 -X screen -t "Process"
screen -S "$SESSION" -p 0 -X stuff "echo 'Process'\n"

# 1. htop
screen -S "$SESSION" -X screen -t "htop"
screen -S "$SESSION" -p "htop" -X stuff "echo 'htop'\n"

# 2. scripting
screen -S "$SESSION" -X screen -t "script"
screen -S "$SESSION" -p "script" -X stuff "echo 'Script'\n"

# Automatized joining sessions
screen -r "$SESSION"
