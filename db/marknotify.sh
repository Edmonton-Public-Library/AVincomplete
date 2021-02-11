#!/bin/bash
####################################################
#
# load_avincomplete.sh source file for project avincomplete. 
#
# Driver script to output customers that should be notified of missing items.
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
#   0.3 - Removed code that backs off if too many processes are running. 
#   0.2 - Added removal of items that are no longer charged. 
#   0.1 - Scheduled -n mark customers for notification of missing material. 
#
####################################################
WORK_DIR_AN=/home/ilsdev/projects/avincomplete/db
ADDRESSES="andrew.nisbet@epl.ca"
echo `date` >> $WORK_DIR_AN/load.log
if [ -s $WORK_DIR_AN/avincomplete.pl ]
then
	cd $WORK_DIR_AN
	echo "== database $WORK_DIR_AN/avincomplete.pl removing items whose home locations have changed to LOST." >> $WORK_DIR_AN/load.log
	$WORK_DIR_AN/avincomplete.pl -l >>$WORK_DIR_AN/load.log 2>&1
	echo "done." >> $WORK_DIR_AN/load.log
	echo "== database $WORK_DIR_AN/avincomplete.pl -n making note of customers to notify." >> $WORK_DIR_AN/load.log
	$WORK_DIR_AN/avincomplete.pl -n >>$WORK_DIR_AN/load.log 2>&1
	echo "done." >> $WORK_DIR_AN/load.log
	echo "====" >> $WORK_DIR_AN/load.log
else
	echo "**Error: unable to find $WORK_DIR_AN/avincomplete.pl" >>$WORK_DIR_AN/load.log 2>&1
	echo "**Error: unable to find $WORK_DIR_AN/avincomplete.pl" | mailx -a'From:ilsdev@ilsdev1.epl.ca' -s"AVI report" $ADDRESSES
fi
# EOF