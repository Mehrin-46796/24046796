#!/bin/bash
# clean data
# This script takes a semi-colon delimited file, assigns missing IDs, replaces decimal commas,
# removes non-ASCII characters, and outputs a cleaned tab-separated version.


input_file_path="$1"

#input file check command

if [[ $# -ne 1 || ! -f "$input_file_path" ]]; then
  echo -e "\aError: Please provide valid file name for execute"
  exit 1
fi


#next available ID command

maximum_valid_id=$(awk -F';' '
  NR > 1 && $1 ~ /^[0-9]+$/ {
    id = $1 + 0
    if (id > maximum_valid_id) maximum_valid_id = id
  }
  END {
    print maximum_valid_id
  }
' "$input_file_path")

next_valid_id=$((maximum_valid_id + 1))

#Clean/process the data command

awk -F';' -v next_valid_id="$next_valid_id" '
BEGIN {
  OFS = "\t" 
}

NR == 1 {
  print 
  next
}

{
  #new Id assign command
  if ($1 == "") {
    $1 = next_valid_id
    next_valid_id++
  }

  #decimal commas replace command
  for (i = 1; i <= NF; i++) {
    gsub(",", ".", $i)
  }

  #nonASCII characters remove command
  for (i = 1; i <= NF; i++) {
    gsub(/[^\x00-\x7F]/, "", $i)
  }

  #Print command
  print
}
' "$input_file_path" | sed 's/\r$//'

