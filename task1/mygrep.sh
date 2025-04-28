#!/bin/bash

show_line_numbers=0
invert_match=0
pattern=""
filename=""

usage() {
  echo "Usage: $0 [OPTIONS] PATTERN FILE"
  echo "Search for PATTERN in FILE."
  echo
  echo "options:"
  echo "  -n    prefix each line of output with the 1-based line number."
  echo "  -v    invert the sense of matching, to select non-matching lines."
  echo "  -h, --help  Display this help and exit."
  exit 1
}

if [[ "$1" == "--help" ]]; then
  usage
fi

while getopts ":nvh" opt; do
  case ${opt} in
    n )
      show_line_numbers=1
      ;;
    v )
      invert_match=1
      ;;
    h )
      usage
      ;;
    \? )
      echo "Error: Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

if [ "$#" -ne 2 ]; then
  if [ "$#" -eq 1 ] && [ "$invert_match" -eq 1 ]; then
     echo "Error: Search pattern is required." >&2
  elif [ "$#" -eq 1 ]; then
     echo "Error: File name is required." >&2
  else
     echo "Error: Incorrect number of arguments." >&2
  fi
  usage
fi

pattern="$1"
filename="$2"
lower_pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')

if [ ! -f "$filename" ]; then
  echo "Error: File not found: $filename" >&2
  exit 1
fi

if [ ! -r "$filename" ]; then
  echo "Error: Cannot read file: $filename" >&2
  exit 1
fi

line_num=0
while IFS= read -r line || [[ -n "$line" ]]; do
  line_num=$((line_num + 1))
  lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

  match_found=0
  if [[ "$lower_line" == *"$lower_pattern"* ]]; then
    match_found=1
  fi

  print_this_line=0
  if [ "$invert_match" -eq 1 ]; then
    if [ "$match_found" -eq 0 ]; then
      print_this_line=1
    fi
  else
    if [ "$match_found" -eq 1 ]; then
      print_this_line=1
    fi
  fi

  if [ "$print_this_line" -eq 1 ]; then
    if [ "$show_line_numbers" -eq 1 ]; then
      printf "%d:%s\n" "$line_num" "$line"
    else
      echo "$line"
    fi
  fi
done < "$filename"

exit 0
