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
HOME=/home/ilsdev/projects/avincomplete/db
echo `date` >> $HOME/load.log
test=`ps x | grep avincomplete | wc -l`
k=3
if [ $(echo " $test > $k" | bc) -eq 1 ]
then
	echo "== process busy." >> $HOME/load.log
	exit 2
fi
if [ -s $HOME/avincomplete.pl ]
then
	cd $HOME
	echo "== database $HOME/avincomplete.pl discharging complete items." >> $HOME/load.log
	$HOME/avincomplete.pl -t >>$HOME/load.log 2>&1
	echo "done." >> $HOME/load.log
	echo "====" >> $HOME/load.log
else
	echo "**Error: unable to find $HOME/avincomplete.pl" >>$HOME/load.log 2>&1
fi
# EOF