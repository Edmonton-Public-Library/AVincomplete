#!/bin/bash
#################################################################
#
# Rotate the log file and back up the database for AV incomplete.
#    Copyright (C) 2015  Andrew Nisbet, Edmonton Public Library.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# Author:  Andrew Nisbet, Edmonton Public Library
# Dependencies: clean.pl
# Version:
#   0.2 - Added clean up if backup successful.
#   0.1 - added save of discard.log
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
### Keep the number of old log files down to 10.
# backup database and complete.log
tar cvfz avincomplete.$timestamp.tgz avincomplete.db complete.log discard.log

if [ -s avincomplete.$timestamp.tgz ]
then
	clean.pl -t"avincomplete.201*" -v -u
else
	echo "*** WARNING **** couldn't clean up the avincomplete.201... files because the last backup failed!"
fi
### Keep the number of old log files down to 10.
if [ -s $newlogfile ]
then
	clean.pl -t"load.log.201*" -v -u
else
	echo "*** WARNING **** couldn't clean up the load.log.201... files because the last backup failed!"
fi
#EOF
