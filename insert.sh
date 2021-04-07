#!/bin/bash

# Project 2: Will insert a record into a text invoice. Accepts Two arguemnts the 
# invoice name name nad the second is optional representing the category of records 
# that the user wishes to insert. If there is no second argument then the script
# prompts the user to enter records for every missing record in th escript. 
#
# Author: Carlee Yancey
# Author: Brett Dale
# Version 1 (12 April, 2021)
#
# Exit Status:
#   exit 0: Good
#   exit 1: usage error dealing with args
#   exit 2: file is invalid
#   exit 3: The given category to insert is not valid for the given invoice
#

#check the number of args
if [ "$#" -gt 2 ] # To many args
then 
    echo "Usage: insert.sh <filename> [optional: <category>]"
    exit 1
elif [ "$#" -eq 0 ] # No Args 
then 
    echo "Usage: insert.sh <filename> [optional: <category>]"
    exit 1
else 
    filename=$1
    if [ "$2" != "" ] #Checks to see if the second arg exist
    then 
        categoryInsert=$2
    else
        categoryInsert=""
    fi
fi

#checks to see if the given file is valid. 
bash valid.sh $filename
status=$? #gets the exit status from the call to valid
if [ $status -ne 0 ] #checks to see if exit with 0
then
    echo $filename" is not a valid file"
    exit 2
fi

#checks to see if the user gave a category arg
if [ "$categoryInsert" != "" ]
then
    validCategory=0 # if 0 not valid, if 1 valid. 
    category="" 
    categories=$(awk -F: '$1=="categories"{print $2}'  $filename)
    clength=$(echo $categories | awk -F, '{print NF}') #Get length of categories
    index=0
    while [ $clength -gt $index ]
    do
        category=$(echo $categories | cut -d, -f$(($index+1))) #Gets a single category
        if [ $validCategory -eq 0 ] # Will only enter if the categoryInsert is not valid yet
        then
            shopt -s nocasematch # Turns on nocasematch
            # Checks to see if the current category equals the category that we want to insert
            case $category in
                $categoryInsert)
                    validCategory=1 # Sets validCategory to 1 since they match
                    categoryIndex=$index
                    ;;
            esac
            shopt -u nocasematch # Turns off nocasematch
        fi
        ((index++))
    done

    if [ $validCategory -eq 0 ] # Invalid category to insert
    then
        echo $categoryInsert" is not a valid category for this invoice"
        exit 3
    fi
fi

numInserted=0 # Then number of items that is inserted

#Check to see if missing any missing records for even category
if [ "$categoryInsert" != "" ] # Checking a certain catergoy
then

    itemList=$(awk -F: '$1=="items"{print $2}'  $filename) # Gets the items numbers
    itemNum=$(echo $itemList | cut -d, -f$(($categoryIndex+1))) #Gets the number for said category
   
    #Get the number of times that category has info
    itemCount=$(grep -c -i "^$categoryInsert" $filename)

    #Checks to see if it matches  itemNum
    if [ $itemCount -ne $itemNum ]
    then
        while [ $itemNum -gt $itemCount ]
        do
            echo -n "Please enter the name of the "$categoryInsert" item > "
            read itemName
            echo -n "Please enter a price per unit of "$categoryInsert" > "
            read price
            echo -n "Pleae enter the amount of "$categoryInsert" units to purchase > "   
            read amount
            
            lowerCat=$(echo $categoryInsert | tr '[:upper:]' '[:lower:]')
            echo $lowerCat": "$itemName", "$price", "$amount >> $filename
            echo ""
            ((numInserted++))
            ((itemCount++))
        done
    fi    
else
    index=0
    categories=$(awk -F: '$1=="categories"{print $2}'  $filename)
    clength=$(echo $categories | awk -F, '{print NF}') #Get length of categories
    category=""
    while [ $clength -gt $index ]
    do
        category=$(echo $categories | cut -d, -f$(($index+1))) #Gets a single category
        itemList=$(awk -F: '$1=="items"{print $2}'  $filename) # Gets the items numbers
        itemNum=$(echo $itemList | cut -d, -f$(($index+1))) #Gets the number for said category
   
        #Get the number of times that category has info
        itemCount=$(grep -c -i "^$category" $filename)

        #Checks to see if it matches  itemNum
        if [ $itemCount -ne $itemNum ]
        then
            while [ $itemNum -gt $itemCount ]
            do
                echo -n "Please enter the name of the "$category" item > "
                read itemName
                echo -n "Please enter a price per unit of "$category" > "
                read price
                echo -n "Pleae enter the amount of "$category" units to purchase > "   
                read amount
            
                lowerCat=$(echo $category | tr '[:upper:]' '[:lower:]')
                echo $lowerCat": "$itemName", "$price", "$amount >> $filename
                echo ""
                ((numInserted++))
                ((itemCount++))
            done
        fi
        ((index++)) 
    done    
fi

#Prints out how many where inserted and exits 0
echo $numInserted" records added to "$filename" invoice"
exit 0
