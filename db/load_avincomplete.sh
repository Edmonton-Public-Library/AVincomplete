#!/bin/bash
####################################################
#
# load_avincomplete.sh source file for project avincomplete. 
#
# Refreshes data in the AV incomplete database.
#    Copyright (C) 2015-2023  Andrew Nisbet
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
#   0.7 Fixed some recommendations from ShellCheck.
#
####################################################
WORK_DIR_AN=/home/ilsdev/projects/avincomplete/db
APP=$(basename -s .sh "$0")
LOG="$WORK_DIR_AN/$APP.log"
echo "$(date)" >> "$LOG"
test=$(pgrep --count avincomplete)
k=10
if [ "$(echo " $test > $k" | bc)" -eq 1 ]
then
	echo "== process busy." >> "$LOG"
	exit 2
fi
if [ -s $WORK_DIR_AN/avincomplete.pl ]
then
	cd $WORK_DIR_AN || { echo "**Error unable to change into $WORK_DIR_AN"; exit 1; }
	{ echo "== database $WORK_DIR_AN/avincomplete.pl updating AVSNAG cards.";
	$WORK_DIR_AN/avincomplete.pl -c ;
	echo "done.";
	echo "== database $WORK_DIR_AN/avincomplete.pl updating items entered by staff.";
	$WORK_DIR_AN/avincomplete.pl -u ;
	echo "done.";
	echo "== database $WORK_DIR_AN/avincomplete.pl updating items from AVSNAGS cards.";
	$WORK_DIR_AN/avincomplete.pl -U ;
	echo "done.";
	echo "== database $WORK_DIR_AN/avincomplete.pl processing discard items.";
	$WORK_DIR_AN/avincomplete.pl -D ;
	echo "done.";
	echo "===="; } >> "$LOG" 2>&1
else
	echo "**Error: unable to find $WORK_DIR_AN/avincomplete.pl" >>"$LOG" 2>&1
fi
# EOF