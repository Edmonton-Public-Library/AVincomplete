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
my $VERSION  = qq{0.1};

#
# Message about this program and how to use it.
#
sub usage()
{
    print STDERR << "EOF";

	usage: $0 [-Cdfx] [-D<foo.bar>] [-u<user_key>]
Creates and manages av incomplete sqlite3 database.

 -C:           Create new database called '$DB_FILE'. If the db exists '-f' must be used.
 -d:           Debug.
 -D<file>:     Dump hold table to HTML file <file>.
 -f:           Force create new database called '$DB_FILE'. **WIPES OUT EXISTING DB**
 -u<user_key>: Gets basic information about the last user for contact purposes 
               including the user's barcode, profile, name, email address, and phone.
 -x:           This (help) message.

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
    my $opt_string = 'CdD:fu:x';
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
	Contact INTEGER DEFAULT 0,
	ContactDate DATE DEFAULT NULL,
	Complete INTEGER DEFAULT 0,
	CompleteDate DATE DEFAULT NULL,
	Discard  INTEGER DEFAULT 0,
	DiscardDate DATE DEFAULT NULL,
	Location CHAR(6) NOT NULL,
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
		# print HTML `echo "SELECT user_id, user_profile, title, date FROM holds;" | sqlite3 -html $DB_FILE`;
		close HTML;
		exit;
	}
	if ( $opt{'u'} ) 
	{
		my $userKey = $opt{'u'};
		# This line takes a user key and gets the user's barcode, profile, name, email address, and phone.
		# my $results = `echo $userKey | ssh sirsi\@eplapp.library.ualberta.ca 'cat - | seluser -iU -oBpDX.9007.X.9009.'`;
		print STDOUT "Hello PHP!";
		exit 3;
	}
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
sub insert( $ )
{
# From discardweb...
# my ( $id, $checkoutDate, $iType, $callNum, $tcn, $titleAuthor, $pubDate, $pub, $holds ) = @_;
	# $SQL = << "END_SQL";
# INSERT OR IGNORE INTO last_copy 
# (ItemID, DateCharged, ItemType, HoldCount, CallNum, TitleControlNumber, TitleAuthor, PublicationDate, Publication) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
# END_SQL
	# $DBH->do($SQL, undef, $id, $checkoutDate, $iType, $holds, $callNum, $tcn, $titleAuthor, $pubDate, $pub);
	If you inserted then this just updates, but if insert failed because it exists, then this will run.
	# $SQL = <<"END_SQL";
# UPDATE last_copy SET DateCharged=?, ItemType=?, HoldCount=?, CallNum=?, TitleControlNumber=?, TitleAuthor=?, PublicationDate=?, Publication=? 
# WHERE ItemID=?
# END_SQL
	# $DBH->do($SQL, undef, $checkoutDate, $iType, $holds, $callNum, $tcn, $titleAuthor, $pubDate, $pub, $id);
	# return;



	my $line = shift;
	my ($ItemId, $Title, $CreateDate, $UserKey, $Contact, $ContactDate, $Complete, $CompleteDate, $Discard, $DiscardDate, $Location, $Comments) = @_;
	$SQL = <<"END_SQL";
INSERT OR REPLACE INTO holds 
(ItemId, Title, CreateDate, UserKey, Contact, ContactDate, Complete, CompleteDate, Discard, DiscardDate, Location, Comments) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
END_SQL
	$DBH->do($SQL, undef, $ItemId, $Title, $CreateDate, $UserKey, $Contact, $ContactDate, $Complete, $CompleteDate, $Discard, $DiscardDate, $Location, $Comments);
	return;
}

# grab all the Data from the ILS.
my $API_OUT = `ssh sirsi\@eplapp.library.ualberta.ca 'perl /s/sirsi/Unicorn/Bincustom/ncipstats.pl -a | seluser -iB -oSUBp'`;
my @data = split '\n', $API_OUT;
while (@data)
{
	my $line = shift @data;
	print "$line\n" if ( $opt{'d'} );
	insert( $line );
}

$DBH->disconnect;

# EOF