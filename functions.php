<?php
ini_set('error_reporting', E_ALL);
require 'db.inc';
####################################################################################
#
# Name: functions.php
# Purpose: helper functions for managing key operations on the database.
#
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
# Created: Tue Apr 16 13:38:56 MDT 2013
# Rev: 
#          0.1 - Added action 'transit' to functional check. 
#          0.0 - Dev. 
#
####################################################################################

###
# Gets the information of the customer that last checked out this item.
# param:  $db - database object.
# param:  $item - the item id of the item to be created.
# return: string of the customer's contact information.
function get_customer_info(&$db, $item)
{
	// sqlite> .schema
	// TABLE avincomplete (
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
	// http://stackoverflow.com/questions/3319112/sqlite-read-only-database
	$sql = "SELECT UserId, UserName, UserPhone, Title, UserEmail, Comments FROM avincomplete WHERE ItemId=$item;";
	$ret = $db->query($sql);
	$output = '';
	while ($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
		$output = 'User ID: '. $row['UserId'].'<br/>name: '.$row['UserName'].
		'<br/>phone: '.$row['UserPhone'].'<br/>email: <a href="mailto:'.$row['UserEmail'].'?Subject=Item borrowed from EPL: '.$row['Title'].'." target="_top">'.$row['UserEmail'].'</a><br/>Incomplete: '.$row['Comments'];
	}
	$db->close();
	return $output;
}

###
# Marks an item as complete. This is only to be done if you have received an item that makes 
# an AV incomplete item complete, that is, if you have a DVD case and you receive the matching
# (or near matching) disk from somewhere, and putting the two items together make the item 
# circulate-able, then it can be marked complete.
# param:  $db - database object.
# param:  $item - the item id of the item to be created.
# return: true if it worked and false otherwise.
function mark_item_complete(&$db, $item)
{
	// sqlite> .schema
	// TABLE avincomplete (
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
	$sql = <<<EOF_SQL
UPDATE avincomplete SET Complete=1, CompleteDate=strftime('%Y-%m-%d', DATETIME('now')) WHERE ItemId=:id
EOF_SQL;
	$stmt = $db->prepare($sql);
	$stmt->bindValue(':id', $item, SQLITE3_INTEGER);
	$result = $stmt->execute();
	$db->close();
	return true;
}

###
# Marks an item for discard.
# param:  $db - database object.
# param:  $item - the item id of the item to be created.
# return: 
function mark_item_discard(&$db, $item)
{
	// sqlite> .schema
	// TABLE avincomplete (
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
	$sql = <<<EOF_SQL
UPDATE avincomplete SET Discard=1, DiscardDate=strftime('%Y-%m-%d', DATETIME('now')) WHERE ItemId=:id
EOF_SQL;
	$stmt = $db->prepare($sql);
	$stmt->bindValue(':id', $item, SQLITE3_INTEGER);
	$stmt->execute();
	$db->close();
	return true;
}

###
# Marks an item for discard.
# param:  $db - database object.
# param:  $location - The destination of the item being transitted.
# param:  $item - the item id of the item to be created.
# return: 
function mark_item_transit(&$db, $location, $item)
{
	// sqlite> .schema
	// TABLE avincomplete (
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
	$sql = <<<EOF_SQL
UPDATE avincomplete SET TransitLocation=:location, TransitDate=strftime('%Y-%m-%d', DATETIME('now')) WHERE ItemId=:id
EOF_SQL;
	$stmt = $db->prepare($sql);
	$stmt->bindValue(':location', $location, SQLITE3_TEXT);
	$stmt->bindValue(':id', $item, SQLITE3_INTEGER);
	$stmt->execute();
	$db->close();
	return true;
}

###
# Sets a flag on the item that the customer has been contacted.
# param:  $db - database object.
# param:  $item - the item id of the item to be created.
# return: 
function mark_customer_contacted(&$db, $item)
{
	// sqlite> .schema
	// TABLE avincomplete (
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
	$sql = <<<EOF_SQL
UPDATE avincomplete SET Contact=1, ContactDate=strftime('%Y-%m-%d', DATETIME('now')) WHERE ItemId=:id
EOF_SQL;
	$stmt = $db->prepare($sql);
	$stmt->bindValue(':id', $item, SQLITE3_INTEGER);
	$result = $stmt->execute();
	$db->close();
	return true;
}

###
# Creates a new item for the database. Talks to the ILS to get some salient information.
# Backup to save to file then operate on it with some other script.
# param:  $db - database object.
# param:  $item - the item id of the item to be created.
# param:  $branch - branch that currently has the first item. We DO NOT want to shuffle stuff
#         around the library to match it up. The branch that finds the first piece of an AV incomplete
#         is the owning library.
# return: true if it worked and false otherwise.
function create_new_item(&$db, $item, $branch, $comments)
{
	$title = "(title will be updated shortly)";
	// sqlite> .schema
	// TABLE avincomplete (
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
	$sql = <<<EOF_SQL
INSERT OR IGNORE INTO avincomplete (ItemId, Title, CreateDate, Location, Comments) VALUES (:id, :title, strftime('%Y-%m-%d', DATETIME('now')), :branch, :comments);
EOF_SQL;
	$stmt = $db->prepare($sql);
	$stmt->bindValue(':id', $item, SQLITE3_INTEGER);
	$stmt->bindValue(':title', $title, SQLITE3_TEXT);
	$stmt->bindValue(':branch', $branch, SQLITE3_TEXT);
	$stmt->bindValue(':comments', $comments, SQLITE3_TEXT);
	$result = $stmt->execute();
	$sql = <<<EOF_SQL
UPDATE avincomplete SET Title=:title, CreateDate=strftime('%Y-%m-%d', DATETIME('now')), Location=:branch, Comments=:comments WHERE ItemId=:id;
EOF_SQL;
	$stmt = $db->prepare($sql);
	$stmt->bindValue(':id', $item, SQLITE3_INTEGER);
	$stmt->bindValue(':title', $title, SQLITE3_TEXT);
	$stmt->bindValue(':branch', $branch, SQLITE3_TEXT);
	$stmt->bindValue(':comments', $comments, SQLITE3_TEXT);
	$result = $stmt->execute();
	$db->close();
	return true;
}

###
# Adds a comment to an item.
# 
# param:  $db - database object.
# param:  $item - the item id of the item to be created.
# param:  $branch - branch that currently has the first item. We DO NOT want to shuffle stuff
#         around the library to match it up. The branch that finds the first piece of an AV incomplete
#         is the owning library.
# param:  $comment - the string to add to the database.
# return: true if it worked and false otherwise.
function add_comments(&$db, $item, $branch, $comment){
	// if (strlen($comment) > 255){
		// return false;
	// }
	// sqlite> .schema
	// TABLE avincomplete (
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
	$sql = <<<EOF_SQL
UPDATE avincomplete SET Comments=:comment WHERE ItemId=:id
EOF_SQL;
	$stmt = $db->prepare($sql);
	$stmt->bindValue(':comment', $comment, SQLITE3_TEXT);
	$stmt->bindValue(':id', $item, SQLITE3_INTEGER);
	$result = $stmt->execute();
	$db->close();
	return true;
}

###
# Entry point for all GET requests to this page.
# mark item complete: action=complete&item_id=$item&branch=$branch
# create new item:    action=create&item_id=$item&branch=$branch
if (! empty($_GET)) {
 	if (! empty($_GET['action'])){
		# Putting this here makes for brittle code, that is this type of checking
		# requires that all calls to this page require an action, item_id and branch.
		if (empty($_GET['item_id']) || empty($_GET['branch'])){
			$msg = "Either Item id or branch not specified in call to functions.php#" . $_GET['action'];
			header("Location:error.php?msg=$msg");
		}
		$item   = $_GET['item_id'];
		$branch = $_GET['branch'];
		if ($_GET['action'] === 'complete'){ # Mark an item complete in database.
			if (mark_item_complete($db, $item)){
				echo "Item <kbd>$item</kbd> marked as complete, well done.";
			} else {
				$msg = "Function '" . $_GET['action'] . "' failed in functions.php.";
				header("Location:error.php?msg=$msg");
			}
		} elseif ($_GET['action'] === 'comments'){ # Comment on an item in database.
			if (! empty($_GET['data'])){
				$commentData = $_GET['data'];
				add_comments($db, $item, $branch, $commentData);
				$db->close(); # Manually close because create needs to use it twice.
			} else {
				$msg = "Function '" . $_GET['action'] . "' failed in functions.php expected comment data but got none.";
				header("Location:error.php?msg=$msg");
			}
		} elseif ($_GET['action'] === 'create'){ # Create a new entry (or register) item in database.
			# Check if comments have been passed. The old version of the site doesn't 
			# but the new can if staff use checkboxes in search_create_item.php.
			$commentData = '';
			if (! empty($_GET['data'])){
				$commentData = html_entity_decode($_GET['data']);
			}
			if (create_new_item($db, $item, $branch, $commentData)){
				echo "Item <kbd>$item</kbd> registered as incomplete.";
			} else {
				echo "Function '" . $_GET['action'] . "' failed in functions.php.";
			}
		} elseif ($_GET['action'] === 'contact'){ # Contacted customer flag set on item in database.
			if (mark_customer_contacted($db, $item)){
				echo "Contacted customer flag set on item <kbd>$item</kbd>.";
			} else {
				$msg = "Function '" . $_GET['action'] . "' failed in functions.php.";
				header("Location:error.php?msg=$msg");
			}
		} elseif ($_GET['action'] === 'discard'){ # Discard item flag set on item in database.
			if (mark_item_discard($db, $item)){
				echo "Item <kbd>$item</kbd> set to be discarded.";
			} else {
				$msg = "Function '" . $_GET['action'] . "' failed in functions.php.";
				header("Location:error.php?msg=$msg");
			}
		} elseif ($_GET['action'] === 'transit'){ # transit item flag set on item in database.
			if (mark_item_transit($db, $branch, $item)){
				echo "Place label on <kbd>$item</kbd> and put it in the appropriate red bin.";
			} else {
				$msg = "Function '" . $_GET['action'] . "' failed in functions.php.";
				header("Location:error.php?msg=$msg");
			}
		} elseif ($_GET['action'] === 'info'){ # get customer information.
			$msg = get_customer_info($db, $item);
			if (strlen($msg) > 0){
				echo $msg;
			} else {
				$msg = "Function '" . $_GET['action'] . "' failed in functions.php.";
				header("Location:error.php?msg=$msg");
			}
		} else { # Huh?, don't know how to do that.
			$msg = "Function '" . $_GET['action'] . "' not implemented in functions.php.";
			header("Location:error.php?msg=$msg");
		}
	}
} else {
	$msg = "Dude, your get request at functions.php, has, like no parameters man.";
	header("Location:error.php?msg=$msg");
}
?>