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
#   0.2 - Added removal of items that are no longer charged. 
#   0.1 - Scheduled -n mark customers for notification of missing material. 
#
####################################################
HOME=/home/ilsdev/projects/avincomplete/db
echo `date` >> $HOME/load.log
test=`ps x | grep avincomplete | wc -l`
k=10
if [ $(echo " $test > $k" | bc) -eq 1 ]
then
	echo "== process busy." >> $HOME/load.log
	exit 2
fi
if [ -s $HOME/avincomplete.pl ]
then
	cd $HOME
	echo "== database $HOME/avincomplete.pl removing items whose home locations have changed to LOST." >> $HOME/load.log
	$HOME/avincomplete.pl -l >>$HOME/load.log 2>&1
	echo "done." >> $HOME/load.log
	echo "== database $HOME/avincomplete.pl -n making note of customers to notify." >> $HOME/load.log
	$HOME/avincomplete.pl -n >>$HOME/load.log 2>&1
	echo "done." >> $HOME/load.log
	echo "====" >> $HOME/load.log
else
	echo "**Error: unable to find $HOME/avincomplete.pl" >>$HOME/load.log 2>&1
fi
# EOF