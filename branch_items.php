<html>
<head>
<title>AV Incomplete</title>
<?php 
	ini_set('error_reporting', E_ALL);
	// phpinfo();
?>
<script src='http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js'></script>
<style>
<style>
body {
  font: 13px/1.3 'Lucida Grande',sans-serif;
  color: #666;
}
.table {
    display:table;
}
.header {
    display:table-header-group;
    font-weight:bold;
	background-color:white;
}
.rowGroup {
    display:table-row-group;
}
.row {
    display:table-row;
	background-color: 'white';
	color: #336600;
}
.odd {
  background-color: #E0FFD6;
  color: #336600;
}

.cell {
    display:table-cell;
    width:5%;
}

.fixed {
    position: fixed;
    top:0; left:0;
    width: 100%;
}

</style>
</head>
<body style='text-align:center'>

<form action='index.php' class='fixed'><input type='submit' value='back'></form>
<div id="original" class="table">
  <div class="header sticky">
    <div class='cell'>Item ID<a id='item_id' href='#' title='sort'><img src='images/sort.gif' /></a></div>
    <div class='cell'>Title<a id='title' href='#' title='sort'><img src='images/sort.gif' /></a></div>
    <div class='cell'>Location</div>
    <div class='cell'>Date<a id='date' href='#' title='sort'><img src='images/sort.gif' /></a></div>
    <div class='cell'>Discard</div>
    <div class='cell'>Complete</div>
    <div class='cell'>Contacted</a></div>
    <div class='cell'>Comments</div>
    <div class='cell'>Contact</div>
  </div>
<?php 
ini_set('error_reporting', E_ALL);
// phpinfo();
require 'db.inc';

function convertANSIDate($date){
	return substr($date, 0, 4) . "-" . substr($date, 4, 2) . "-" . substr($date, 6);
}

# creates a get more information form but 
function getContact(){
	// $ret = "<form action='delete.php' method='POST'>";
	// $ret .= "<input type='hidden' value='$orderId' name='order_id'>";
	// $ret .= "<input type='hidden' value='$orderLine' name='order_line'>";
	// $ret .= "<input type='hidden' value='$itype' name='itype'>";
	// $ret .= "<input type='hidden' value='$dateRestriction' name='start_date'>";
	// $ret .= "<input type='submit' value='X'>";
	// $ret .= "</form>";
	// return $ret; 
}

$sql = "";
if (empty($_GET['branch']) || $_GET['branch'] == 'ALL'){
	# If the item field is empty show the entire database of materials.
	$sql = "SELECT * FROM avincomplete ORDER BY CreateDate";
} else {
	# Show a specific branch items...
	$sql = "SELECT * FROM avincomplete WHERE Branch='" . $_GET['branch'] . "'";
}
// TABLE avincomplete 
//        ItemId INTEGER PRIMARY KEY NOT NULL,
//		  Title CHAR(256),
//        CreateDate DATE DEFAULT CURRENT_TIMESTAMP,
//        UserKey INTEGER,
//        Contact INTEGER DEFAULT 0,
//        ContactDate DATE DEFAULT NULL,
//        Complete INTEGER DEFAULT 0,
//        CompleteDate DATE DEFAULT NULL,
//        Discard  INTEGER DEFAULT 0,
//        DiscardDate DATE DEFAULT NULL,
//        Location CHAR(3) NOT NULL,
//        Comments CHAR(256)
$ret = $db->query($sql);
while ($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
	$daysToProcess   = $row['DaysToProcess'];
	$dateReceived    = $row['DateReceived'];
	$dateDistributed = $row['DateDistributed'];
	echo "  <div class='rowGroup' days_to_process='$daysToProcess' date_received='$dateReceived' date_distributed='$dateDistributed'>";
	echo "    <div class='row'>";
	echo "      <div class='cell'>" . $row['ItemId'] . "</div>";
	echo "      <div class='cell'>" . $row['Title'] . "</div>";
	echo "      <div class='cell'>" . $row['Location'] . "</div>";
	echo "      <div class='cell'>" . convertANSIDate($row['CreateDate']) . "</div>";
// Here we have to put in checkboxes, or graphics that we can link to other actions.
	echo "      <div class='cell'>" . getContact() . "</div>"; // Form for the remove operation.
	echo "    </div>";
	echo "  </div>";
}
$db->close();

// function setDiscarded(){
	// $sql = "UPDATE avincomplete SET Discard=1 WHERE ItemId=" . $_GET['itemId'];
	// $db->query($sql);
// }
// $db->close();
?>
</div>
<div id="results" class='table'></div>
<form action='index.php'>
<input type='submit' value='back'>
</form>
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
		$("#results").append(myArray);
		zebraRows();
	}
);
$('a#date').click(
	function(event) 
	{
		event.preventDefault();
		myArray = $(".rowGroup");
		isDescending = ! isDescending; 
		sortIt(myArray, 'date');
		$("#results").append(myArray);
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
		$("#results").append(myArray);
		zebraRows();
	}
);

//used to apply alternating row styles
function zebraRows(selector, className)
{
	myRows = $(".row");
	$.each(myRows, function(i, val){
		console.log(i + '::' + val);
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