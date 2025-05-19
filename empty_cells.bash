#!/bin/bash

# check empty cells
# This script analysis a define text file to count the number
# of empty (blank or whitespace) cells in each column.


# Check number of arguments
if [[ $# -ne 2 ]]; then
  echo "Please provide the correct format." >&2
  echo "Example: ./empty_cells.bash filename.txt \";\"" >&2
  exit 1
fi


input_file="$1"
separator="$2"

# Check the input file existance
if [[ ! -r "$input_file" ]]; then
  echo "Error: '$input_file' not exists." >&2
  exit 1
fi

# Read header row to get column names
IFS="$separator" read -r -a headers < <(head -n 1 "$input_file" | sed 's/^\xEF\xBB\xBF//' | sed 's|^/||')
num_columns=${#headers[@]}

# Initialize array to count empty cells per column
declare -a empty_counts
for ((i = 0; i < num_columns; i++)); do
  empty_counts[i]=0
done

# Process the file starting from the second line
tail -n +2 "$input_file" | while IFS="$separator" read -r -a row; do
  for ((i = 0; i < num_columns; i++)); do
    cell="${row[i]}"
    # cut whitespace
    cell="${cell#"${cell%%[![:space:]]*}"}"
    cell="${cell%"${cell##*[![:space:]]}"}"
    # Check if cell is empty
    if [[ -z "$cell" ]]; then
      ((empty_counts[i]++))
    fi
  done
done

# display results
echo "Empty cell counts per column:"
for ((i = 0; i < num_columns; i++)); do
  printf "%s: %d\n" "${headers[i]}" "${empty_counts[i]}"
done
