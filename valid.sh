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
#   exit 6: NC isn't state in .iso file
#   exit 7: More categories than items
#   exit 8: Categories field is a number

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

#Checking for missing headers, statement below ignores empty lines and lines that have only spaces/tabs in file
category_count=$(sed '/^[[:blank:]]*$/d' "$filename" | wc -l)

if [ "$category_count" -lt 4 ]; then
    echo "ERROR: Missing header line"
    #HERE
    #echo "Last header line: $(awk -v line="$count" '{if(NR==line) print $0}' "$filename")"
    echo "Last header line: $(awk '/./{line=$0} END{print line}' "$filename")"
    exit 5
fi

#Checking for NC as state in .iso files
if [ "$extension" == "iso" ]; then
    #HERE
    #state="$(awk 'NR==2 {print substr($0, length($0)-1)}' "$filename")"
    state=$(grep "^address:.*" "$filename" | sed 's/^.*: //' | awk '{print substr($0, length($0)-1)}')
    if [ "$state" != "NC" ]; then
        echo "ERROR: State in .iso invoice is not NC --> State found was: $state"
        exit 6
    fi
fi

#NEW CHECK
#Checking oso file to see if state is NC
if [ "$extension" == "oso" ]; then
    state=$(grep "^address:.*" "$filename" | sed 's/^.*: //' | awk '{print substr($0, length($0)-1)}')
    if [ "$state" == "NC" ]; then
        echo "ERROR: State in .oso invoice is NC"
    fi
fi

#Checking to see if item count is valid for amount of categories
#HERE

category_count=$(($(grep -oP '(?<=categories:).*' "$filename" | tr -cd , | wc -c) + 1))
items=$(($(grep -oP '(?<=items:).*' "$filename" | tr -cd , | wc -c) + 1))

if [ "$category_count" -ne "$items" ]; then
    echo "ERROR: invalid item quantities: $category_count categories but $items items"
    exit 7
fi

#Checking if any categories are numbers
temp=$(grep -oP '(?<=categories:).*' "$filename")
check=$(echo "$temp" | tr -d ' ')
IFS=','
read -a arr <<< "$check"
#This regex handles numbers with decimals and signs in front
numbers='^[+-]?[0-9]+([.][0-9]+)?$'
for val in "${arr[@]}";
do
  if [[ $val =~ $numbers ]]; then
      echo "ERROR: Categories can not be numbers"
      exit 8
  fi
done