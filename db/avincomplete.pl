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
#               createholds.pl, chargeitems.pl.
# Created: Tue Apr 16 13:38:56 MDT 2013
# Rev: 
#          0.2 - Fix to -u titles not updating, items in database not checked
#                off customers' card. 
#          0.1 - Dev. 
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

my $VERSION  = qq{0.2};

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

	usage: $0 [-CdfuUx] [-D<foo.bar>]
Creates and manages av incomplete sqlite3 database.
Note: -c and -d flags rebuild the avsnag cards and discard cards for a branch based on 
profiles. The branch id must appear as the first 3 letters of its name like: SPW-AVSNAG, or
RIV-DISCARD, for a discard card.

 -c: Refreshes the avsnagcards table of EPL-AVSNAG cards. These are the cards used to checkout 
     materials and place holds. Can safely be run regularly. AV incomplete cards themselves
     don't change all that often, but if a new one is added this should be run. See '-d'
     for discard cards.
 -C: Create new database called '$DB_FILE'. If the db exists '-f' must be used.
 -d: Refreshes the avdiscardcards table of DISCARD cards. Can safely be run regularly especially
     if a new branch discard card is added. See '-c' for avsnag cards.
 -D<file>: Dump hold table to HTML file <file>.
 -f: Force create new database called '$DB_FILE'. **WIPES OUT EXISTING DB**
 -u: Updates database based on items entered into the database by the website.
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
        # Comments CHAR(256)
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
#         '31221102616518  |CLV-AVINCOMPLETE|Pride and prejudice|535652|21221021851248|Smith, Merlin|780-244-5655|xxxxxxxx@hotmail.com|'
# return: none.
sub insertNewItems( $ )
{
	$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
		PrintError       => 0,
		RaiseError       => 1,
		AutoCommit       => 1,
		FetchHashKeyName => 'NAME_lc',
	});
	# Now start importing data.
	my @data = split '\n', shift;
	while (@data)
	{
		my $line = shift @data;
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
			
			# 31221106301570  |Call of duty|82765|21221020238199|Sutherland, Buster Brown|780-299-0755||
			# print "$itemId, '$title', $userKey, $userId, '$name', '$phone', '$email'\n";
			$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avincomplete 
(ItemId, Title, UserKey, UserId, UserName, UserPhone, UserEmail, Processed, ProcessDate) 
VALUES 
(?, ?, ?, ?, ?, ?, ?, ?, ?)
END_SQL
			$DBH->do($SQL, undef, $itemId, $title, $userKey, $userId, $name, $phone, $email, 1, $DATE);
		}
		else
		{
			print STDERR "rejecting item '$itemId'\n";
		}
	}
	$DBH->disconnect;
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
	Comments CHAR(256)
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
	# Get the branch's snag card.
	my $branchCard = `echo "select UserId from avsnagcards where Branch = (select Location from avincomplete where ItemId=$itemId);" | sqlite3 $DB_FILE`;
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
# param:  Item ID 
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


# Kicks off the setting of various switches.
# param:  
# return: 
sub init
{
    my $opt_string = 'cCdD:fuUx';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ( $opt{'x'} );
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
	if ( $opt{'D'} ) 
	{
		my $dumpFile = $opt{'D'};
		open HTML, ">$dumpFile" or die "**error: unable to write to file '$dumpFile', $!\n";
		print HTML `echo "SELECT * FROM avincomplete;" | sqlite3 -html $DB_FILE`;
		close HTML;
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
			# Place the item on hold for the av snag card at the correct branch.
			placeHoldForItem( $itemId );
		}
		exit;
	} # End of '-u' switch handling.
	# Update database from AVSNAG profile cards, inserts new records or ignores if it's already there.
	if ( $opt{'U'} )
	{
		# seluser -p"EPL-AVSNAG" -oUB | selcharge -iU -oIS # Finds all charges by card and outputs item id and AVSNAG barcode
		# selitem -iI -oCsBS # Takes item id and outputs cat key previous user (PU) key and item's barcode.
		# selcatalog -iC -oSt # Takes the cat key and outputs everything so far and the title.
		# seluser -iU -oSUBDX.9026.X.9007. # Gets the user's key which is first on the output from above and looks up contact info PHONE and EMAIL. 
		my $apiResults = `ssh sirsi\@eplapp.library.ualberta.ca 'seluser -p"EPL-AVSNAG" -oUB | selcharge -iU -oIS | selitem -iI -oCsBS | selcatalog -iC -oSt | seluser -iU -oSUBDX.9026.X.9007.'`;
		# produces output like:
		# -- snip --
		# 31221106301570  |CLV-AVINCOMPLETE|Call of duty|82765|21221020238199|Sutherland, Buster Brown|780-299-0755||
		# 31221102616518  |CLV-AVINCOMPLETE|Pride and prejudice [videorecording]|535652|21221021851248|Smith, Merlin|780-244-5655|xxxxxxxx@hotmail.com|
		# 31221106335685  |CLV-AVINCOMPLETE|Up all night |1123298|CLV-AVINCOMPLETE|CLV-AV Incomplete|||
		# 31221107371440  |CLV-AVINCOMPLETE|Ske-dat-de-dat|582982|ABB-AVINCOMPLETE|ABB-AV Incomplete|||
		# -- snip --
		insertNewItems( $apiResults );
		# Since all these items came from the AVSNAGs cards across the library they don't need to charged or discharged.
		# We still want to place a hold for the item if it gets trapped by a sorter or smart chute.
		# placeHoldsOnItems( $apiResults );
		exit;
	} # End of '-U' switch handling.
	if ( $opt{'c'} ) # Create table of system cards for holds and checkouts.
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
	if ( $opt{'d'} ) # Create table of system cards for discards.
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
}

init();

# EOF