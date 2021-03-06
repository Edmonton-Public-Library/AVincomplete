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
	echo "== database $HOME/avincomplete.pl updating AVSNAG cards." >> $HOME/load.log
	$HOME/avincomplete.pl -c >>$HOME/load.log 2>&1
	echo "done." >> $HOME/load.log
	echo "== database $HOME/avincomplete.pl updating items entered by staff." >> $HOME/load.log
	$HOME/avincomplete.pl -u >>$HOME/load.log 2>&1
	echo "done." >> $HOME/load.log
	echo "== database $HOME/avincomplete.pl updating items from AVSNAGS cards." >> $HOME/load.log
	$HOME/avincomplete.pl -U >>$HOME/load.log 2>&1
	echo "done." >> $HOME/load.log
	echo "== database $HOME/avincomplete.pl processing discard items." >> $HOME/load.log
	$HOME/avincomplete.pl -D >>$HOME/load.log 2>&1
	echo "done." >> $HOME/load.log
	echo "====" >> $HOME/load.log
else
	echo "**Error: unable to find $HOME/avincomplete.pl" >>$HOME/load.log 2>&1
fi
# EOF