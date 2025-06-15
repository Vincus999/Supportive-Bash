#!/bin/bash

# Fully Fixed Weather Greeter Script
# Now properly handles cache directory and weather data parsing

# Configuration
USER_NAME=$(whoami)
MESSAGE_FILE="$HOME/.supportive_messages"
WEATHER_CACHE_DIR="$HOME/.weather_cache"
CACHE_EXPIRY=3600
CITIES=("Budapest" "Debrecen" "Szeged" "Vienna" "Graz")
DEFAULT_CITY="Budapest"

# Ensure cache directory exists
mkdir -p "$WEATHER_CACHE_DIR" || {
    echo "Error: Could not create cache directory" >&2
    WEATHER_CACHE_DIR="$HOME"
}

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Weather icons
SUNNY="${YELLOW}☀️${NC}"
CLOUDY="${WHITE}☁️${NC}"
RAIN="${BLUE}🌧️${NC}"
STORM="${PURPLE}⛈️${NC}"
SNOW="${CYAN}❄️${NC}"
WINDY="${WHITE}🌬️${NC}"

# Get current time
HOUR=$(date +%H)
DAY=$(date +%A)
DATE_STR=$(date +"%B %d, %Y")

# Time-based greeting
if [ $HOUR -lt 12 ]; then
    TIME_GREETING="Good morning"
    TIME_ICON="${YELLOW}🌅${NC}"
elif [ $HOUR -lt 17 ]; then
    TIME_GREETING="Good afternoon"
    TIME_ICON="${YELLOW}☀️${NC}"
else
    TIME_GREETING="Good evening"
    TIME_ICON="${BLUE}🌙${NC}"
fi

# Reliable weather fetching with proper parsing
get_weather() {
    local city="$1"
    local cache_file="${WEATHER_CACHE_DIR}/${city}.cache"
    local temp_cache
    
    # Check cache first
    if [ -f "$cache_file" ]; then
        local cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        if [ $cache_age -le $CACHE_EXPIRY ]; then
            temp_cache=$(cat "$cache_file")
        fi
    fi

    # Fetch fresh data if needed
    if [ -z "$temp_cache" ]; then
        echo -e "${YELLOW}Fetching fresh weather data for $city...${NC}" >&2
        temp_cache=$(curl -s "wttr.in/${city}?format=\"%c+%t+%w+%h\"&m" | tr -d '"')
        
        if [ -n "$temp_cache" ]; then
            echo "$temp_cache" > "$cache_file"
        elif [ -f "$cache_file" ]; then
            temp_cache=$(cat "$cache_file")
            echo -e "${YELLOW}Using cached weather data${NC}" >&2
        else
            temp_cache="⛅ +0°C 0km/h 0%"
            echo -e "${RED}Weather service unavailable${NC}" >&2
        fi
    fi

    # Parse weather data properly
    WEATHER_ICON=$(echo "$temp_cache" | awk '{print $1}')
    TEMP=$(echo "$temp_cache" | awk '{print $2}')
    WIND=$(echo "$temp_cache" | awk '{print $3}')
    HUMIDITY=$(echo "$temp_cache" | awk '{print $4}')

    # Map weather icons
    case "$WEATHER_ICON" in
        "☀️") WEATHER_ICON=$SUNNY ;;
        "⛅") WEATHER_ICON=$CLOUDY ;;
        "☁️") WEATHER_ICON=$CLOUDY ;;
        "🌧️") WEATHER_ICON=$RAIN ;;
        "⛈️") WEATHER_ICON=$STORM ;;
        "❄️") WEATHER_ICON=$SNOW ;;
        "🌫️") WEATHER_ICON=$WINDY ;;
        *) WEATHER_ICON="${GREEN}🌈${NC}" ;;
    esac
}

# City selection
select_city() {
    while true; do
        echo -e "\n${CYAN}Available cities:${NC}"
        for i in "${!CITIES[@]}"; do
            echo "$((i+1))) ${CITIES[$i]}"
        done
        
        read -rp "Select city (1-${#CITIES[@]} or Enter for $DEFAULT_CITY): " choice
        
        if [ -z "$choice" ]; then
            SELECTED_CITY="$DEFAULT_CITY"
            return 0
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#CITIES[@]} ]; then
            SELECTED_CITY="${CITIES[$((choice-1))]}"
            return 0
        else
            echo -e "${RED}Invalid selection. Please try again.${NC}"
        fi
    done
}

# Initialize messages
init_messages() {
    DEFAULT_MESSAGES=(
        "$TIME_GREETING $USER_NAME! $TIME_ICON Today is $DAY in $SELECTED_CITY"
        "Hello $USER_NAME! $TIME_ICON Weather: $WEATHER_ICON $TEMP"
        "$TIME_GREETING! $DATE_STR ${PURPLE}✨${NC} Wind: $WIND"
        "Welcome back $USER_NAME! $TIME_ICON Humidity: $HUMIDITY"
    )

    if [ -f "$MESSAGE_FILE" ]; then
        mapfile -t CUSTOM_MESSAGES < "$MESSAGE_FILE"
        MESSAGES=()
        for msg in "${CUSTOM_MESSAGES[@]}"; do
            msg=${msg//%u/$USER_NAME}
            msg=${msg//%d/$DAY}
            msg=${msg//%D/$DATE_STR}
            msg=${msg//%t/$TIME_GREETING}
            msg=${msg//%i/$TIME_ICON}
            msg=${msg//%w/$WEATHER_ICON $TEMP}
            msg=${msg//%W/$WIND}
            msg=${msg//%h/$HUMIDITY}
            msg=${msg//%c/$SELECTED_CITY}
            MESSAGES+=("$msg")
        done
    else
        MESSAGES=("${DEFAULT_MESSAGES[@]}")
    fi
}

# Main execution
select_city
get_weather "$SELECTED_CITY"
init_messages

# Display greeting
echo -e "
  ${GREEN}╭────────────────────────────────────────────────────╮
  │                                                      │
  │   $(printf "%-42s" "${TIME_GREETING} ${USER_NAME}!")   │
  │   ${CYAN}$(printf "%-42s" "$DATE_STR")${NC}   │
  │                                                      │
  │   ${YELLOW}Weather for $SELECTED_CITY:${NC}                   │
  │   $WEATHER_ICON  Temperature: $(printf "%-15s" "$TEMP")   │
  │   💨  Wind: $(printf "%-28s" "$WIND")   │
  │   💧  Humidity: $(printf "%-24s" "$HUMIDITY")   │
  │                                                      │
  │   ${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}   │
  │                                                      │
  ╰────────────────────────────────────────────────────╯${NC}
"

# Exit
exit
