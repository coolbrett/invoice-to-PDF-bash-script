#!/bin/bash

# Shell script to make sure file created is valid

# Author: Carlee Yancey
# Author: Brett Dale
# Version: 1 (March 24, 2021)

# Exit Status:
#   exit 0: Good
#   exit 1: usage error dealing with args
#   exit 2: file name already exist
#   exit 3: Length of state is not 2
#   exit 4: File is not able to be read / accessible
#   exit 5: Missing headers

#first step is to check argument count
filename=$1
if ! [[ $# -eq 1 ]]; then
    echo "usage: ./valid.sh <filename>"
    exit 1
fi

#now we check permissions of file passed in
if ! [[ -r "$filename" ]]; then
    echo "ERROR: $filename is not accessible"
    exit 4
fi

#Checking the file extension to make sure it is valid
extension="${filename##*.}"

if [ "$extension" != "iso" ] && [ "$extension" != "oso" ]; then
    echo "ERROR: \".$extension\" is not a valid file extension"
    exit 4
fi

#Checking for missing headers, statement below ignores empty lines and lines that have only spaces/tabs
count=$(sed '/^[[:blank:]]*$/d' $filename | wc -l)

if [ "$count" -lt 4 ]; then
    echo "ERROR: Missing header line"
    echo "Last header line: $(awk -v line="$count" '{if(NR==line) print $0}' "$filename")"
    exit 5
fi