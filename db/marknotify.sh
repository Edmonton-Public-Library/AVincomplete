#!/bin/bash
####################################################
#
# load_avincomplete.sh source file for project avincomplete. 
#
# Driver script to output customers that should be notified of missing items.
#    Copyright (C) 2015-2023 Andrew Nisbet
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
# Created: Tue Apr 14 12:20:04 MDT 2015
# Rev:     
#   0.4 Fixed some recommendations from ShellCheck. 
#
####################################################
WORK_DIR_AN=/home/ilsdev/projects/avincomplete/db
ADDRESSES="andrew.nisbet@epl.ca"
APP=$(basename -s .sh "$0")
LOG="$WORK_DIR_AN/$APP.log"
echo "$(date)" >> "$LOG"
if [ -s $WORK_DIR_AN/avincomplete.pl ]
then
	cd $WORK_DIR_AN || { echo "**Error unable to change into $WORK_DIR_AN"; exit 1; }
	{ echo "== database $WORK_DIR_AN/avincomplete.pl removing items whose home locations have changed to LOST.";
	$WORK_DIR_AN/avincomplete.pl -l;
	echo "done.";
	echo "== database $WORK_DIR_AN/avincomplete.pl -n making note of customers to notify.";
	$WORK_DIR_AN/avincomplete.pl -n;
	echo "done.";
	echo "===="; } >> "$LOG" 2>&1
else
	echo "**Error: unable to find $WORK_DIR_AN/avincomplete.pl" >>"$LOG" 2>&1
	echo "**Error: unable to find $WORK_DIR_AN/avincomplete.pl" | mailx -a'From:ilsdev@ilsdev1.epl.ca' -s"AVI report" $ADDRESSES
fi
# EOF