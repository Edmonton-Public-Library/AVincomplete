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

# Kicks off the setting of various switches.
# param:  
# return: 
sub init
{
    my $opt_string = 'CdD:fuUx';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ( $opt{'x'} );
	# Create new sqlite database.
	if ( $opt{'C'} ) 
	{
		if ( -e $DB_FILE and ! $opt{'f'} )
		{
			print STDERR "**error: db '$DB_FILE' exists. If you want to overwrite use '-f' flag.\n";
			exit;
		}
		else
		{
			unlink $DB_FILE;
		}
		$DBH      = DBI->connect($DSN, $USER, $PASSWORD, {
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
		# Set permissions so the eventual owner (www-data) and ilsdev account
		# can cron maintenance.
		my $mode = 0664;
		chmod $mode, $DB_FILE;
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
		my $results = `echo 'SELECT ItemId FROM avincomplete WHERE Processed=0;' | sqlite3 $DB_FILE`;
		my @data = split '\n', $results;
		while (@data)
		{
			# There will be a bar code here if successful. We need to get 
		}
		exit;
	} # End of '-u' switch handling.
	# Update database from AVSNAG profile cards, inserts new records or ignores if it's already there.
	if ( $opt{'U'} )
	{
		$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
			PrintError       => 0,
			RaiseError       => 1,
			AutoCommit       => 1,
			FetchHashKeyName => 'NAME_lc',
		});
		# my $API_OUT = `ssh sirsi\@eplapp.library.ualberta.ca 'seluser -p"EPL-AVSNAG" -oUB | selcharge -iU -oIS | selitem -iI -oBSs'`;
		# seluser -p"EPL-AVSNAG" -oUB | selcharge -iU -oIS # Finds all charges by card and outputs item id and AVSNAG barcode
		# selitem -iI -oCsBS # Takes item id and outputs cat key previous user (PU) key and item's barcode.
		# selcatalog -iC -oSt # Takes the cat key and outputs everything so far and the title.
		# seluser -iU -oSUBDX.9005.X.9007. # Gets the user's key which is first on the output from above and looks up contact info PHONE and EMAIL. 
		my $API_OUT = `ssh sirsi\@eplapp.library.ualberta.ca 'seluser -p"EPL-AVSNAG" -oUB | selcharge -iU -oIS | selitem -iI -oCsBS | selcatalog -iC -oSV | seluser -iU -oSUBDX.9026.X.9007.'`;
		# produces output like:
		# -- snip --
		# 31221106301570  |CLV-AVINCOMPLETE|Call of duty|82765|21221020238199|Sutherland, Buster Brown|780-299-0755||
		# 31221102616518  |CLV-AVINCOMPLETE|Pride and prejudice [videorecording]|535652|21221021851248|Smith, Merlin|780-244-5655|xxxxxxxx@hotmail.com|
		# 31221106335685  |CLV-AVINCOMPLETE|Up all night |1123298|CLV-AVINCOMPLETE|CLV-AV Incomplete|||
		# 31221107371440  |CLV-AVINCOMPLETE|Ske-dat-de-dat|582982|ABB-AVINCOMPLETE|ABB-AV Incomplete|||
		# -- snip --
		# We can put that into the local database then '-u' can be used to fill in details on items.
		my @data = split '\n', $API_OUT;
		while (@data)
		{
			my $line = shift @data;
			my($itemId, $location, $title, $userKey, $userId, $name, $phone, $email) = split( '\|', $line );
			if ( defined $itemId and defined $location )
			{
				$itemId     = trim( $itemId );
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
		exit;
	} # End of '-U' switch handling.
}

init();

$DBH = DBI->connect($DSN, $USER, $PASSWORD, {
   PrintError       => 0,
   RaiseError       => 1,
   AutoCommit       => 1,
   FetchHashKeyName => 'NAME_lc',
});

# Inserts a line of data into the ncip database.
# param:  Line taken from ncip logs.
# return: <none>
sub insert
{
# From discardweb...
# my ( $id, $checkoutDate, $iType, $callNum, $tcn, $titleAuthor, $pubDate, $pub, $holds ) = @_;
	# $SQL = << "END_SQL";
# INSERT OR IGNORE INTO last_copy 
# (ItemID, DateCharged, ItemType, HoldCount, CallNum, TitleControlNumber, TitleAuthor, PublicationDate, Publication) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
# END_SQL
	# $DBH->do($SQL, undef, $id, $checkoutDate, $iType, $holds, $callNum, $tcn, $titleAuthor, $pubDate, $pub);
	## If you inserted then this just updates, but if insert failed because it exists, then this will run.
	# $SQL = <<"END_SQL";
# UPDATE last_copy SET DateCharged=?, ItemType=?, HoldCount=?, CallNum=?, TitleControlNumber=?, TitleAuthor=?, PublicationDate=?, Publication=? 
# WHERE ItemID=?
# END_SQL
	# $DBH->do($SQL, undef, $checkoutDate, $iType, $holds, $callNum, $tcn, $titleAuthor, $pubDate, $pub, $id);
	# return;


	my ($ItemId, $Title) = @_;
	$SQL = <<"END_SQL";
INSERT OR IGNORE INTO avincomplete 
(
ItemId, Title
) 
VALUES 
(
?, ?
)
END_SQL
	$DBH->do($SQL, undef, 
	$ItemId, $Title
);
	return;
}

# grab all the Data from the ILS.
# This could initially fill the table, we grab all the items from AVSNAG cards.
# When staff click add a new item will appear in table, those will be collected at the end of the day and 
# the empty fields filled out to include information from the ILS. If the item is not found in the ILS, the
# entry will be removed from the (local) avincomplete table.
# Additionally the script will have to go and recheck the ILS nightly to find new items to insert into the database.
# We shall use the algorithm of INSERT IGNORE ON DUPLICATE and then do an update to the record.
#
# === Details ===
# Behind the scenes the script will grab all the items that are unprocessed.
# * select * from avincomplete where processed = 0
# * process this list:
#    check if the item is charged:
#    YES: 
#      is AVSNAG?
#       YES: record previous customer.
#       NO: record current customer, discharge item from customer and charge to branch's AVSNAG card (See chargeitem.pl). 
#           Place copy level hold on item for branch's AVSNAG card (See createhold.pl).
#     NO: record previous customer charge to branch's AVSNAG card (See chargeitem.pl). 
#         Place copy level hold on item for branch's AVSNAG card (See createhold.pl).
# * insert data into database
# ** Title, checked out, previous user key, current user key, user id, Name, phone, email. 

my $API_OUT = `ssh sirsi\@eplapp.library.ualberta.ca ' | seluser -iB -oSUBp'`;
my @data = split '\n', $API_OUT;
while (@data)
{
	my $line = shift @data;
	print "$line\n" if ( $opt{'d'} );
	insert( $line );
}

$DBH->disconnect;

# EOF