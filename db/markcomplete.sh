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
#   0.1 - Scheduled -t to accommodate quicker checkouts for complete material. 
#
####################################################
WORK_DIR_AN=/home/ilsdev/projects/avincomplete/db
echo `date` >> $WORK_DIR_AN/load.log
if [ -s $WORK_DIR_AN/avincomplete.pl ]
then
	cd $WORK_DIR_AN
	echo "== database $WORK_DIR_AN/avincomplete.pl -t discharging complete items." >> $WORK_DIR_AN/load.log
	$WORK_DIR_AN/avincomplete.pl -t >>$WORK_DIR_AN/load.log 2>&1
	echo "done." >> $WORK_DIR_AN/load.log
	echo "====" >> $WORK_DIR_AN/load.log
else
	echo "**Error: unable to find $WORK_DIR_AN/avincomplete.pl" >>$WORK_DIR_AN/load.log 2>&1
fi
# EOF