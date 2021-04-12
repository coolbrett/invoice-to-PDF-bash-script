#!/bin/bash

# Shell script to print invoices using LaTeX
#
# Author: Carlee Yancey
# Author: Brett Dale
# Version 1 (April 9th, 2021)

# Exit Status:
#   exit 0: Good
#   exit 1: usage errors, command line args error related
#   exit 2: File passed is not readable
#   exit 3: File passed does not have correct extensions
#   exit 4: File did not pass valid.sh check


#Checking command line arg count
if [[ $# -gt 2 ]] || [[ $# -lt 1 ]]; then
    echo "usage: print.sh <invoice filename> [-c]"
    exit 1
fi

#Checking that if arg count is 2, that the second arg is "-c"
if [[ $# -eq 2 ]] && [[ $2 != "-c" ]]; then
    echo "usage: print.sh <invoice filename [-c]"
    exit 1
fi

#Running to make sure file is valid
invoice="$1"
bash valid.sh "$invoice"
status=$?
if [ $status -ne 0 ]; then
    echo "$invoice is not a valid invoice"
    exit 4
fi

#Now we turn create our groff file
filename="tmp.tr"
touch $filename
> $filename
#Adding the basics of a groff
echo ".sp 10
.ps 14
.vs 16
.TS
center, box, expand, nowarn, tab(/);" >> $filename

#Grab name and address here
name=$(awk -F: '$1=="customer"{print $2}' "$invoice")
address=$(awk -F: '$1=="address"{print $2}' "$invoice")

#Table formatting w/ name and address added in
echo "c c c c c
c c c c c
c r c r c .
/ /$name/ /
/ /$address/ /
.sp .1v
_
.sp .1v
Category/Item/Cost/Quantity/Total
.sp .1v
=
.sp .1v" >> $filename

#Get our data from invoice
categories=$(awk -F: '$1=="categories"{print $2}'  "$invoice")
clength=$(echo "$categories" | awk -F, '{print NF}')
index=0

#temp file that may get sorted depending on -c flag existing
datafile="temp.dat"
touch $datafile
> $datafile
while [ "$clength" -gt $index ]; do
    #get single category, then find lines with items matching category
    category=$(echo "$categories" | cut -d, -f$(($index+1)))
    #elimates leading and trailing whitespace, some categories were coming out as " category"
    category="$(echo -e "${category}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    data=$(grep "^$category:.*" "$invoice" | sed 's/^.*: //')
    #Below is using our lines retrieved from grep and iterating through them
    echo "$data" |
    while IFS= read -r line ;
    do
      #temp=$(echo $line | tr -d ' ')
      temp=$line
      product=$(echo "$temp" | cut -d "," -f 1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
      price=$(echo "$temp" | cut -d "," -f 2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | awk '{printf "%.2f\n", $1}')
      quantity=$(echo "$temp" | cut -d "," -f 3 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
      total=$(awk -v price="$price" -v quantity="$quantity" 'BEGIN{total=(price*quantity); printf("%.2f", total)}')
      #here we write to the groff file
      echo "$category/$product/$price/$quantity/$total" >> $datafile
    done
    #echo "$data" | cut -d "," -f 2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
    ((index++))
done

#Check for -c flag
if [ "$2" == "-c" ]; then
    sorted="sorted.dat"
    touch $sorted
    sort -n -t / -k5 $datafile > $sorted
    cat $sorted >> $filename
    rm $sorted
    else
      cat $datafile >> $filename
      rm $datafile
fi
#finishing groff file
echo ".TE" >> $filename

#compiling groff file into ps file to display
tbl tmp.tr | groff > tmp.ps
rm tmp.tr
okular tmp.ps
rm tmp.ps
exit 0