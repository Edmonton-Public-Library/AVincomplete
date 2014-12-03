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

	usage: $0 [-Cdfx] [-D<foo.bar>]
Creates and manages av incomplete sqlite3 database.

 -C: Create new database called '$DB_FILE'. If the db exists '-f' must be used.
 -d: Debug.
 -D<file>: Dump hold table to HTML file <file>.
 -f: Force create new database called '$DB_FILE'. **WIPES OUT EXISTING DB**
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
    my $opt_string = 'CdD:fx';
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
	Date DATE,
	Complete INTEGER,
	Branch CHAR(3) NOT NULL,
	UserKey INTEGER,
	HomeBranch CHAR(3),
	CallNum CHAR(20),
	Contacted DATE,
	Comments CHAR(100)
	);
END_SQL
		$DBH->do($SQL);
		$DBH->disconnect;
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
	my $line = shift;
	
	my ($holdKey, $title, $date, $userKey, $userId, $userProfile) = split '\|', $line;
	$SQL = <<"END_SQL";
INSERT OR REPLACE INTO holds 
(ItemId, Date, Complete, Branch, UserKey, HomeBranch, CallNum, Contacted, Comments) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
END_SQL
	$DBH->do($SQL, undef, $holdKey, $title, $date, $userKey, $userId, $userProfile);
	return;
}

# grab all the NCIP log data since we don't know when the logs are rotated from log => log1, it's done by file size (10000 kB).
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