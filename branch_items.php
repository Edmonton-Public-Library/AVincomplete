<!DOCTYPE html>
<html lang="en">
<head>
  <title><?php if (! empty($_GET['branch'])){ echo $_GET['branch']; } ?> AV Incomplete</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
</head>
<body>
<div class="container">
  <div class="jumbotron">
	<h1>AV Incomplete</h1>
	<p>''A fuller expression of Self comes from the journey for greater wholeness.'' - Kathryn V. White</p>
  </div>
  <p>Incomplete items at <?php if (empty($_GET['branch'])){ echo '??'; } else { echo $_GET['branch']; } ?></p>

<!-- 
<form action='index.php'>
<input type='submit' value='back'>
</form>
-->
	<div id='original' class='table'>
		<div class='header sticky row'>
			<div class='col-sm-2 cell list-group-item active'>Bar Code&nbsp;<a id='item_id' href='#' title='sort'><img src='images/sort.gif' /></a></div>
			<div class='col-sm-2 cell list-group-item active'>Title&nbsp;<a id='title' href='#' title='sort'><img src='images/sort.gif' /></a></div>
			<div class='col-sm-1 cell list-group-item active'>Location</div>
			<div class='col-sm-2 cell list-group-item active'>Date&nbsp;<a id='date' href='#' title='sort'><img src='images/sort.gif' /></a></div>
			<div class='col-sm-1 cell list-group-item active'>Discard</div>
			<div class='col-sm-1 cell list-group-item active'>Complete</div>
			<div class='col-sm-1 cell list-group-item active'>Contact</div>
			<div class='col-sm-1 cell list-group-item active'>Comments</div>
			<div class='col-sm-1 cell list-group-item active'>Info</div>
		</div>
<?php 
ini_set('error_reporting', E_ALL);
// phpinfo();
require 'db.inc';

function convertANSIDate($date){
	return substr($date, 0, 4) . "-" . substr($date, 4, 2) . "-" . substr($date, 6);
}

# creates a get more information form which will display customer information.
function getContact(){
	// $ret = "<form action='delete.php' method='POST'>";
	// $ret .= "<input type='hidden' value='$orderId' name='order_id'>";
	// $ret .= "<input type='hidden' value='$orderLine' name='order_line'>";
	// $ret .= "<input type='hidden' value='$itype' name='itype'>";
	// $ret .= "<input type='hidden' value='$dateRestriction' name='start_date'>";
	// $ret .= "<input type='submit' value='X'>";
	// $ret .= "</form>";
	// return $ret; 
	return 'data';
}

$sql = "";
if (empty($_GET['branch']) || $_GET['branch'] == 'ALL'){
	# If the item field is empty show the entire database of materials.
	$sql = "SELECT * FROM avincomplete ORDER BY CreateDate";
} else {
	# Show a specific branch items...
	$sql = "SELECT * FROM avincomplete WHERE Location='" . $_GET['branch'] . "'";
}
// TABLE avincomplete 
// ItemId INTEGER PRIMARY KEY NOT NULL,
// Title CHAR(256),
// CreateDate DATE DEFAULT CURRENT_DATE,
// UserKey INTEGER,
// Contact INTEGER DEFAULT 0,
// ContactDate DATE DEFAULT NULL,
// Complete INTEGER DEFAULT 0,
// CompleteDate DATE DEFAULT NULL,
// Discard  INTEGER DEFAULT 0,
// DiscardDate DATE DEFAULT NULL,
// Location CHAR(6) NOT NULL,
// Comments CHAR(256)
$ret = $db->query($sql);
$ran = 0;
while ($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
	$itemId        = $row['ItemId'];
	$dateCreated   = $row['CreateDate'];
	// replace the spaces because they break the sorting.
	$title         = preg_replace("/\s+/", "_", $row['Title']);
	echo "  <div class='row rowGroup' date_create='$dateCreated' item_id='$itemId' title='$title'>";
	echo "      <div class='col-sm-2 cell list-group-item'>" . $row['ItemId'] . "</div>";
	echo "      <div class='col-sm-2 cell list-group-item'>" . $row['Title'] . "</div>";
	echo "      <div class='col-sm-1 cell list-group-item'>" . $row['Location'] . "</div>";
	echo "      <div class='col-sm-2 cell list-group-item'>" . convertANSIDate($row['CreateDate']) . "</div>";
// TODO Here we have to put in checkboxes, or graphics that we can link to other actions with ajax.
	echo "      <div class='col-sm-1 cell list-group-item'>data</div>";
	echo "      <div class='col-sm-1 cell list-group-item'>data</div>";
	echo "      <div class='col-sm-1 cell list-group-item'>data</div>";
	echo "      <div class='col-sm-1 cell list-group-item'>data</div>";
	echo "      <div class='col-sm-1 cell list-group-item'>" . getContact() . "</div>"; // Form for the remove operation.
	echo "  </div>";
	$ran++;
}
$db->close();
if ($ran == 0){
	echo "  <div class='rowGroup'>";
	echo "    <div class='col-sm-2 cell list-group-item'>";
	echo "      <div class='cell'>Move along, nothing to see here.</div>";
	echo "    </div>";
	echo "  </div>";
}
// function setDiscarded(){
	// $sql = "UPDATE avincomplete SET Discard=1 WHERE ItemId=" . $_GET['itemId'];
	// $db->query($sql);
// }
// $db->close();
?>
	</div>
	<div id='results' class='table'></div>
</div>

<!-- <form action='index.php'>
<input type='submit' value='back'>
</form>
-->
<script>
var stickyOffset = $('.sticky').offset().top;

$(window).scroll(function(){
	var sticky = $('.sticky'), scroll = $(window).scrollTop();
	if (scroll >= stickyOffset){
		sticky.addClass('fixed');
	} else {
		sticky.removeClass('fixed');
	}
});

var isDescending = false;
$(document).ready(function(){
	zebraRows();
});

$('a#title').click(
	function(event) 
	{
		event.preventDefault();
		myArray = $(".rowGroup");
		isDescending = ! isDescending; 
		sortIt(myArray, 'title');
		$("div#results").append($(".header"));
		$("div#results").append(myArray);
		zebraRows();
	}
);
$('a#date_create').click(
	function(event) 
	{
		event.preventDefault();
		myArray = $(".rowGroup");
		isDescending = ! isDescending; 
		sortIt(myArray, 'date_create');
		$("div#results").append($(".header"));
		$("div#results").append(myArray);
		zebraRows();
	}
);
$('a#item_id').click(
	function(event) 
	{
		event.preventDefault();
		myArray = $(".rowGroup");
		isDescending = ! isDescending; 
		sortIt(myArray, 'item_id');
		$("div#results").append($(".header"));
		$("div#results").append(myArray);
		zebraRows();
	}
);

//used to apply alternating row styles
function zebraRows(selector, className)
{
	myRows = $(".row");
	$.each(myRows, function(i, val){
		//console.log(i + '::' + val);
		$(val).removeClass('odd');
		if (i % 2 == 0){
			$(val).addClass('odd');
		}
	});
}

/*
* Sorts one of the columns.
*/
function sortIt(myArray, which){
	myArray.sort(function(a, b) {
		// convert to integers from strings
		a = parseInt(a.getAttribute(which), 10);
		b = parseInt(b.getAttribute(which), 10);
		// compare
		if (isDescending){
			if (a < b) {
				return 1;
			} else if (a > b) {
				return -1;
			} else {
				return 0;
			}
		} else { // ascending
			if (a > b) {
				return 1;
			} else if (a < b) {
				return -1;
			} else {
				return 0;
			}
		}
	});
}

</script>
</body>
</html>