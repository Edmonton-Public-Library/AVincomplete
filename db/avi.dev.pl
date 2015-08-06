#!/usr/bin/perl -w
####################################################
#
# Perl source file for project avincomplete 
# Purpose: Help fill a request from Vicky to report the
# number of users we could email a reminder about materials
# returned incomplete. 
#
# Or more suscintly: Would it be possible to tell me the following? Of the items that were checked
# out to AVSNAGS cards in 2012, how many had a previous borrower without an
# email address? (This is so we have an idea of how many customers staff would
# need to call under our proposed new method).
# Method:
# Assumptions: You already have a list of items checked out from EPL-AVSNAG cards.
# If you don't do: 
# **********************************************************************************************
#    seluser -p"EPL-AVSNAG" -oBp >snag.cards.ids.lst
#    cat snag.cards.ids.lst | grephist.pl -D"20120101,20121231" -c"CV" >all.snags.2012.lst
#    cat all.snags.2012.lst | cut -d^ -f6 | cut -c3- >item.ids.lst
# Now you have all the items.
# **********************************************************************************************
# 1) get a list of the last users that borrowed the item:
#   a) for each item get all charges
#   b) find the last date
#
# Finds and reports last users of AVIncomplete items and prints their addresses.
#    Copyright (C) 2015  Andrew Nisbet, Edmonton Public Library.
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
# Dependencies: seluser, selitem, selcatalog, selhold, selcharge, chargeitems.pl
#               createholds.pl, cancelholds.pl, dischargeitem.pl.
# Created: Tue Apr 16 13:38:56 MDT 2013
# Rev: 
#          0.7.01 - Fix discharge to use station library current default is EPLMNA.
#          0.7.00 - Add -n to notify customers of missing components.
#          0.6.04 - Fix to discharge items.
#          0.6.03 - Discharge item from user charge item to discard.
#          0.6.02 - Remove holds from branch cards when item marked complete.
#          0.6.01 - Fixed spelling mistake in usage.
#          0.6 - Audit items in database and check item out to AVSnag if not checked out.
#          0.5 - Add test for checkout to anyone and logic to check item out to AVSnag if not checked out.
#                This will stop reported items from appearing on the PULL hold lists when a copy level hold
#                is placed.
#          0.4 - Add -D to discard items marked discard, replaces original use of -D dump to HTML.
#                and records complete records before removing them.
#          0.3 - Added -t to discharge items marked complete.
#          0.2 - Fix to -u titles not updating, items in database not checked
#                off customers' card. -U and -u refactored. 
#          0.1 - Dev. 
#
# Dependencies: mailbot.pl
#
####################################################

use strict;
use warnings;
use vars qw/ %opt /;
use Getopt::Std;
use DBI;

my $DB_FILE  = "avincomplete.db";
my $DSN      = "dbi:SQLite:dbname=$DB_FILE";
my $USER     = "";
my $PASSWORD = "";
my $DBH      = "";
my $SQL      = "";

my $AVSNAG   = "AVSNAG"; # Profile of the av snag cards.
my $DATE     = `date +%Y-%m-%d`;
chomp( $DATE );

my $VERSION  = qq{0.7.01};

# Trim function to remove whitespace from the start and end of the string.
# param:  string to trim.
# return: string without leading or trailing spaces.
sub trim( $ )
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

#
# Message about this program and how to use it.
#
sub usage()
{
    print STDERR << "EOF";

	usage: $0 [-acCdftuUx] [-D<foo.bar>]
Creates and manages av incomplete sqlite3 database.
Note: -c and -d flags rebuild the avsnag cards and discard cards for a branch based on 
profiles. The branch id must appear as the first 3 letters of its name like: SPW-AVSNAG, or
RIV-DISCARD, for a discard card.

 -a: Audits items in the database to ensure they are checked out and if not checks them out 
     to the branch's av snag card. This option typically doesn't need to be run regularly
     since items entered with -u are automatically checked out to a snag card if they are
     not currently checked out, and the process takes a long time since it looks at all 
     items in the database. It is safe to run since it doesn't update the local database
     and merely makes calls to the ILS to check and charge items. Another $0 
     process may safely run at the same time if you have scheduled it to do so.
 -c: Refreshes the avsnagcards table of EPL-AVSNAG cards. These are the cards used to checkout 
     materials and place holds. Can safely be run regularly. AV incomplete cards themselves
     don't change all that often, but if a new one is added this should be run. See '-d'
     for discard cards. This should be run before -U to ensure all cards are attributable
     to a given branch before we start trying to insert items and place holds on those items.
 -C: Create new database called '$DB_FILE'. If the db exists '-f' must be used.
 -d: Refreshes the avdiscardcards table of DISCARD cards. Can safely be run regularly especially
     if a new branch discard card is added. See '-c' for avsnag cards.
 -D: Process items marked as discard. Tests items are in ILS and if so cancels any hold for the
     branch AVSNAG card, discharges them from the card they are currently charged to, 
     then quickly charges them to the branches' discard card, then logs the entry and removes
     the entry from the avincomplete.db database.
 -f: Force create new database called '$DB_FILE'. **WIPES OUT EXISTING DB**
 -n: Send out notifications of incomplete materials. Customers with emails will be emailed
     from the production server.
 -t: Discharge items that are marked complete, removing the copy level hold on any of the
     branches' AVSNAG cards.
 -u: Updates database based on items entered by staff on the web site. Safe to do anytime.
 -U: Updates database based on items on cards with $AVSNAG profile. Safe to run anytime,
     but should be run with a frequency that is inversely proportional to the amount of
     time staff are servicing AV incomplete.
 -x: This (help) message.

example: 
 $0 -x
 
Version: $VERSION
EOF
    exit;
}

######### Subroutines
# Table reference:
#
# sqlite> .schema
# CREATE TABLE avincomplete (
        # ItemId INTEGER PRIMARY KEY NOT NULL,
        # Title CHAR(256),
        # CreateDate DATE DEFAULT CURRENT_DATE,
        # UserKey INTEGER,
        # UserId INTEGER,
        # UserPhone CHAR(20),
        # UserName  CHAR(100),
        # UserEmail CHAR(100),
        # Processed INTEGER DEFAULT 0,
        # ProcessDate DATE DEFAULT NULL,
        # Contact INTEGER DEFAULT 0,
        # ContactDate DATE DEFAULT NULL,
        # Complete INTEGER DEFAULT 0,
        # CompleteDate DATE DEFAULT NULL,
        # Discard  INTEGER DEFAULT 0,
        # DiscardDate DATE DEFAULT NULL,
        # Location CHAR(6) NOT NULL,
        # TransitLocation CHAR(6) DEFAULT NULL,
        # TransitDate DATE DEFAULT NULL,
        # Comments CHAR(256),
        # Notified  INTEGER DEFAULT 0,
        # NoticeDate DATE DEFAULT NULL
# );
# CREATE TABLE avsnagcards (
        # UserKey INTEGER PRIMARY KEY NOT NULL,
        # UserId CHAR(20) NOT NULL,
        # Branch CHAR(6) NOT NULL
# );
# CREATE TABLE avdiscardcards (
        # UserKey INTEGER PRIMARY KEY NOT NULL,
        # UserId CHAR(20) NOT NULL,
        # Branch CHAR(6) NOT NULL
# );
#
# Creates new records in the AV incomplete database. Ignores if the 
# primary key (item ID) is already present.
# param:  Lines of data to store: 
#         '31221102616518  |Pride and prejudice|535652|21221021851248|Smith, Merlin|780-244-5655|xxxxxxxx@hotmail.com|'
# param:  library code string like 'WMC'
# return: none.
sub insertNewItem( $$ )
{
	# Now start importing data.
	my $line    = shift;
	my $libCode = shift;
	my($itemId, $title, $userKey, $userId, $name, $phone, $email) = split( '\|', $line );
	if ( defined $itemId and $libCode ne '')
	{
		$itemId   = trim( $itemId );
		$userKey  = trim( $userKey );
		$userId   = trim( $userId );
		if ( $userId !~ m/\d{13,}/ )
		{
			$name = 'N/A';
			$phone= 'N/A';
			$email= 'N/A';
		}
		$title    = trim( $title );
		$name     = trim( $name );
		$phone    = trim( $phone );
		$email    = trim( $email );
		
		# 31221106301570  |Call of duty|82765|21221020238199|Sutherland, Buster Brown|780-299-0755||
		# print "$itemId, '$title', $userKey, $userId, '$name', '$phone', '$email' '$libCode'\n";
		$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avincomplete 
(ItemId, Title, UserKey, UserId, UserName, UserPhone, UserEmail, Processed, ProcessDate, Location) 
VALUES 
(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
END_SQL
		$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
			PrintError       => 0,
			RaiseError       => 1,
			AutoCommit       => 1,
			FetchHashKeyName => 'NAME_lc',
		});
		$DBH->do($SQL, undef, $itemId, $title, $userKey, $userId, $name, $phone, $email, 1, $DATE, $libCode);
		$DBH->disconnect;
	}
	else
	{
		print STDERR "rejecting item '$itemId'\n";
	}
}

# Updates a staff entered record in the AV incomplete database.
# param:  Lines of data to store: 
#         '31221102616518  |Pride and prejudice|535652|21221021851248|Smith, Merlin|780-244-5655|xxxxxxxx@hotmail.com|'
# return: none.
sub updateNewItems( $ )
{
	$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
		PrintError       => 0,
		RaiseError       => 1,
		AutoCommit       => 1,
		FetchHashKeyName => 'NAME_lc',
	});
	# Now start importing data.
	my $line = shift;
	my($itemId, $title, $userKey, $userId, $name, $phone, $email) = split( '\|', $line );
	if ( defined $itemId )
	{
		$itemId   = trim( $itemId );
		$userKey  = trim( $userKey );
		$userId   = trim( $userId );
		if ( $userId !~ m/\d{13,}/ )
		{
			$name = 'N/A';
			$phone= 'N/A';
			$email= 'N/A';
		}
		$title    = trim( $title );
		$name     = trim( $name );
		$phone    = trim( $phone );
		$email    = trim( $email );
		print STDERR "updating item '$itemId'\n";

		# 31221106301570  |Call of duty|564906|2122102299999|V, Brook|780-451-2345|xxxxxxxx@hotmail.com|
		# print "$itemId, '$title', $userKey, $userId, '$name', '$phone', '$email'\n";
		$SQL = <<"END_SQL";
UPDATE avincomplete SET Title=?, UserKey=?, UserId=?, UserName=?, UserPhone=?, UserEmail=?, Processed=?, ProcessDate=? 
WHERE ItemId=?
END_SQL
		$DBH->do($SQL, undef, $title, $userKey, $userId, $name, $phone, $email, 1, $DATE, $itemId);
	}
	else
	{
		print STDERR "update rejecting item '$itemId'\n";
	}
	$DBH->disconnect;
}

# Inserts av snag cards into the  incomplete table.
# param:  user key integer.
# param:  user id string.
# param:  branch string.
# return: none.
sub insertAvSnagCard( $$$ )
{
	my $userKey = shift;
	my $userId  = shift;
	my $branch  = shift;
$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
	PrintError       => 0,
	RaiseError       => 1,
	AutoCommit       => 1,
	FetchHashKeyName => 'NAME_lc',
});
	$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avsnagcards 
(UserKey, UserId, Branch) 
VALUES 
(?, ?, ?)
END_SQL
	$DBH->do($SQL, undef, $userKey, $userId, $branch);
	$DBH->disconnect;
}

# Inserts av discard cards into the avincomplete.db database avdiscardcards table.
# param:  user key integer.
# param:  user id string.
# param:  branch string.
# return: none.
sub insertAvDiscardCard( $$$ )
{
	my $userKey = shift;
	my $userId  = shift;
	my $branch  = shift;
$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
	PrintError       => 0,
	RaiseError       => 1,
	AutoCommit       => 1,
	FetchHashKeyName => 'NAME_lc',
});
	$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avdiscardcards 
(UserKey, UserId, Branch) 
VALUES 
(?, ?, ?)
END_SQL
	$DBH->do($SQL, undef, $userKey, $userId, $branch);
	$DBH->disconnect;
}

# Creates the AV incomplete table.
# param:  none.
# return: none.
sub createAvIncompleteTable()
{
	$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
	   PrintError       => 0,
	   RaiseError       => 1,
	   AutoCommit       => 1,
	   FetchHashKeyName => 'NAME_lc',
	});
	
	$SQL = <<"END_SQL";
CREATE TABLE avincomplete (
	ItemId INTEGER PRIMARY KEY NOT NULL,
	Title CHAR(256),
	CreateDate DATE DEFAULT CURRENT_DATE,
	UserKey INTEGER,
	UserId INTEGER,
	UserPhone CHAR(20),
	UserName  CHAR(100),
	UserEmail CHAR(100),
	Processed INTEGER DEFAULT 0,
	ProcessDate DATE DEFAULT NULL,
	Contact INTEGER DEFAULT 0,
	ContactDate DATE DEFAULT NULL,
	Complete INTEGER DEFAULT 0,
	CompleteDate DATE DEFAULT NULL,
	Discard  INTEGER DEFAULT 0,
	DiscardDate DATE DEFAULT NULL,
	Location CHAR(6) NOT NULL,
	TransitLocation CHAR(6) DEFAULT NULL,
	TransitDate DATE DEFAULT NULL,
	Comments CHAR(256),
	Notified  INTEGER DEFAULT 0,
	NoticeDate DATE DEFAULT NULL
);
END_SQL
	$DBH->do($SQL);
	$DBH->disconnect;
}

# Creates the AV incomplete table.
# param:  none.
# return: none.
sub createAvSnagCardsTable()
{
	$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
	   PrintError       => 0,
	   RaiseError       => 1,
	   AutoCommit       => 1,
	   FetchHashKeyName => 'NAME_lc',
	});
	# AV snag cards ids are never digits, more like MNA-AVSNAG
	$SQL = <<"END_SQL";
CREATE TABLE avsnagcards (
	UserKey INTEGER PRIMARY KEY NOT NULL,
	UserId CHAR(20) NOT NULL,
	Branch CHAR(6) NOT NULL
);
END_SQL
	$DBH->do($SQL);
	$DBH->disconnect;
}

# Creates the AV incomplete discard cards table. This is where the branch's 
# discard cards are going to be stored.
# param:  none.
# return: none.
sub createAvDiscardCardsTable()
{
	$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
	   PrintError       => 0,
	   RaiseError       => 1,
	   AutoCommit       => 1,
	   FetchHashKeyName => 'NAME_lc',
	});
	# AV snag cards ids are never digits, more like MNA-AVSNAG
	$SQL = <<"END_SQL";
CREATE TABLE avdiscardcards (
	UserKey INTEGER PRIMARY KEY NOT NULL,
	UserId CHAR(20) NOT NULL,
	Branch CHAR(6) NOT NULL
);
END_SQL
	$DBH->do($SQL);
	$DBH->disconnect;
}

# Places a hold for a given item. The item is checked in the local db, it's location
# determined, then the avsnag card is found for the branch, then a hold is placed for 
# the avsnag card's owning library.
# param:  item ID.
# return: <none>
sub placeHoldForItem( $ )
{
	my ($itemId) = shift;
	# Get the branch's snag card, but make sure we limit it to one card.
	my $branchCard = `echo "select UserId from avsnagcards where Branch = (select Location from avincomplete where ItemId=$itemId) LIMIT 1;" | sqlite3 $DB_FILE`;
	my $branch     = `echo "select Location from avincomplete where ItemId=$itemId;" | sqlite3 $DB_FILE`;
	chomp( $branchCard );
	chomp( $branch );
	if ( $branchCard ne '' )
	{
		print "\n\n\n Branch card: '$branchCard' \n\n\n";
		# Does a hold exist for this item on this card? If there is no hold it will return nothing.
		# echo ABB-AVINCOMPLETE | seluser -iB | selhold -iU -oI | selitem -iI -oB | grep $itemId # will output all the ids 
		my $hold = `echo "$branchCard|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | seluser -iB | selhold -iU -jACTIVE -oI | selitem -iI -oB | grep $itemId'`; # will output all the ids 
		if ( $hold eq '' )
		{
			if ( $branch ne '' )
			{
				`echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | createholds.pl -l"EPL$branch" -B"$branchCard" -U'`;
				print STDERR "Ok: copy hold place on item '$itemId' for '$branchCard'.\n";
			}
			else # Couldn't find the branch for this avsnag card.
			{
				print STDERR "Couldn't find the branch for '$branchCard' for '$itemId'.\n";
			}
		}
		else # Hold already exists on card for identified branch.
		{
			print STDERR "'$itemId' already on hold for '$branchCard'.\n";
		}
	}
	else # Branch card not found for requested branch.
	{
		print STDERR "* warn: couldn't find a branch card because the branch name was empty on item '$itemId'\n";
	}
}

# Updates a staff entered record in the AV incomplete database.
# param:  Lines of data to store: 
#         '31221102616518|535652|21221021851248|Smith, Merlin|780-244-5655|xxxxxxxx@hotmail.com|'
# return: none.
sub updateUserInfo( $ )
{
	# Now start importing data.
	my $line = shift;
	my($itemId, $userKey, $userId, $name, $phone, $email) = split( '\|', $line );
	$userKey  = trim( $userKey );
	$userId   = trim( $userId );
	if ( $userId !~ m/\d{12}/ )
	{
		$name = 'N/A';
		$phone= 'N/A';
		$email= 'N/A';
	}
	$name     = trim( $name );
	$phone    = trim( $phone );
	$email    = trim( $email );
	print STDERR "updating item '$itemId'\n";
	# 31221106301570|82765|21221020238199|Sutherland, Buster Brown|780-299-0755||
	# print "$itemId, $userKey, $userId, '$name', '$phone', '$email'\n";
	$SQL = <<"END_SQL";
UPDATE avincomplete SET UserKey=?, UserId=?, UserName=?, UserPhone=?, UserEmail=?, Processed=?, ProcessDate=? 
WHERE ItemId=?
END_SQL
	$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
		PrintError       => 0,
		RaiseError       => 1,
		AutoCommit       => 1,
		FetchHashKeyName => 'NAME_lc',
	});
	$DBH->do($SQL, undef, $userKey, $userId, $name, $phone, $email, 1, $DATE, $itemId);
	$DBH->disconnect;
}

# This function takes a item ID as an argument, and returns 1 if the current location is CHECKEDOUT and the 
# account is a legit customer, that is, not a system card, and 0 otherwise.
# param:  Item ID 
# return: 1 if checked out to customer and 0 otherwise.
sub isCheckedOutToCustomer( $ )
{
	my $itemId = shift;
	# my $locationCheck = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -om'`;
	my $locationCheck = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -oIm | selcharge -iI -oUS | seluser -iU -oSB'`;
	# On success: 'CHECKEDOUT|21221022896929|' on fail: ''
	# Here we check if we get at least 12 digits because system cards are letters and L-PASS and ME have different 
	# numbers but all more than 12.
	return 1 if ( $locationCheck =~ m/CHECKEDOUT/ and $locationCheck =~ m/\d{12}/ );
	return 0;
}

# This function takes a item ID as an argument, and returns 1 if the 
# current location is CHECKEDOUT and 0 otherwise.
# param:  Item ID 
# return: 1 if checked out to anyone (system or customer) and 0 otherwise.
sub isCheckedOut( $ )
{
	my $itemId = shift;
	# my $locationCheck = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -om'`;
	my $locationCheck = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -oIm | selcharge -iI -oUS | seluser -iU -oSB'`;
	# On success: 'CHECKEDOUT|21221022896929|' on fail: ''
	# Here we check if we get at least 12 digits because system cards are letters and L-PASS and ME have different 
	# numbers but all more than 12.
	return 1 if ( $locationCheck =~ m/CHECKEDOUT/ );
	return 0;
}

# This function takes a item ID as an argument, updates the record with the current user's  
# account information.
# param:  Item ID 
# return: none.
sub updateCurrentUser( $ )
{
	my $itemId = shift;
	# UPDATE avincomplete SET Title=?, UserKey=?, UserId=?, UserName=?, UserPhone=?, UserEmail=?, Processed=?, ProcessDate=? 
	# WHERE ItemId=?
	my $sqlAPI = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -oI | selcharge -iI -oU | seluser -iU -oUBDX.9026.X.9007.'`;
	# returns: '564906|21221012345678|V, Brooke|780-xxx-xxxx|xxxxxxxx@hotmail.com|'
	# but we need:
	#31221098551174|301585|21221012345678|Billy, Balzac|780-496-5108|ilsteam@epl.ca|
	chomp( $sqlAPI );
	$sqlAPI = $itemId . "|" . $sqlAPI;
	print STDERR "$sqlAPI\n";
	updateUserInfo( $sqlAPI );
}

# This function takes a item ID as an argument, updates the record with the current user's  
# account information.
# param:  Item ID 
# return: none.
sub updatePreviousUser( $ )
{
	my $itemId = shift;
	# UPDATE avincomplete SET Title=?, UserKey=?, UserId=?, UserName=?, UserPhone=?, UserEmail=?, Processed=?, ProcessDate=? 
	# WHERE ItemId=?
	########################## TODO finish finding the previous user.
	my $sqlAPI = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -os | seluser -iU -oUBDX.9026.X.9007.'`;
	# returns: '871426|21221021008682|W, T|780-644-nnnn|email@foo.bar|'
	# but we need:
	#31221098551174|301585|21221012345678|Billy, Balzac|780-496-5108|ilsteam@epl.ca|
	chomp( $sqlAPI );
	$sqlAPI = $itemId . "|" . $sqlAPI;
	print STDERR "$sqlAPI\n";
	updateUserInfo( $sqlAPI );
}

# This function takes a item ID as an argument, and returns 1 if the item is found on the ILS and 0 otherwise.
# param:  Item ID - note that it must be free of pipes, and should be free of any extra spaces.
# return 1 if item exists and 0 otherwise (because it was discarded).
sub isInILS( $ )
{
	my $itemId = shift;
	my $returnString = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB'`;
	return 1 if ( $returnString =~ m/\d+/ );
	return 0;
}

# This function takes a item ID as an argument, updates the title information in the database.
# param:  Item ID 
# return  none
sub updateTitle( $ )
{
	my $itemId = shift;
	# UPDATE avincomplete SET Title=?, UserKey=?, UserId=?, UserName=?, UserPhone=?, UserEmail=?, Processed=?, ProcessDate=? 
	# WHERE ItemId=?
	my $sqlAPI = `echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -oC | selcatalog -iC -ot'`;
	#31221098551174|(Item not found in ILS)|301585|21221012345678|Billy, Balzac|780-496-5108|ilsteam@epl.ca|
	chomp( $sqlAPI );
	$sqlAPI = $itemId . "|" . $sqlAPI . "0|0|Unknown|0|none|";
	print STDERR "$sqlAPI\n";
	updateNewItems( $sqlAPI );
}

# This function tests if the user key user id combo is a valid user.
# param:  string to test like '604887|WMC-AVINCOMPLETE|' 
# return  1 if the a valid system card; the bar code contains letters, and 0 otherwise.
sub isValidSystemCard( $ )
{
	my $userKeyUserId = shift;
	#   valid: '604887|WMC-AVINCOMPLETE|' 
	# invalid: '604887|21221012345678|' 
	return 1 if ( $userKeyUserId =~ m/[A-Z]+/ );
	return 0;
}

# This function tests if the given item id is in the database.
# param:  string to test like '31221012345678' 
# return  1 if the item is already in the database, and 0 otherwise.
sub alreadyInDatabase( $ )
{
	my $itemId = shift;
	my $result = `echo "SELECT ItemId, Title FROM avincomplete WHERE ItemId=$itemId;" | sqlite3 $DB_FILE`;
	if ( $result =~ m/\d{14}/ )
	{
		# All the system messages appear in parenthesis and then the word 'Item', so if we find one
		# let's try to re check the item in the ILS.
		if ( $result =~ m/\(Item/ )
		{
			return 0; # If the title is a system message, return false so we try to update again.
		}
		else
		{
			return 1;
		}
	}
	return 0;
}

# This function finds the library that owns the card passed in as parameter 1.
# param:  string to test like '604887|WMC-AVINCOMPLETE|' 
# return  string of the library code, like 'WMC', or 'MNA' if the branch can't be determined.
#         In that case, try running -c to update.
sub getLibraryCode( $ )
{
	# Set up a default, should never get used, but if there is a failure for some reason it make 
	# sense that items be routed and managed from the main branch.
	my $code = 'MNA';
	my $userKeyUserId = shift;
	my @keyIdFields   = split '\|', $userKeyUserId;
	if ( defined $keyIdFields[0] )
	{
		my $key  = $keyIdFields[0];
		$code = `echo "SELECT Branch FROM avsnagcards WHERE UserKey=$key;" | sqlite3 $DB_FILE`;
		chomp( $code );
	}
	return $code;
}

# Checks an item out to an AVSnag card. The function takes an item ID that is guaranteed not
# to be already checked out. See isCheckedOut().
# param:  item ID as a string.
# return: <none>
sub checkOutItemToAVSnag( $ )
{
	my $itemId = shift;
	# Get the branch's snag card, but make sure we limit it to one card.
	my $branchCard = `echo "select UserId from avsnagcards where Branch = (select Location from avincomplete where ItemId=$itemId) LIMIT 1;" | sqlite3 $DB_FILE`;
	my $branch     = `echo "select Location from avincomplete where ItemId=$itemId;" | sqlite3 $DB_FILE`;
	chomp( $branchCard );
	chomp( $branch );
	if ( $branchCard ne '' )
	{
		print "\n Branch SNAG card: '$branchCard' \n";
		if ( $branch ne '' )
		{
			`echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | chargeitems.pl -b -u"$branchCard" -U'`;
			print STDERR "Ok: item '$itemId' checked out to '$branchCard'.\n";
		}
		else # Couldn't find the branch for this avsnag card.
		{
			print STDERR "Couldn't find the branch for '$branchCard' for '$itemId'.\n";
		}
	}
	else # Branch card not found for requested branch.
	{
		print STDERR "* warn: couldn't find a branch card because the branch name was empty on item '$itemId'\n";
	}
}

# Checks and removes holds from the branches' AV snag card.
# param:  item ID as a string.
# return: <none>
sub cancelHolds( $ )
{
	my $itemId = shift;
	# Get the branch's snag card, but make sure we limit it to one card.
	my $branchCards = `echo "select UserId from avsnagcards where Branch = (select Location from avincomplete where ItemId=$itemId);" | sqlite3 $DB_FILE`;
	my @cards = split '\n', $branchCards;
	while (@cards)
	{
		my $branchCard = shift @cards;
		print STDERR "\n Checking and removing holds for '$branchCard'.\n";
		# Here we just instruct the script to remove the hold for the item. The script will not remove holds
		# on items if the user doesn't have a hold.
		`echo "$itemId|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | cancelholds.pl -B"$branchCard" -U'`;
		print STDERR "Ok: any holds for item '$itemId' removed from '$branchCard'.\n";
	}
}

# Kicks off the setting of various switches.
# param:  
# return: 
sub init
{
    my $opt_string = 'acCdDfntuUx';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ( $opt{'x'} );
	# Audit all items in the database to ensure that if they are not checked out, that they get checked out to
	# the appropriate branch AV snag card.
	if ( $opt{'a'} ) 
	{
		print STDERR "Checking items in database to ensure they are checked out.\n";
		my $apiResults = `echo 'SELECT ItemId FROM avincomplete;' | sqlite3 $DB_FILE`;
		my @data = split '\n', $apiResults;
		while (@data)
		{
			# For all the items that staff entered, let's find the current location.
			my $itemId = shift @data;
			# Does the item exist on the ils or was it discarded?
			if ( ! isInILS( $itemId ) )
			{
				print STDERR "$itemId not found in ILS.\n";
				# Nothing else we can do with this, let's get the next item ID.
				next;
			}
			# If the item isn't checked out at all to anyone, then check out to avsnag card 
			# so item doesn't show up on PULL hold reports, when we place a copy hold for it.
			if ( ! isCheckedOut( $itemId ) )
			{
				print STDERR "checking item out to an AVSNAG card for the current branch.\n";
				checkOutItemToAVSnag( $itemId );
			}
		}
	}
	# This looks for items that are marked complete and discharges them from the card they are checked out to.
	if ( $opt{'t'} ) 
	{
		# Find all the items marked complete.
		my $selectCompleteItems = `echo 'SELECT ItemId FROM avincomplete WHERE Complete=1;' | sqlite3 $DB_FILE`;
		my @data = split '\n', $selectCompleteItems;
		while (@data)
		{
			# For all the items that staff entered, let's find the current location.
			my $itemId = shift @data;
			# Does the item exist on the ils or was it discarded?
			if ( ! isInILS( $itemId ) )
			{
				# We could actually remove the record because if it doesn't exist it's just going to clog things up.
				print STDERR "$itemId not found in ILS, removing the entry from the database.\n";
				`echo 'DELETE FROM avincomplete WHERE ItemId=$itemId AND Complete=1;' | sqlite3 $DB_FILE`;
				next;
			}
			# cancel the hold if any, before discharging, to ensure we don't trap our own hold.
			cancelHolds( $itemId );
			# discharge the item.
			print STDERR "discharging $itemId, removing the entry from the database.\n";
			my $stationLibrary = `echo "select Location from avincomplete where ItemId=$itemId;" | sqlite3 $DB_FILE`;
			chomp $stationLibrary;
			$stationLibrary = 'EPL' . $stationLibrary;
			# Add station library to discharge -s"EPLWHP"
			`echo "$itemId" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | dischargeitem.pl -U -s"$stationLibrary"'`;
			`echo 'SELECT * FROM avincomplete WHERE ItemId=$itemId AND Complete=1;' | sqlite3 $DB_FILE >>complete.log 2>&1`;
			# remove from the av incomplete database.
			`echo 'DELETE FROM avincomplete WHERE ItemId=$itemId AND Complete=1;' | sqlite3 $DB_FILE`;
		}
		exit;
	}
	# Create new sqlite database.
	if ( $opt{'C'} ) 
	{
		if ( -e $DB_FILE )
		{
			if ( $opt{'f'} )
			{
				# Just dropping the table preserves the ownership by www-data.
				`echo "DROP TABLE avincomplete;" | sqlite3 $DB_FILE`;
				createAvIncompleteTable();
				`echo "DROP TABLE avsnagcards;" | sqlite3 $DB_FILE`;
				createAvSnagCardsTable();
				`echo "DROP TABLE avdiscardcards;" | sqlite3 $DB_FILE`;
				createAvDiscardCardsTable();
			}
			else
			{
				print STDERR "**error: db '$DB_FILE' exists. If you want to overwrite use '-f' flag.\n";
			}
			exit;
		}
		createAvIncompleteTable();
		# Set permissions so the eventual owner (www-data) and ilsdev account
		# can cron maintenance.
		my $mode = 0664;
		chmod $mode, $DB_FILE;
		print STDERR "** IMPORTANT **: don't forget to change ownership to www-data or it will remain locked to user edits.\n";
		exit;
	}
	# Process items marked for discard.
	if ( $opt{'D'} ) 
	{
		# Here we take the items that are marked discarded and discharge them, then charge them to the branch's discard card.
		# Find all the items marked complete.
		my $selectDiscardItems = `echo 'SELECT ItemId FROM avincomplete WHERE Discard=1;' | sqlite3 $DB_FILE`;
		my @data = split '\n', $selectDiscardItems;
		while (@data)
		{
			# For all the items that staff entered, let's find the current location.
			my $itemId = shift @data;
			# Does the item exist on the ils or was it discarded?
			if ( ! isInILS( $itemId ) )
			{
				# We could actually remove the record because if it doesn't exist it's just going to clog things up.
				print STDERR "$itemId not found in ILS, removing the entry from the database.\n";
				`echo 'DELETE FROM avincomplete WHERE ItemId=$itemId AND Discard=1;' | sqlite3 $DB_FILE`;
				next;
			}
			my $branchDiscardCard = `echo "select UserId from avdiscardcards where Branch = (select Location from avincomplete where ItemId=$itemId) LIMIT 1;" | sqlite3 $DB_FILE`;
			chomp( $branchDiscardCard );
			# Cancel any holds for the branches' avsnag cards
			cancelHolds( $itemId );
			# discharge the item, then recharge the item to a branch's discard card.
			print STDERR "discharging $itemId.\n";
			my $stationLibrary = `echo "select Location from avincomplete where ItemId=$itemId;" | sqlite3 $DB_FILE`;
			chomp $stationLibrary;
			$stationLibrary = 'EPL' . $stationLibrary;
			# Add station library to discharge -s"EPLWHP"
			`echo "$itemId" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | dischargeitem.pl -U -s"$stationLibrary"'`;
			print STDERR "charging $itemId, to $branchDiscardCard.\n";
			`echo "$itemId" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | chargeitems.pl -b -u"$branchDiscardCard" -U'`;
			# record what you are about to remove.
			`echo 'SELECT * FROM avincomplete WHERE ItemId=$itemId AND Discard=1;' | sqlite3 $DB_FILE >>discard.log 2>&1`;
			# remove from the av incomplete database.
			`echo 'DELETE FROM avincomplete WHERE ItemId=$itemId AND Discard=1;' | sqlite3 $DB_FILE`;
		}
		exit;
	}
	# Update database from items entered into the local database by the web site.
	# We want to get data for all the items that don't already have it so we will need:
	# Find the items in the db that are entered by staff.
	if ( $opt{'u'} )
	{
		my $apiResults = `echo 'SELECT ItemId FROM avincomplete WHERE Processed=0;' | sqlite3 $DB_FILE`;
		my @data = split '\n', $apiResults;
		while (@data)
		{
			# For all the items that staff entered, let's find the current location.
			my $itemId = shift @data;
			# Does the item exist on the ils or was it discarded?
			if ( ! isInILS( $itemId ) )
			{
				print STDERR "$itemId not found in ILS.\n";
				# post that the item is missing 
				my $apiUpdate = $itemId . '|(Item not found in ILS, maybe discarded, or invalid item ID)|0|0|Unavailable|0|none|';
				updateNewItems( $apiUpdate );
				# Nothing else we can do with this, let's get the next item ID.
				next;
			}
			# We can update the title information.
			updateTitle( $itemId );
			# if it's CHECKEDOUT then lets find the user information and update the record.
			if ( isCheckedOutToCustomer( $itemId ) )
			{
				print STDERR "Yep, checked out to customer.\n";
				updateCurrentUser( $itemId );
			}
			else
			{
				print STDERR "Nope not checked, or checked out to a system card.\n";
				updatePreviousUser( $itemId );
			}
			# If the item isn't checked out at all to anyone, then check out to avsnag card 
			# so item doesn't show up on PULL hold reports, when we place a copy hold for it.
			if ( ! isCheckedOut( $itemId ) )
			{
				print STDERR "checking item out to an AVSNAG card for the current branch.\n";
				checkOutItemToAVSnag( $itemId );
			}
			# Place the item on hold for the av snag card at the correct branch.
			print STDERR "placing hold for $itemId.\n";
			placeHoldForItem( $itemId );
		}
		exit;
	} # End of '-u' switch handling.
	# Update database from AVSNAG profile cards, inserts new records or ignores if it's already there.
	if ( $opt{'U'} )
	{
		# Find all the AV Snag cards in the system, then iterate over them to find all the items charged.
		my $selectSnagCards = `ssh sirsi\@eplapp.library.ualberta.ca 'seluser -p"EPL-AVSNAG" -oUB'`;
		# Looks like: '604887|WMC-AVINCOMPLETE|'
		my @data = split '\n', $selectSnagCards;
		while (@data)
		{
			my $userKeyUserId = shift @data;
			################################
			# Uncomment the next line if you want to test just a single branch.
			# next if ( $userKeyUserId !~ m/WMC-AVINCOMPLETE/ ); ############ Testing only remove .
			################################
			# Sometimes a human customer account gets set to AVSNAG accidentally so lets skip it if it is.
			next if ( ! isValidSystemCard( $userKeyUserId ) );
			# Later we must include the library code whenever we insert a new item so get it now.
			my $libCode = getLibraryCode( $userKeyUserId );
			# Now find all the charges for this card. The output looks like this: '31221104409748  |'
			my $selectCardCharges = `echo "$userKeyUserId" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selcharge -iU -oIS | selitem -iI -oB'`;
			my @itemList = split '\n', $selectCardCharges;
			while ( @itemList )
			{
				# For all the items that staff entered, let's find the current location.
				my $itemId = shift @itemList;
				# clean the item id of spaces and trailing pipe.
				$itemId =~ s/(\s+|\|)//g;
				# speed things up a bit if we ignore the ones we have already processed.
				next if ( alreadyInDatabase( $itemId ) );
				# Now we will make an entry for the item im the database, then populate it with title and user data.
				my $apiUpdate = $itemId . '|(Item process in progress...)|0|0|Unavailable|0|none|';
				insertNewItem( $apiUpdate, $libCode );
				print STDERR "inserted: $itemId\n";
				# We can update the title information.
				updateTitle( $itemId );
				# We already know that this is a system card so let's get the previous user.
				updatePreviousUser( $itemId );
				# Try to Place hold for the av snag card if there isn't one already.
				placeHoldForItem( $itemId );
			} # end while
		} # end of while system card iteration.
		exit; # End of '-U' switch handling.
	} 
	# Create table of system cards for holds and checkouts.
	if ( $opt{'c'} ) 
	{
		my $apiResults = `ssh sirsi\@eplapp.library.ualberta.ca 'seluser -p"EPL-AVSNAG" -oUB'`;
		# which produces:
		# ...
		# 836641|DLI-SNAGS|
		# 1081444|MNA-AVINCOMPLETE|
		# 1096665|21221022952235|
		# ...
		$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
			PrintError       => 0,
			RaiseError       => 1,
			AutoCommit       => 1,
			FetchHashKeyName => 'NAME_lc',
		});
		my @data = split '\n', $apiResults;
		while (@data)
		{
			my $line = shift @data;
			my ( $userKey, $userId ) = split( '\|', $line );
			# get rid of the extra white space on the line
			$userId = trim( $userId );
			# if this user id doesn't match your library's library card format (in our case codabar)
			# ignore it. It is probably a system card.
			next if ( $userId =~ m/\d{13,}/ );
			# This is brittle, but it seems that most cards are named by branch as the first 3 characters.
			# If that holds lets get them now.
			my $branch = substr( $userId, 0, 3 );
			$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avsnagcards (UserKey, UserId, Branch) VALUES (?, ?, ?)
END_SQL
			$DBH->do( $SQL, undef, $userKey, $userId, $branch );
			# Now try an update user keys that are already in there but out of date (Name changed).
			$SQL = <<"END_SQL";
UPDATE avsnagcards SET UserId=?, Branch=? 
WHERE UserKey=?
END_SQL
			$DBH->do($SQL, undef, $userKey, $userId, $branch );
		}
		$DBH->disconnect();
	} # end of if '-c' processing.
	# Create table of system cards for discards.
	if ( $opt{'d'} ) 
	{
		my $apiResults = `ssh sirsi\@eplapp.library.ualberta.ca 'seluser -p"DISCARD" -oUB'`;
		# which produces:
		# ...
		# 1123293|CLV-DISCARD-NOV|
		# 1123294|CLV-DISCARD-DEC|
		# 1126170|WMC-DISCARD-DEC2|
		# 1133749|21221023754002|
		# ...
		$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
			PrintError       => 0,
			RaiseError       => 1,
			AutoCommit       => 1,
			FetchHashKeyName => 'NAME_lc',
		});
		my @data = split '\n', $apiResults;
		while (@data)
		{
			my $line = shift @data;
			my ( $userKey, $userId ) = split( '\|', $line );
			# get rid of the extra white space on the line
			$userId = trim( $userId );
			# if this user id doesn't match your library's library card format (in our case codabar)
			# ignore it. It is probably a system card.
			next if ( $userId =~ m/\d{4,}/ );
			# This is brittle, but it seems that most cards are named by branch as the first 3 characters.
			# If that holds lets get them now.
			my $branch = substr( $userId, 0, 3 );
			$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avdiscardcards (UserKey, UserId, Branch) VALUES (?, ?, ?)
END_SQL
			$DBH->do( $SQL, undef, $userKey, $userId, $branch );
			# Now try an update user keys that are already in there but out of date (Name changed).
			$SQL = <<"END_SQL";
UPDATE avdiscardcards SET UserId=?, Branch=? 
WHERE UserKey=?
END_SQL
			$DBH->do($SQL, undef, $userKey, $userId, $branch );
		}
		$DBH->disconnect();
	} # end of -d processing (discard cards for a branch.
	# Notify customers about the missing parts of materials they borrowed.
	if ( $opt{'n'} )
	{
		my $customerFile = "customers.lst";
		`echo 'SELECT UserId, Title, Comments FROM avincomplete WHERE Comments NOT NULL AND Notified=0 AND UserId NOT NULL;' | sqlite3 $DB_FILE >$customerFile`;
		# produces: 
		# 21221023803338|The foolish tortoise [sound recording] / written by Richard Buckley ; [illustrated by] Eric Carle|disc is missing
		# 21221021920217|Yaiba. Ninja gaiden Z [game] / [developed by Comcept, Spark Unlimited]. --|disc is missing
		# 21221021499063|Glee. The final season [videorecording]|disc 1 is missing
		# copy list to EPLAPP.
		if ( -s $customerFile )
		{
			# Copy the file over to the production machine ready for the next run of mailerbot.
			my $destDir = "/s/sirsi/Unicorn/EPLwork/cronjobscripts/Mailerbot/AVIncomplete/";
			`scp $customerFile sirsi\@eplapp.library.ualberta.ca:$destDir`;
			print STDERR "file $customerFile copied to application server\n";
			# Set notified date on entry.
			`echo 'UPDATE avincomplete SET Notified=1, NoticeDate="$DATE" WHERE Comments NOT NULL AND Notified=0 AND UserId NOT NULL;' | sqlite3 $DB_FILE`;
			print STDERR "notification flag set in database.\n";
		}
		else
		{
			print STDERR "didn't find any new customers to contact. Did staff mark the missing parts on new items?\n";
		}
		# TODO: logic in app should reset the Notified flag to 0 if there is a change to the comments field.
	}
}

init();

# EOF