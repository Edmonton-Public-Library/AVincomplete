#!/bin/bash
#################################################################
#
# Rotate the log file and back up the database for AV incomplete
#
#################################################################
WORK_DIR=/home/ilsdev/projects/avincomplete/db
cd $WORK_DIR
logfile=$WORK_DIR/load.log
if [ ! -f $logfile ]; then
  echo "log $logfile file not found"
  exit 1
fi
timestamp=`date +%Y%m%d`
newlogfile=$logfile.$timestamp
cp $logfile $newlogfile
gzip -f -9 $newlogfile
cat /dev/null > $logfile

# backup database and complete.log
tar cvfz avincomplete.$timestamp.tgz avincomplete.db complete.log
#EOF
