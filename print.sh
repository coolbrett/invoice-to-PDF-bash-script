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


#Checking command line arg count
echo  "arg count: $#"
if [[ $# -gt 2 ]] || [[ $# -lt 1 ]]; then
    echo "usage: print.sh <invoice filename> [-c]"
    exit 1
fi

#Checking that if arg count is 2, that the second arg is "-c"
if [[ $# -eq 2 ]] && [[ $1 != "-c" ]]; then
    echo "usage: print.sh <invoice filename [-c]"
    exit 1
fi

#Running to make sure file is valid
bash valid.sh "$1"
echo "File is valid"

#Now we turn create our LaTeX file
filename="tmp.tex"
touch $filename
> $filename

#Adding the basics of a LaTeX file
echo "\begin{table}[ht]
\caption{Nonlinear Model Results} % title of Table
\centering % used for centering table
\begin{tabular}{c c c c} % centered columns (4 columns)
\hline %inserts single horizontal line
Category & Item & Cost & Quantity & Total \\ [0.5ex] % inserts table
%heading
\hline\hline % inserts double horizontal line

\hline %inserts single line
\end{tabular}
\label{tab:nonlin} % is used to refer this table in the text
\end{table}" >> $filename

