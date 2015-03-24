<!DOCTYPE html>
<html lang="en">
<head>
  <title><?php if (! empty($_GET['branch'])){ echo $_GET['branch']; } ?> AV Incomplete</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  <link rel="stylesheet" href='css/style.css'>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
</head>
<body>
<nav class="navbar navbar-inverse navbar-fixed-top">
  <div class="container-fluid">
	<div class="navbar-header">
	  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
		<span class="sr-only">Toggle navigation</span>
		<span class="icon-bar"></span>
		<span class="icon-bar"></span>
		<span class="icon-bar"></span>
	  </button>
	  <a class="navbar-brand" href="index.php">EPL AV Incomplete</a>
	</div>
	<div id="navbar" class="navbar-collapse collapse">
	  <ul class="nav navbar-nav navbar-right">
		<li><a href="index.php"><span class="glyphicon glyphicon-home"></span></a></li>
		<li><a href="branch_items.php?branch=ALL"><span class="glyphicon glyphicon-wrench"></span></a></li>
		<li><a href="help.php"><span class="glyphicon glyphicon-info-sign"></span></a></li>
	  </ul>
	  <form class="navbar-form navbar-right">
		<input id='search' type="text" class="form-control" placeholder="Search..." name='search-term'>
	  </form>
	</div>
  </div>
</nav>

<div class="container-fluid">
	<div class="col-sm-12">
     <h2 class="sub-header">Incomplete items at 
	 <?php 
		if (empty($_GET['branch'])){ 
			echo '??';
		} else {
			if ($_GET['branch'] === 'ALL'){
				echo "all branches";
			} else {
				echo $_GET['branch']." branch";
			}
		} 
	?></h2>
<!--
<form action='index.php'>
<input type='submit' value='back'>
</form>
-->
	<div id='original' class='table'>
		<div class='header sticky row'>
			<div class='col-sm-2 cell list-group-item active'>Item ID&nbsp;<a id='item_id' href='#' title='sort'><img src='images/sort.gif' /></a></div>
			<div class='col-sm-3 cell list-group-item active'>Title&nbsp;<a id='title' href='#' title='sort'><img src='images/sort.gif' /></a></div>
			<div class='col-sm-1 cell list-group-item active'>Date&nbsp;<a id='date' href='#' title='sort'><img src='images/sort.gif' /></a></div>
			<div class='col-sm-1 cell list-group-item active'>Comments</div>
			<div class='col-sm-1 cell list-group-item active'>Customer</div>
			<div class='col-sm-1 cell list-group-item active'>Contact</div>
			<div class='col-sm-1 cell list-group-item active'>Complete</div>
			<div class='col-sm-1 cell list-group-item active'>Discard</div>
		</div>
<?php 
ini_set('error_reporting', E_ALL);
// phpinfo();
require 'db.inc';

$sql = "";
$branch = '';
if (empty($_GET['branch']) || $_GET['branch'] == 'ALL'){
	# If the item field is empty show the entire database of materials.
	$sql = "SELECT * FROM avincomplete ORDER BY CreateDate";
} else {
	$branch = $_GET['branch'];
	# Show a specific branch items...
	$sql = "SELECT * FROM avincomplete WHERE Location='" . $_GET['branch'] . "'";
}
// TABLE avincomplete 
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
$ret = $db->query($sql);
$ran = 0;
while ($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
	$itemId        = $row['ItemId'];
	$dateCreated   = $row['CreateDate'];
	// replace the spaces because they break the sorting.
	$title         = preg_replace("/\s+/", "_", $row['Title']);
	echo "  <div class='row rowGroup' date_create='$dateCreated' item_id='$itemId' title='$title'>";
	echo "      <div class='col-sm-2 cell list-group-item'>" . $row['ItemId'] . "</div>";
	echo "      <div class='col-sm-3 cell list-group-item'>" . $row['Title'] . "</div>";
	echo "      <div class='col-sm-1 cell list-group-item'>" . $row['CreateDate'] . "</div>";
	# TODO add function to bring up a modal data entry window for comments.
	echo "      <div class='col-sm-1 cell list-group-item'><a id='comment' my-action='comments' href='#' item_id='".$itemId."' branch='".$row['Location']."' class='btn btn-default btn-xs btn-block' data-toggle='modal' data-target='#commentsModal'><span class='glyphicon glyphicon-pencil'></span></button></a></div>";
	echo "      <div class='col-sm-1 cell list-group-item'><a class='info' href='#' item_id='".$itemId."' branch='".$row['Location']."'><button type='button' class='btn btn-default btn-xs btn-block' data-toggle='modal' data-target='.bs-example-modal-lg'><span class='glyphicon glyphicon-question-sign'></span></button></a></div>";
	if ($row['Contact'] == 1){
		echo "      <div class='col-sm-1 cell list-group-item'><a class='av-button' my-action='contact' href='#' item_id='".$itemId."' branch='".$row['Location']."'><button type='button' class='btn btn-success btn-xs btn-block' data-toggle='modal' data-target='.bs-example-modal-lg'><span class='glyphicon glyphicon-earphone'></span>?</button></a></div>";
	} else {
		echo "      <div class='col-sm-1 cell list-group-item'><a class='av-button' my-action='contact' href='#' item_id='".$itemId."' branch='".$row['Location']."'><button type='button' class='btn btn-default btn-xs btn-block' data-toggle='modal' data-target='.bs-example-modal-lg'><span class='glyphicon glyphicon-earphone'></span>?</button></a></div>";
	}
	if ($row['Complete'] == 1){
		echo "      <div class='col-sm-1 cell list-group-item'><a class='av-button' my-action='complete' href='#' item_id='".$itemId."' branch='".$row['Location']."'><button type='button' class='btn btn-success btn-xs btn-block' data-toggle='modal' data-target='.bs-example-modal-lg'><span class='glyphicon glyphicon-ok'></span></button></a></div>";
	} else {
		echo "      <div class='col-sm-1 cell list-group-item'><a class='av-button' my-action='complete' href='#' item_id='".$itemId."' branch='".$row['Location']."'><button type='button' class='btn btn-default btn-xs btn-block' data-toggle='modal' data-target='.bs-example-modal-lg'><span class='glyphicon glyphicon-ok'></span></button></a></div>";
	}
	if ($row['Discard'] == 1){
		echo "      <div class='col-sm-1 cell list-group-item'><a class='av-button' my-action='discard' href='#' item_id='".$itemId."' branch='".$row['Location']."'><button type='button' class='btn btn-success btn-xs btn-block' data-toggle='modal' data-target='.bs-example-modal-lg'><span class='glyphicon glyphicon-trash'></span></button></a></div>";
	} else {
		echo "      <div class='col-sm-1 cell list-group-item'><a class='av-button' my-action='discard' href='#' item_id='".$itemId."' branch='".$row['Location']."'><button type='button' class='btn btn-default btn-xs btn-block' data-toggle='modal' data-target='.bs-example-modal-lg'><span class='glyphicon glyphicon-trash'></span></button></a></div>";
	}
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

?>
			</div>
		</div>
	<div id='results' class='table'></div>
</div>
<!-- Modal dialog box -->
<div class='modal fade bs-example-modal-lg' tabindex='-1' role='dialog' aria-labelledby='myLargeModalLabel' aria-hidden='true'>
  <div class='modal-dialog modal-sm'>
    <div class='modal-content'>
      <div class='modal-header'>
         <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>
            <h4 class='modal-title'>Info</h4>
         </div>
         <div class='modal-body'>
            <p id='info-dialog'>Oops, you shouldn't be seeing this</p>
        </div>
        <div class='modal-footer'>
            <button type='button' class='btn btn-default' data-dismiss='modal'>Close</button>
        </div>
    </div>
  </div>
</div>
<!-- end of Modal dialog box -->
<!-- Begin modal text box -->
<div class="modal fade" id="commentsModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="exampleModalLabel">Notes</h4>
      </div>
      <div class="modal-body">
        <form>
          <div class="form-group">
            <label for="message-text" class="control-label">Comments:</label>
            <textarea class="form-control" id="comment-text" placeholder="comments" autofocus></textarea>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <a class="btn btn-default" data-dismiss="modal">Close</a>
        <a id='save-comments' class="btn btn-primary" data-dismiss="modal">Save</a>
      </div>
    </div>
  </div>
</div>
<!-- End modal text box -->
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
	// Handles comments modal dialog box. add the action branch and item to the modal so we 
	// can fire an ajax request and know what we are talking about.
	$("a#comment").click(function(){
		// $("#info-dialog").load("demo_test.txt");
		itemId = $(this).attr('item_id');
		branch = $(this).attr('branch');
		myAction = $(this).attr('my-action');
		$("#comment-text").text(itemId + " : " + branch + " : " + myAction);
		$("#save-comments").attr('item_id', itemId);
		$("#save-comments").attr('branch', branch);
		$("#save-comments").attr('my-action', myAction);
		$("textarea#comment-text").val('');
	});
	
	// clear out the text area on click
	$('textarea#comment-text').click('click focusin', function() {
		$('textarea#comment-text').val('');
	});
	
	// What to do when the save button is clicked.
	$("a#save-comments").click(function(){
		itemId = $(this).attr('item_id');
		branch = $(this).attr('branch');
		myAction = $(this).attr('my-action');
		data   = encodeURIComponent($("textarea#comment-text").val());
		$("#info-dialog").load(
			"functions.php?action=" + myAction + "&item_id=" + itemId + "&branch=" + branch + "&data=" + data, 
			function(responseTxt, statusTxt, xhr){
				if(statusTxt == "error")
					$("#comment-text").text("Error: " + xhr.status + ": " + xhr.statusText);
		});
    });
	// Handles all the actions related to displaying information in the modal dialogue box.
	$("a.av-button").click(function(){
        // $("#info-dialog").load("demo_test.txt");
		itemId = $(this).attr('item_id');
		branch = $(this).attr('branch');
		myAction = $(this).attr('my-action');
        $("#info-dialog").load(
			"functions.php?action=" + myAction + "&item_id=" + itemId + "&branch=" + branch, 
			function(responseTxt, statusTxt, xhr){
				if(statusTxt == "error")
					$("#info-dialog").text("Error: " + xhr.status + ": " + xhr.statusText);
		});
    });
	
	// Handles all the get customer information dialog boxes.
	$("a.info").click(function(){
        // $("#info-dialog").load("demo_test.txt");
		itemId = $(this).attr('item_id');
		branch = $(this).attr('branch');
        $("#info-dialog").load(
			"functions.php?action=info&item_id=" + itemId + "&branch=" + branch, 
			function(responseTxt, statusTxt, xhr){
				if(statusTxt == "error")
					$("#info-dialog").text("Error: " + xhr.status + ": " + xhr.statusText);
		});
    });
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