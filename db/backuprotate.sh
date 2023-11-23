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
#   0.4 Changed names of logs, and clean schedule.
#
#################################################################
WORK_DIR=/home/ilsdev/projects/avincomplete/db
APP=$(basename -s .sh "$0")
LOG="$WORK_DIR/$APP.log"
if [ ! -f "$LOG" ]; then
  echo "log $LOG file not found"
  exit 1
fi
timestamp=$(date +%Y%m%d)
# backup database and complete.log
tar cvfz "avincomplete.$timestamp.tgz" avincomplete.db marknotify.log notification.log load_avincomplete.log "$LOG"
echo > "$LOG"
### Keep the number of old log files down to 10.
if [ -s "avincomplete.$timestamp.tgz" ]
then
	/usr/local/bin/clean.pl -t"avincomplete.202*" -v -u
else
	echo "*** WARNING **** couldn't clean up the avincomplete.202... files because the last backup failed!"
fi
#EOF
