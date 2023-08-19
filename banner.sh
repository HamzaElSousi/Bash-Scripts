#!/bin/bash

# Hamza El Sousi
# 040982818

# Function to print the usage message and exit with non-zero status
print_usage() {
  echo "Usage: banner [OPTION]... STRING"
  echo "Try 'banner --help' for more information."
  exit 1
}

# Function to print the help page and exit successfully
print_help() {
  echo "Usage: banner [OPTION]... STRING"
  echo ""
  echo "This script creates a banner with the provided STRING as the title."
  echo ""
  echo "Options:"
  echo "  -w NUM                Set the width of the banner (default is terminal width)"
  echo "  -p NUM                Set the number of spaces to pad above and below the text (default is 0)"
  echo "  -c [CHAR]             Create the border with a special character (default is -)"
  echo "  -n                    Only echo the centered text without printing a banner"
  echo "  --text-color=COLOR    Set the color of the text (available colors: black, red, green, yellow, blue, magenta, cyan, white)"
  echo "  --border-color=COLOR  Set the color of the border (available colors: black, red, green, yellow, blue, magenta, cyan, white)"
  echo ""
  echo "Created by: Hamza El Sousi"
  exit 0
}

# Function to create the banner with multi-line text support
  create_banner() {
    local width=$1
    local padding=$2
    local border_char=$3
    local text=$4
    local text_color=$5
    local border_color=$6

    # Calculate the effective width for the text content
    local content_width=$(( width - 2 )) # Subtract 2 to account for the + characters and the space between the text and borders

    # Wrap the text
    local wrapped_text=$(echo -n "$text" | fold -s -w $content_width)

    # Calculate the number of lines needed for the text
    local text_lines=$(echo "$wrapped_text" | wc -l)

    # Calculate the number of empty lines to pad above and below the text
    local empty_lines=$(( padding - text_lines ))
    local top_padding=$(( empty_lines / 2 ))
    local bottom_padding=$(( empty_lines - top_padding ))

    # Create the border line with corners
    local border="+"
    for (( i = 0; i < width - 2; i++ )); do
      border+="$border_char"
    done
    border+="+"
    

    # Prepare the content
    local content="$border\n"

    # Add top padding
    for (( i = 0; i < top_padding; i++ )); do

      content+="|$border_color_code$(printf "%-${content_width}s" " ")|\n"
    done

    # Add wrapped text lines
    while IFS= read -r line; do
      local line_length=${#line}
      local padding_length=$(( (content_width - line_length) / 2 ))
      local left_padding_length=$(( padding_length + (content_width - line_length) % 2 ))
      content+="|$(printf "%-${left_padding_length}s" " ")$line$(printf "%-${padding_length}s" " ")|\n"
    done <<< "$wrapped_text"

    # Add bottom padding
    for (( i = 0; i < bottom_padding; i++ )); do
      content+="|$(printf "%-${content_width}s" " ")|\n"
    done

    content+="$border"

  # Set text color
  local text_color_code=""
  case $text_color in
  black)   text_color_code="\e[30m";;
  red)     text_color_code="\e[31m";;
  green)   text_color_code="\e[32m";;
  yellow)  text_color_code="\e[33m";;
  blue)    text_color_code="\e[34m";;
  magenta) text_color_code="\e[35m";;
  cyan)    text_color_code="\e[36m";;
  white)   text_color_code="\e[37m";;
  *)       text_color_code="\e[39m";;
esac

  # Set border color
  local border_color_code=""
  case $border_color in
    black)   border_color_code="\e[40m";;
    red)     border_color_code="\e[41m";;
    green)   border_color_code="\e[42m";;
    yellow)  border_color_code="\e[43m";;
    blue)    border_color_code="\e[44m";;
    magenta) border_color_code="\e[45m";;
    cyan)    border_color_code="\e[46m";;
    white)   border_color_code="\e[47m";;
    *)       border_color_code="\e[49m";;
  esac
  
  
  echo -e "${text_color_code}${border_color_code}${content}\e[0m"
}

# Function to get the terminal width, handles the case where tput is unavailable
get_terminal_width() {
  local cols=$(tput cols 2>/dev/null)
  if [ -z "$cols" ]; then
    cols=$(stty size <&2 | cut -d ' ' -f2)
  fi
  echo "$cols"
}

# Initialize variables
width=""
padding=""
border_char=""
text=""
text_color=""
border_color=""
no_banner=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -w)
      width=$2
      shift
      ;;
    -p)
      padding=$2
      shift
      ;;
    -c)
      border_char=$2
      shift
      ;;
    -n)
      no_banner=true
      ;;
    --text-color=*)
      text_color="${1#*=}"
      ;;
    --border-color=*)
      border_color="${1#*=}"
      ;;
    --help)
      print_help
      ;;
    *)
      if [[ -z "$text" ]]; then
        text=$1
      else
        echo "Invalid argument: $1"
        print_usage
        exit 1
      fi
      ;;
  esac
  shift
done

# Check if STRING argument is provided
if [[ -z "$text" ]]; then
  echo "Error: STRING argument is missing."
  print_usage
  exit 1
fi

# Set default values if not provided
width=${width:-$(get_terminal_width)}
padding=${padding:-0}
border_char=${border_char:-'-'}
text_color=${text_color:-}
border_color=${border_color:-}

# Check if -n option is provided
if [ "$no_banner" = true ]; then
  echo "$text"
else
  create_banner "$width" "$padding" "$border_char" "$text" "$text_color" "$border_color"
fi
