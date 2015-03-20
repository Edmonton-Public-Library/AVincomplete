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
#    Copyright (C) 2013  Andrew Nisbet
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
# Created: Tue Apr 16 13:38:56 MDT 2013
# Rev: 
#          0.0 - Dev. 
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

my $VERSION  = qq{0.1};

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

 -c: Create new table of EPL-AVSNAG cards. These are the cards used to checkout 
     materials and place holds.
 -C: Create new database called '$DB_FILE'. If the db exists '-f' must be used.
 -d: Debug.
 -D<file>: Dump hold table to HTML file <file>.
 -f: Force create new database called '$DB_FILE'. **WIPES OUT EXISTING DB**
 -u: Updates database based on items entered into the database by the website
 -U: Updates database based on items on cards with $AVSNAG profile.
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
		my($itemId, $location, $title, $userKey, $userId, $name, $phone, $email) = split( '\|', $line );
		if ( defined $itemId and defined $location )
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
			$location = trim( $location );
			# This is brittle, but it seems that most cards are named by branch as the first 3 characters.
			# If that holds lets get them now.
			$location = substr( $location, 0, 3 );
			print STDERR "adding item '$itemId' from branch '$location'\n";

			# 31221106301570  |CLV-AVINCOMPLETE|Call of duty|82765|21221020238199|Sutherland, Buster Brown|780-299-0755||
			# print "$itemId, '$location', '$title', $userKey, $userId, '$name', '$phone', '$email'\n";
			$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avincomplete 
(ItemId, Location, Title, UserKey, UserId, UserName, UserPhone, UserEmail, Processed, ProcessDate) 
VALUES 
(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
END_SQL
			$DBH->do($SQL, undef, $itemId, $location, $title, $userKey, $userId, $name, $phone, $email, 1, $DATE);
		}
		else
		{
			print STDERR "rejecting item '$itemId' branch '$location'\n";
		}
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
	# 
	if ( $opt{'u'} )
	{
		my $apiResults = `echo 'SELECT ItemId FROM avincomplete WHERE Processed=0;' | sqlite3 $DB_FILE`;
		my @data = split '\n', $apiResults;
		while (@data)
		{
			my $barCode = shift @data;
			print `echo "$barCode|" | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | selitem -iB -oCBm'`;
			# 875883|31221098551174  |HOLDS|
			# **error number 111 on item start, cat=0 seq=0 copy=0 id=31221099948528
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
			if ( $userId =~ m/\d{13,}/ )
			{
				next;
			}
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
	}
}

init();

# EOF