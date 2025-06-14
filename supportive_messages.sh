#!/bin/bash

# Supportive Login Greeter
# Displays random uplifting messages when users log in

# Configuration
USER_NAME=$(whoami)  # Get current username
MESSAGE_FILE="$HOME/.supportive_messages"  # Custom messages file
LOG_FILE="$HOME/.login_greeter.log"  # Optional logging

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

# Default messages if custom file doesn't exist
DEFAULT_MESSAGES=(
    "Welcome back, $USER_NAME! You've got this! ${GREEN}✨${NC}"
    "Hello $USER_NAME! Today is a new opportunity to grow. ${BLUE}🌱${NC}"
    "Good to see you, $USER_NAME! Remember: progress > perfection. ${PURPLE}💪${NC}"
    "Hi $USER_NAME! You're capable of amazing things today. ${CYAN}🚀${NC}"
    "Welcome $USER_NAME! Small steps still move you forward. ${GREEN}🐢${NC}"
    "Hello beautiful mind! The world needs your unique gifts. ${PURPLE}🎁${NC}"
    "Hi $USER_NAME! You're stronger than you think. ${BLUE}💙${NC}"
    "Welcome back! Mistakes are just learning in disguise. ${GREEN}📚${NC}"
    "Hello $USER_NAME! Breathe. You're exactly where you need to be. ${CYAN}🧘${NC}"
    "Hi there! Your presence makes a difference. ${PURPLE}🌟${NC}"
)

# Load custom messages if file exists, otherwise use defaults
if [ -f "$MESSAGE_FILE" ]; then
    mapfile -t MESSAGES < "$MESSAGE_FILE"
    # Add username to custom messages
    MESSAGES=("${MESSAGES[@]/\%u/$USER_NAME}")
else
    MESSAGES=("${DEFAULT_MESSAGES[@]}")
fi

# Select a random message
RANDOM_MSG=${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}

# Display the message with ASCII art
echo -e "
  ${GREEN}╭──────────────────────────────────────────╮
  │                                          │
  │   $(echo -e "$RANDOM_MSG" | fold -w 30 -s)   │
  │                                          │
  ╰──────────────────────────────────────────╯${NC}
"

# Optional logging
echo "[$(date)] Displayed greeting to $USER_NAME" >> "$LOG_FILE"

# Exit
exit
