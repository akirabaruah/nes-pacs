#!/bin/bash

if [ $# -ne 2 ]; then
    echo "usage: $0 <file> <dumpfile>"
    exit 1
fi

FILE=$1
DUMPFILE=$2
TMP1=${FILE}.1.tmp
TMP2=${FILE}.2.tmp

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
function runtest {
    COMMAND=$1
    MESSAGE=$2

    if [ -z "$MESSAGE" ]; then
	MESSAGE=$COMMAND
    fi

    echo '' >> $DUMPFILE
    echo $MESSAGE >> $DUMPFILE
    $COMMAND >> $DUMPFILE
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
	echo -e "[${GREEN}pass${NC}] $MESSAGE"
    else
	echo -e "[${RED}fail${NC}] $MESSAGE"
    fi
}

obj_dir/Vcpu $FILE | tail -n+1 > $TMP1
std/fake6502 $FILE | head -n-1 > $TMP2

runtest "diff $TMP1 $TMP2" "$FILE"
rm $TMP1 $TMP2
