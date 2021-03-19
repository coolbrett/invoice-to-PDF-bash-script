#!/bin/bash

# Project 2: Creates purpose is to create a new file corresponding to the type specified.
# It calls the valid.sh script to make sure the file that was created is valid.
# Creates files that contain header information only.
#
# Author: Carlee Yancey
# Author: Brett Dale
# Version: 1 (24 March, 2021)
#
# Exit Status:
#   exit 0: Good
#   exit 1: usage error dealing with args
#   exit 2: file name already exist 
#   exit 3: Length of state is not 2
#

#checks the number of args
if [ "$#" -gt 2 ] # to many args
then
    echo "Usage: create.sh -i|-o filename"
    exit 1
elif [ "$#" -eq 1 ] #short an argument
then    
    echo "Usage: create.sh -i|-o filename"
    exit 1
elif [ "$#" -eq 0 ] #no args
then     
    echo "Usage: create.sh -i|-o filename"
    exit 1
else #has correct number of args, checks what the args are
    
    file=$2 #get the filename

    #checks the $1 is -0 or -i
    if [ "$1" != "-i" ] && [ "$1" != "-o" ]
    then
        echo "Usage: create.sh -i|-o filename"
        exit 1
    elif [ "$1" = "-o" ]
    then 
        state=""
        filename="$file.oso"
    elif [ "$1" = "-i" ]
    then
        state="NC"
        filename="$file.iso"
    fi

    #check that the filename does not already exist
    if [ -e $filename ]
    then
        echo "ERROR: " $filename "already exist"
        exit 2
    fi
fi

#Prompts the user for information
echo -n "Please enter customer name > " 
read name

echo -n "Please enter street address > "
read street

echo -n "Please enter city > "
read city

if [ "$state" != "NC" ] #Checking to see if out of state
then
    echo -n "Please enter state > "
    read state
    length=`echo $state | awk '{print length}'`
  
    if [ $length -ne 2 ] # checking the length of the state
    then
        echo "ERROR: " $state "is not the correct length for a state abberviation: ("$length")"    
        exit 3
    fi
fi

#Makes sure that there is at least one catergory.
categories=""
while [ "$categories" = "" ]
do
    echo -n "Please enter the fields that comprise the order > " 
    read categories
done
#TODO handle getting each category

clength=$(echo $categories | wc -w)

#Asking for the number of items for the categories
numbers=""
category=""
index=0
while [ $clength -gt $index ]
do 
    val=$(echo $categories | cut -d" " -f$(($index+1)))
    echo -n "Please enter the number of \""$val"\" items you want to purchase > "
    read num
    if [ "$numbers" = "" ]
    then
        numbers=$num
    else
        numbers="$numbers,$num"  
    fi
    if [ "$category" = "" ]
    then
        category=$val
    else
        category="$category, $val"
    fi
    ((index++))
done

#create the file 
touch $filename
echo "customer:"$name >> $filename
echo "address:"$street", "$city", "$state >> $filename
echo "categories:"$category >> $filename
#TODO categories
echo "items:" $numbers >> $filename

exit 0

#check to see if valid 
echo "calling valid with " $filename
bash valid.sh $filename

status=$? #exit status of vaild
if [ $status -e 0 ]
then
    echo $filename "has been created for "
    #TODO print the first two lines of the created file
else
    #TODO handle deleteing the file
    rm $filename
fi
exit 0

