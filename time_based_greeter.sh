#!/bin/bash

# Supportive Login Greeter with Time-Based Messages
# Displays uplifting messages based on time of day

# Configuration
USER_NAME=$(whoami)                          # Get username
MESSAGE_FILE="/home/c76a5j/supportive_messages"    # Custom messages file
LOG_FILE="/home/c76a5j/login_greeter.log"          # Optional logging
LAST_RUN_FILE="/home/c76a5j/last_greeter_run"      # Track last run date

# Color definitions (ANSI escape codes)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'  # No Color

# ASCII Art
SUN="${YELLOW}☀️${NC}"
MOON="${BLUE}🌙${NC}"
STARS="${PURPLE}✨${NC}"
HEART="${RED}❤️${NC}"
PLANT="${GREEN}🌱${NC}"

# Get current time and date
HOUR=$(date +%H)
DAY=$(date +%A)
DATE_STR=$(date +"%B %d, %Y")

# Time-based greeting
if [ $HOUR -lt 12 ]; then
    TIME_GREETING="Good morning"
    TIME_ICON=$SUN
elif [ $HOUR -lt 17 ]; then
    TIME_GREETING="Good afternoon"
    TIME_ICON=$SUN
else
    TIME_GREETING="Good evening"
    TIME_ICON=$MOON
fi

# Default messages if custom file doesn't exist
DEFAULT_MESSAGES=(
    "$TIME_GREETING $USER_NAME! Today is $DAY - a perfect day to make progress $PLANT"
    "Hello $USER_NAME! $TIME_ICON Remember: small steps still move you forward ${STARS}"
    "$TIME_GREETING! It's $DATE_STR - you're exactly where you need to be $HEART"
    "Hi $USER_NAME $TIME_ICON The world needs your unique gifts today ${PURPLE}🎁${NC}"
    "Welcome back! $TIME_GREETING! Mistakes are just learning in disguise ${GREEN}📚${NC}"
)

# Load custom messages if file exists
if [ -f "$MESSAGE_FILE" ]; then
    mapfile -t CUSTOM_MESSAGES < "$MESSAGE_FILE"
    # Process placeholders
    MESSAGES=()
    for msg in "${CUSTOM_MESSAGES[@]}"; do
        msg=${msg//\%u/$USER_NAME}
        msg=${msg//\%d/$DAY}
        msg=${msg//\%D/$DATE_STR}
        msg=${msg//\%t/$TIME_GREETING}
        msg=${msg//\%i/$TIME_ICON}
        MESSAGES+=("$msg")
    done
else
    MESSAGES=("${DEFAULT_MESSAGES[@]}")
fi

# Select a random message
RANDOM_MSG=${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}

# Display the message with ASCII box
echo -e "
  ${GREEN}╭────────────────────────────────────────────────╮
  │                                                  │
  │   $(echo -e "$RANDOM_MSG" | fold -w 38 -s)   │
  │                                                  │
  ╰────────────────────────────────────────────────╯${NC}
"

# Show last login time if recorded
if [ -f "$LAST_RUN_FILE" ]; then
    LAST_RUN=$(cat "$LAST_RUN_FILE")
    echo -e "${YELLOW}Last login: $LAST_RUN${NC}"
fi

# Update last run time
date +"%Y-%m-%d %H:%M:%S" > "$LAST_RUN_FILE"

# Optional logging
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Displayed greeting to $USER_NAME" >> "$LOG_FILE"

# Exit
exit
