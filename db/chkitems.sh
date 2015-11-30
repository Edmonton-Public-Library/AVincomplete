#!/bin/bash
###########
#
# Check given file of item ids and output entry within avincomplete database.
# July 27, 2015
#
###########
HOME=/home/ilsdev/projects/avincomplete/db
cd $HOME
if [ ! -s /home/ilsdev/projects/avincomplete/db/$1 ]
then
	echo "*** error, expected file name on stdin, or could not find it in $HOME."
	exit 1
fi
# Explanation:
# -r prevents backslash escapes from being interpreted.
# || [[ -n $line ]] prevents the last line from being ignored if it 
# doesn't end with a \n (since read returns a non-zero exit code when it encounters EOF).
while read -r line || [[ -n "$line" ]]; do
    echo "SELECT * FROM avincomplete WHERE ItemId=$line;" | sqlite3 avincomplete.db
done < "$1"
