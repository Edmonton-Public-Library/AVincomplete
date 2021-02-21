#!/bin/bash
####################################################
#
# notify_customers.sh source file for project avincomplete. 
#
# Driver to run mailerbot.pl for avincomplete. Intended to be run as cron on EPLAPP.
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
#   0.2 - Added handling for messaging customers that have complete items. 
#   0.1 - Development. 
#
####################################################
source /software/EDPL/Unicorn/EPLwork/cronjobscripts/setscriptenvironment.sh
WORK_DIR_AN=/software/EDPL/Unicorn/EPLwork/cronjobscripts/Mailerbot/AVIncomplete
if [ ! -e $WORK_DIR_AN ]
then
	echo "**Error: no such directory '$WORK_DIR_AN'"
	exit 1
fi
cd $WORK_DIR_AN
echo `date` >> $WORK_DIR_AN/notification.log
if [ -s /software/EDPL/Unicorn/Bincustom/mailerbot.pl ]
then
	if [ -s $WORK_DIR_AN/notice.txt ]
	then 
		if [ -s $WORK_DIR_AN/customers.lst ]
		then 
			echo "== notifying customers of missing components." 
			echo "== notifying customers of missing components." >> $WORK_DIR_AN/notification.log
			echo "reading customer file..."
			echo "reading customer file..." >> $WORK_DIR_AN/notification.log
			/software/EDPL/Unicorn/Bincustom/mailerbot.pl -c"$WORK_DIR_AN/customers.lst" -n"$WORK_DIR_AN/notice.txt" >>$WORK_DIR_AN/unmailed_customers.lst 2>>$WORK_DIR_AN/err.log
			echo "done."
			echo "done." >> $WORK_DIR_AN/notification.log
			echo "Saving list of mailed customers." 
			echo "Saving list of mailed customers." >> $WORK_DIR_AN/notification.log
			cat $WORK_DIR_AN/customers.lst >>$WORK_DIR_AN/notification.log
			rm $WORK_DIR_AN/customers.lst
			echo "===="
			echo "====" >> $WORK_DIR_AN/notification.log
		else
			echo "no customers to notify." 
			echo "no customers to notify." >> $WORK_DIR_AN/notification.log
			exit 0
		fi
	else
		echo "** error, notice file is empty or doesn't exist."
		echo "** error, notice file is empty or doesn't exist.">> $WORK_DIR_AN/notification.log 
		exit 2
	fi
	# Now do the completed accounts.
	if [ -s $WORK_DIR_AN/complete_notice.txt ]
	then 
		if [ -s $WORK_DIR_AN/complete_customers.lst ]
		then 
			echo "== notifying customers of completed items." 
			echo "== notifying customers of completed items." >> $WORK_DIR_AN/notification.log
			echo "reading customer complete file..."
			echo "reading customer complete file..." >> $WORK_DIR_AN/notification.log
			/software/EDPL/Unicorn/Bincustom/mailerbot.pl -c"$WORK_DIR_AN/complete_customers.lst" -n"$WORK_DIR_AN/complete_notice.txt" >>$WORK_DIR_AN/unmailed_customers.lst 2>>$WORK_DIR_AN/err.log
			echo "done."
			echo "done." >> $WORK_DIR_AN/notification.log
			echo "Saving list of mailed customers." 
			echo "Saving list of mailed customers." >> $WORK_DIR_AN/notification.log
			cat $WORK_DIR_AN/complete_customers.lst >>$WORK_DIR_AN/notification.log
			rm $WORK_DIR_AN/complete_customers.lst
			echo "===="
			echo "====" >> $WORK_DIR_AN/notification.log
		else
			echo "no customers with complete items to notify." 
			echo "no customers with complete items to notify." >> $WORK_DIR_AN/notification.log
			exit 0
		fi
	else
		echo "** error, notice file is empty or doesn't exist."
		echo "** error, notice file is empty or doesn't exist.">> $WORK_DIR_AN/notification.log 
		exit 2
	fi
else
	echo "**Error: unable to find mailerbot.pl" 
	echo "**Error: unable to find mailerbot.pl" >>$WORK_DIR_AN/notification.log 2>&1
	exit 3
fi
exit 0
