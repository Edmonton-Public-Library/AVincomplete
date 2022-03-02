#!/bin/bash
####################################################
#
# notify_customers.sh source file for project avincomplete. 
#
# Driver to run mailerbot.pl for avincomplete. Intended to be run as cron on EPLAPP.
#    Copyright (C) 2022  Andrew Nisbet
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
#
####################################################
. /software/EDPL/Unicorn/EPLwork/cronjobscripts/setscriptenvironment.sh
WORK_DIR_AN=/software/EDPL/Unicorn/EPLwork/cronjobscripts/Mailerbot/AVIncomplete
LOG=$WORK_DIR_AN/notification.log

# Mailerbot specific variables.
MAILER=/software/EDPL/Unicorn/Bincustom/mailerbot.pl
MAILERBOT_ERROR_LOG=$WORK_DIR_AN/mailerbot_errors.log

# The location of the you-returned-something-incomplete notice.
INCOMPLETE_NOTICE_TEXT=$WORK_DIR_AN/incomplete_item_notice.txt
# This is the 'thank you' notice template if an item is made complete.
COMPLETE_NOTICE_TEXT=$WORK_DIR_AN/complete_item_notice.txt
# The list of the customer that need to be notified they returned incomplete items.
# The list is created by avincomplete.pl.
# TODO: Change this in avincomplete.
INCOMPLETE_ITEM_CUSTOMER_LIST=$WORK_DIR_AN/incomplete_item_customers.lst
# List of customers that need to be notified their items are now complete.
COMPLETE_ITEM_CUSTOMER_LIST=$WORK_DIR_AN/complete_item_customers.lst
# Customers that failed to be mailed by mailerbot.
UNMAILED_CUSTOMERS=$WORK_DIR_AN/unmailed_customers.lst

VERSION="1.00.01"
APPLICATION_NAME=$(basename -s .sh $0)
###############################################################################
# Display usage message.
# param:  none
# return: none
usage()
{
    cat << EOFU!
Usage: $APPLICATION_NAME [-option]
  Prepares and coordinates emailing AV incomplete customers.

  By default it mails customers both if they return items incomplete,
  and if an item previously identified as incomplete has been made
  whole and returned to circulation.

	-h, -help, --help: Outputs this help message.
	-x, -xhelp, --xhelp: Outputs this help message.
	-v, -version, --version: Outputs the application version number.
	-V, -VARS, --VARS: Outputs the variables used by the application.

  Version: $VERSION
EOFU!
}

# Logs messages to STDOUT and $LOG file.
# param:  Message to put in the file.
logit()
{
    local message="$1"
    local time=$(date +"%Y-%m-%d %H:%M:%S")
    if [ -t 0 ]; then
        # If run from an interactive shell message STDOUT and LOG.
        echo -e "[$time] $message" | tee -a $LOG
    else
        # If run from cron do write to log.
        echo -e "[$time] $message" >>$LOG
    fi
}

# Logs messages as an error and exits with status code '1'.
# Parameter: String message.
logerr()
{
    local message="${1} exiting!"
    local time=$(date +"%Y-%m-%d %H:%M:%S")
    if [ -t 0 ]; then
        # If run from an interactive shell message STDOUT and LOG.
        echo -e "[$time] **error: $message" | tee -a $LOG
    else
        # If run from cron do write to log.
        echo -e "[$time] **error: $message" >>$LOG
    fi
    exit 1
}

# TODO: test
# Diagnostic
print_vars()
{
	echo "\$WORK_DIR_AN=$WORK_DIR_AN"
	echo "\$LOG=$LOG"

	# Mailerbot specific variables.
	echo "\$MAILER=$MAILER"
	echo "\$MAILERBOT_ERROR_LOG=$MAILERBOT_ERROR_LOG"

	# The location of the you-returned-something-incomplete notice.
	echo "\$INCOMPLETE_NOTICE_TEXT=$INCOMPLETE_NOTICE_TEXT"
	# This is the 'thank you' notice template if an item is made complete.
	echo "\$COMPLETE_NOTICE_TEXT=$COMPLETE_NOTICE_TEXT"
	# The list of the customer that need to be notified they returned incomplete items.
	# The list is created by avincomplete.pl.
	echo "\$INCOMPLETE_ITEM_CUSTOMER_LIST=$INCOMPLETE_ITEM_CUSTOMER_LIST"
	# List of customers that need to be notified their items are now complete.
	echo "\$COMPLETE_ITEM_CUSTOMER_LIST=$COMPLETE_ITEM_CUSTOMER_LIST"
	# Customers that failed to be mailed by mailerbot.
	echo "\$UNMAILED_CUSTOMERS=$UNMAILED_CUSTOMERS"
}

# TODO: test
### Check input parameters.
# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "help,version,VARS,xhelp" -o "hvxV" -a -- "$@")
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"
while true
do
    case $1 in
	# TODO: test
    -h|--help)
        usage
        exit 0
        ;;
	# TODO: test
    -v|--version)
        echo "$APPLICATION_NAME version: $VERSION"
        exit 0
        ;;
	# TODO: test
	-V|--VARS)
        print_vars
        ;;
	# TODO: test
    -x|--xhelp)
        usage
        exit 0
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

# TODO: test
[[ -d "$WORK_DIR_AN" ]] || logerr "**error, '$WORK_DIR_AN' is an invalid working directory."
cd $WORK_DIR_AN
# TODO: test
[[ -x "$MAILER" ]] || logerr "**error: unable to use $MAILER"
# TODO: test
[[ -s "$INCOMPLETE_NOTICE_TEXT" ]] || logerr "**error, the text file for incomplete item notices ($INCOMPLETE_NOTICE_TEXT) is missing or empty." 
if [ -s "$INCOMPLETE_ITEM_CUSTOMER_LIST" ]; then
	logit "== notifying customers of missing components."
	logit "reading customer file..."
	# TODO: Change mailerbot to use -h for HTML notices and test.
	$MAILER -c"$INCOMPLETE_ITEM_CUSTOMER_LIST" -n"$INCOMPLETE_NOTICE_TEXT" >>$UNMAILED_CUSTOMERS 2>>$MAILERBOT_ERROR_LOG
	logit "done."
	logit "Saving list of mailed customers."
	cat $INCOMPLETE_ITEM_CUSTOMER_LIST >>$LOG
	# Make sure this happens to avoid multiple mailings of the same customers.
	rm $INCOMPLETE_ITEM_CUSTOMER_LIST
	logit "===="
else
	logit "no customers to notify of incomplete items."
fi

# Now do the completed accounts.
# But stop if the verbage for the notice to customers about completed items is missing or empty.
# TODO: change to HTML notice verbage.
[[ -s "$COMPLETE_NOTICE_TEXT" ]] || logerr "**error, the text file for incomplete item notices ($COMPLETE_NOTICE_TEXT) is missing or empty." 
# Then check if there are customers to notify that their items are complete.
if [ -s "$COMPLETE_ITEM_CUSTOMER_LIST" ]; then 
	logit "== notifying customers of completed items." 
	logit "reading customer complete file..."
	# TODO: Change mailerbot to use -h for HTML notices and test.
	$MAILER -c"$COMPLETE_ITEM_CUSTOMER_LIST" -n"$COMPLETE_NOTICE_TEXT" >>$UNMAILED_CUSTOMERS 2>>$MAILERBOT_ERROR_LOG
	logit "done." 
	logit "Saving list of mailed customers." 
	cat $COMPLETE_ITEM_CUSTOMER_LIST >>$LOG
	rm $COMPLETE_ITEM_CUSTOMER_LIST
	logit "====" 
else
	logit "no customers with complete items to notify." 
fi

exit 0
