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
NOTICE_DIR=/software/EDPL/Unicorn/Notices
LOG=$WORK_DIR_AN/notification.log

# Mailerbot specific variables.
MAILER=/software/EDPL/Unicorn/Bincustom/mailerbothtml.sh

# The location of the you-returned-something-incomplete HTML notice.
INCOMPLETE_HTML_TEMPLATE=$NOTICE_DIR/AVIncompleteNotice.html
# This is the 'thank you' notice template if an item is made complete HTML notice.
COMPLETE_HTML_TEMPLATE=$NOTICE_DIR/AVIncompleteIsComplete.html
# The list of the customer that need to be notified they returned incomplete items.
# The list is created by avincomplete.pl.
# TODO: Change this in avincomplete.
INCOMPLETE_ITEM_CUSTOMER_LIST=$WORK_DIR_AN/incomplete_item_customers.lst
# List of customers that need to be notified their items are now complete.
COMPLETE_ITEM_CUSTOMER_LIST=$WORK_DIR_AN/complete_item_customers.lst
IS_TEST=false
TEST_CUSTOMER=21221012345678
TEST_DATA="21221012345678|Cats / by Jim Pipe|insert / booklet missing|31221096645630|ABB"
## Added -t test flag.
VERSION="2.01.02"
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
 -t, -test, --test: Runs in test mode. Only $TEST_CUSTOMER is 
   processed using fake data: 
   '$TEST_DATA'
   and only $TEST_CUSTOMER is emailed.
 -v, -version, --version: Outputs the application version number.
 -V, -VARS, --VARS: Outputs the variables used by the application.
 -x, -xhelp, --xhelp: Outputs this help message.

  Version: $VERSION
EOFU!
}

# Logs messages to STDOUT and $LOG file.
# param:  Message to put in the file.
logit()
{
    local message="$1"
    local time=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$time] $message" | tee -a $LOG
}

# Logs messages as an error and exits with status code '1'.
# Parameter: String message.
logerr()
{
    local message="${1} exiting!"
    local time=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$time] **error: $message" | tee -a $LOG
    exit 1
}

# Diagnostic
print_vars()
{
	echo "\$WORK_DIR_AN=$WORK_DIR_AN"
    echo "\$NOTICE_DIR=$NOTICE_DIR"
	echo "\$LOG=$LOG"

	# Mailerbot specific variables.
	echo "\$MAILER=$MAILER"

	# The location of the you-returned-something-incomplete notice.
	echo "\$INCOMPLETE_HTML_TEMPLATE=$INCOMPLETE_HTML_TEMPLATE"
	# This is the 'thank you' notice template if an item is made complete.
	echo "\$COMPLETE_HTML_TEMPLATE=$COMPLETE_HTML_TEMPLATE"
	# The list of the customer that need to be notified they returned incomplete items.
	# The list is created by avincomplete.pl.
	echo "\$INCOMPLETE_ITEM_CUSTOMER_LIST=$INCOMPLETE_ITEM_CUSTOMER_LIST"
	# List of customers that need to be notified their items are now complete.
	echo "\$COMPLETE_ITEM_CUSTOMER_LIST=$COMPLETE_ITEM_CUSTOMER_LIST"
    echo "\$IS_TEST=$IS_TEST"
    echo "\$TEST_CUSTOMER=$TEST_CUSTOMER"
    echo "\$TEST_DATA=$TEST_DATA"
}

### Check input parameters.
# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "help,test,version,VARS,xhelp" -o "htvxV" -a -- "$@")
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"
while true
do
    case $1 in
    -h|--help)
        usage
        exit 0
        ;;
    -t|--test)
        # TODO: Implement test mode.
        logit "testing mode set."
        IS_TEST=true
        ;;
    -v|--version)
        echo "$APPLICATION_NAME version: $VERSION"
        exit 0
        ;;
	-V|--VARS)
        print_vars
        ;;
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
if [ "$IS_TEST" == true ]; then
    echo "$TEST_DATA" >$INCOMPLETE_ITEM_CUSTOMER_LIST
    echo "$TEST_DATA" >$COMPLETE_ITEM_CUSTOMER_LIST
fi
[[ -s "$INCOMPLETE_HTML_TEMPLATE" ]] || logerr "**error, the text file for incomplete item notices ($INCOMPLETE_HTML_TEMPLATE) is missing or empty." 
if [ -s "$INCOMPLETE_ITEM_CUSTOMER_LIST" ]; then
	logit "== notifying customers of missing components."
	logit "reading incomplete item customers' file and mailing them."
    $MAILER --log_file=$LOG --customers=$INCOMPLETE_ITEM_CUSTOMER_LIST --template=$INCOMPLETE_HTML_TEMPLATE
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
[[ -s "$COMPLETE_HTML_TEMPLATE" ]] || logerr "**error, the text file for incomplete item notices ($COMPLETE_HTML_TEMPLATE) is missing or empty." 
# Then check if there are customers to notify that their items are complete.
if [ -s "$COMPLETE_ITEM_CUSTOMER_LIST" ]; then 
	logit "== notifying customers of completed items." 
	logit "reading complete item customers' file and mailing them."
    $MAILER --log_file=$LOG --customers=$COMPLETE_ITEM_CUSTOMER_LIST --template=$COMPLETE_HTML_TEMPLATE
	logit "done." 
	logit "Saving list of mailed customers." 
	cat $COMPLETE_ITEM_CUSTOMER_LIST >>$LOG
	rm $COMPLETE_ITEM_CUSTOMER_LIST
	logit "====" 
else
	logit "no customers with complete items to notify." 
fi

exit 0
