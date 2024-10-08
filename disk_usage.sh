#!/bin/bash

#Author: Dhananjaya Kumar N
#Description: Simple Shell script to alert through email when disk usage is high

EMAIL="user1@gmail.com user2@gmail.com"
SUBJECT="Disk Usage Monitor"
THRESHOLD=6

checkssmtp(){
    if ! command -v ssmtp &> /dev/null
    then
        echo "Error: ssmtp is not installed. Please install it first."
        exit 1
    fi
}

checkemail(){
    for address in $EMAIL
    do
        if [[ ! "$address" =~ ^[A-Za-z0-9.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
        then
            echo "Error: Invalid email format for $address"
            exit 1
        fi
    done
}

checkemail
checkssmtp

DISK_INFO=$(df -h | awk -v threshold="$THRESHOLD" '$5+0 > threshold {print "Disk Usage of " $1 " is " $5}')

if [[ ! -z "$DISK_INFO" ]]
then
    (
        echo "To: $EMAIL"
        echo "Subject: $SUBJECT"
        echo
        echo "Report Generated on $(date)"
        echo
        echo "$DISK_INFO"
    ) | ssmtp $EMAIL

    echo "Alert email sent - high disk usage detected!"
else
    echo "All disks are below ${THRESHOLD}% - no alert needed."
fi

