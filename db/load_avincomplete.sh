#!/bin/bash
####################################################
#
# load_avincomplete.sh source file for project avincomplete. 
#
# Refreshes data in the AV incomplete database.
#    Copyright (C) 2015  Andrew Nisbet
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
#   0.6 - Removing -d because we don't need to charge to branch discard cards, just a default single system card. 
#   0.5 - Removing -l to run just once a day after closing. 
#         Stops newly added items from being deleted prematurely.
#   0.4 - Add '-D' for removing discarded items.
#   0.3 - Removed running '-t' in favour of a faster schedule on complete items.
#         See markcomplete.sh. 
#   0.2 - Added '-t' and don't blow away the old log, just keep appending. 
#   0.1 - Dev. 
#
####################################################
WORK_DIR_AN=/home/ilsdev/projects/avincomplete/db
echo `date` >> $WORK_DIR_AN/load.log
test=`ps x | grep avincomplete | wc -l`
k=10
if [ $(echo " $test > $k" | bc) -eq 1 ]
then
	echo "== process busy." >> $WORK_DIR_AN/load.log
	exit 2
fi
if [ -s $WORK_DIR_AN/avincomplete.pl ]
then
	cd $WORK_DIR_AN
	echo "== database $WORK_DIR_AN/avincomplete.pl updating AVSNAG cards." >> $WORK_DIR_AN/load.log
	$WORK_DIR_AN/avincomplete.pl -c >>$WORK_DIR_AN/load.log 2>&1
	echo "done." >> $WORK_DIR_AN/load.log
	echo "== database $WORK_DIR_AN/avincomplete.pl updating items entered by staff." >> $WORK_DIR_AN/load.log
	$WORK_DIR_AN/avincomplete.pl -u >>$WORK_DIR_AN/load.log 2>&1
	echo "done." >> $WORK_DIR_AN/load.log
	echo "== database $WORK_DIR_AN/avincomplete.pl updating items from AVSNAGS cards." >> $WORK_DIR_AN/load.log
	$WORK_DIR_AN/avincomplete.pl -U >>$WORK_DIR_AN/load.log 2>&1
	echo "done." >> $WORK_DIR_AN/load.log
	echo "== database $WORK_DIR_AN/avincomplete.pl processing discard items." >> $WORK_DIR_AN/load.log
	$WORK_DIR_AN/avincomplete.pl -D >>$WORK_DIR_AN/load.log 2>&1
	echo "done." >> $WORK_DIR_AN/load.log
	echo "====" >> $WORK_DIR_AN/load.log
else
	echo "**Error: unable to find $WORK_DIR_AN/avincomplete.pl" >>$WORK_DIR_AN/load.log 2>&1
fi
# EOF