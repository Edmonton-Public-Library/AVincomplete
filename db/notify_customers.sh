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
source /s/sirsi/Unicorn/EPLwork/cronjobscripts/setscriptenvironment.sh
HOME=/s/sirsi/Unicorn/EPLwork/cronjobscripts/Mailerbot/AVIncomplete
if [ ! -e $HOME ]
then
	echo "**Error: no such directory '$HOME'"
	exit 1
fi
cd $HOME
echo `date` >> $HOME/notification.log
if [ -s /s/sirsi/Unicorn/Bincustom/mailerbot.pl ]
then
	if [ -s $HOME/notice.txt ]
	then 
		if [ -s $HOME/customers.lst ]
		then 
			echo "== notifying customers of missing components." 
			echo "== notifying customers of missing components." >> $HOME/notification.log
			echo "reading customer file..."
			echo "reading customer file..." >> $HOME/notification.log
			/s/sirsi/Unicorn/Bincustom/mailerbot.pl -c"$HOME/customers.lst" -n"$HOME/notice.txt" >>$HOME/unmailed_customers.lst 2>>$HOME/err.log
			echo "done."
			echo "done." >> $HOME/notification.log
			echo "Saving list of mailed customers." 
			echo "Saving list of mailed customers." >> $HOME/notification.log
			cat $HOME/customers.lst >>$HOME/notification.log
			rm $HOME/customers.lst
			echo "===="
			echo "====" >> $HOME/notification.log
		else
			echo "no customers to notify." 
			echo "no customers to notify." >> $HOME/notification.log
			exit 0
		fi
	else
		echo "** error, notice file is empty or doesn't exist."
		echo "** error, notice file is empty or doesn't exist.">> $HOME/notification.log 
		exit 2
	fi
	# Now do the completed accounts.
	if [ -s $HOME/complete_notice.txt ]
	then 
		if [ -s $HOME/complete_customers.lst ]
		then 
			echo "== notifying customers of completed items." 
			echo "== notifying customers of completed items." >> $HOME/notification.log
			echo "reading customer complete file..."
			echo "reading customer complete file..." >> $HOME/notification.log
			/s/sirsi/Unicorn/Bincustom/mailerbot.pl -c"$HOME/complete_customers.lst" -n"$HOME/complete_notice.txt" >>$HOME/unmailed_customers.lst 2>>$HOME/err.log
			echo "done."
			echo "done." >> $HOME/notification.log
			echo "Saving list of mailed customers." 
			echo "Saving list of mailed customers." >> $HOME/notification.log
			cat $HOME/complete_customers.lst >>$HOME/notification.log
			rm $HOME/complete_customers.lst
			echo "===="
			echo "====" >> $HOME/notification.log
		else
			echo "no customers with complete items to notify." 
			echo "no customers with complete items to notify." >> $HOME/notification.log
			exit 0
		fi
	else
		echo "** error, notice file is empty or doesn't exist."
		echo "** error, notice file is empty or doesn't exist.">> $HOME/notification.log 
		exit 2
	fi
else
	echo "**Error: unable to find mailerbot.pl" 
	echo "**Error: unable to find mailerbot.pl" >>$HOME/notification.log 2>&1
	exit 3
fi
exit 0
