#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <file>"
    exit 1
fi

FILE=$1
TMPFILE=${FILE}.tmp

sed 's/\t\+/ /g' $FILE | sed 's/ \+/ /g' > ${TMPFILE}
cp $TMPFILE $FILE
rm $TMPFILE
