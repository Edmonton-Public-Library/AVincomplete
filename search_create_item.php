<!DOCTYPE html>
<html lang='en'>
<head>
  <title><?php if (! empty($_GET['branch'])){ echo $_GET['branch']; } ?> Incomplete Item</title>
  <meta charset='utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1'>
  <!-- <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"> -->
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link rel='stylesheet' href='css/style.css'>
  <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> -->
  <script src="js/jquery-2.1.1.min.js"></script>
  <!-- <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script> -->
  <script src="js/bootstrap.min.js"></script>
</head>
<body>
<nav class='navbar navbar-inverse navbar-fixed-top'>
  <div class='container-fluid'>
	<div class='navbar-header'>
	  <button type='button' class='navbar-toggle collapsed' data-toggle='collapse' data-target='#navbar' aria-expanded='false' aria-controls='navbar'>
		<span class='sr-only'>Toggle navigation</span>
		<span class='icon-bar'></span>
		<span class='icon-bar'></span>
		<span class='icon-bar'></span>
	  </button>
	  <a class='navbar-brand' href='index.php'>EPL Incomplete Item</a>
	</div>
	<div id='navbar' class='navbar-collapse collapse'>
	  <ul class='nav navbar-nav navbar-right'>
		<li><a href='index.php'>Home</a></li>
		<li><a href='branch_items.php?branch=ALL'>All Incomplete Items</a></li>
		<li><a href='help.php'>Help</a></li>
	  </ul>
	</div>
  </div>
</nav>
<div class='container-fluid'>
	<div class="col-sm-7">
	<h2 class="sub-header">Search results:</h2>
	<div class='row'>
		<div class='col-md-2'>
			<p/>
		</div>
		<div class='col-md-4'>
	
	
	
	
<?php
ini_set('error_reporting', E_ALL);
require 'db.inc';

$item = '';
if (empty($_GET['item_id'])){ 
	$msg = "bar code search requested, but none found.";
	header("error.php?msg=$msg"); 
} else { 
	$item = $_GET['item_id'];  
}
// phpinfo();
// This page shows an item if one exists on record, and if not allows you to create it in the database.
# Get the count of items in the database.
// $sql = "SELECT count(*) as count FROM avincomplete";// WHERE ItemId=" . $_GET['item_id'];
// $sql = "SELECT count(*) as count, Location FROM avincomplete WHERE ItemId=" . $_GET['item_id'];
$sql = "SELECT count(*) as count, Location, Title FROM avincomplete WHERE ItemId=" . $_GET['item_id'];
$branch = '';
if (isset($_GET['branch'])){
	$branch = $_GET['branch'];
} else {
	$msg = "branch missing on create: search_create_item.php.";
	header("Location:error.php?msg=$msg");
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
$row = $ret->fetchArray(SQLITE3_ASSOC);
if (! $row['count']){
	echo "<p class='bg-danger'>Item: <kbd>$item</kbd> hasn't been reported as incomplete yet.</p>";
	// Create a form that includes information that will submit the missing parts for the comments field.
	echo "<p>Missing parts:</p>
		<input id='case' type='checkbox' value='case missing' />case is missing<br />
		<input id='insert' type='checkbox' value='insert / booklet missing' />insert / booklet is missing<br />
		<input id='disc' type='checkbox' value='disc is missing' />disc is missing<br />
		<input id='disc1' type='checkbox' value='disc 1 is missing' />disc 1 is missing<br />
		<input id='disc2' type='checkbox' value='disc 2 is missing' />disc 2 is missing<br />
		<input id='disc3' type='checkbox' value='disc 3 is missing' />disc 3 is missing<br />
		<input id='disc4' type='checkbox' value='disc 4 is missing' />disc 4 is missing<br />
		<input id='disc5' type='checkbox' value='disc 5 is missing' />disc 5 is missing<br />
		<input id='disc6' type='checkbox' value='disc 6 is missing' />disc 6 is missing<br />
		<input id='disc7' type='checkbox' value='disc 7 is missing' />disc 7 is missing<br />
		<input id='disc8' type='checkbox' value='disc 8 is missing' />disc 8 is missing<br />
		<input id='disc9' type='checkbox' value='disc 9 is missing' />disc 9 is missing<br />
		<input id='disc10' type='checkbox' value='disc 10 is missing' />disc 10 is missing<br />
		<input id='several' type='checkbox' value='several discs are missing' />several discs are missing<br />
		<input id='case_not_epls' type='checkbox' value='case does not belong to EPL' />case doesn't belong to EPL<br />
		<input id='disc_not_epls' type='checkbox' value='disc does not belong to EPL' />disc doesn't belong to EPL<br />
		<input id='book' type='checkbox' value='book is missing' />book is missing<br />
		<input id='puppet' type='checkbox' value='puppet is missing' />puppet is missing<br />
		<input id='map' type='checkbox' value='map is missing' />map is missing<br />
		<input id='pattern' type='checkbox' value='pattern' />pattern is missing<br />
		";
	echo "<p>
	<a id='do_it' href='#' my-action='create' item_id='$item' branch='$branch' 
		class='av-button btn btn-default btn-primary btn-lg'
		data-toggle='modal' data-target='.bs-example-modal-lg'>
			Report it now?
	</a>";
} else {
	$title = $row['Title'];
	echo "<p class='bg-success'>Item: <kbd>$item</kbd><br/> '$title' found!<br/>";
	if ($row['Location']){
		if ($row['Location'] === $branch){
			// echo "I think the item should be here at <kbd>$branch</kbd>, check the AV shelf.";
			echo "I think the item should be here at <kbd>$branch</kbd>, check the AV shelf.";
			echo "<p>
					<a id='complete_it' href='#' my-action='complete' item_id='$item' branch='$branch' 
						class='av-button btn btn-default btn-primary btn-lg'
						data-toggle='modal' data-target='.bs-example-modal-lg'>
						Ok
					</a>";
		} else {
			echo "Transit to <kbd>".$row['Location']."</kbd>, and collect a star.";
			echo "<p>
					<a id='transit_it' href='#' my-action='transit' item_id='$item' branch='$branch' 
						class='av-button btn btn-default btn-primary btn-lg'
						data-toggle='modal' data-target='.bs-example-modal-lg'>
							Send to " . $row['Location'] . "?
					</a>";
		}
	} else {
		echo "I have this item registered, but the branch isn't specified, <br/>so I can't tell you where to send it. Do you want to ask around?";
	}
}
echo "<a href='index.php'>";
echo "<button type='button' class='btn btn-default btn-lg'>";
echo "Home";
echo "</button>";
echo "</a></p>";
$db->close();
?>

		</div> <!-- 2nd column -->
	</div> <!-- columns -->
</div> <!-- container -->
<!-- Modal dialog box -->
<div class='modal fade bs-example-modal-lg' tabindex='-1' role='dialog' aria-labelledby='commentsModalLabel' aria-hidden='true'>
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
            <a href='index.php'><button type='button' class='btn btn-default'>Close</button></a>
        </div>
    </div>
  </div>
</div>
<!-- end of Modal dialog box -->
<script>
var missingParts = [];
var missingPartsString = '';
$(document).ready(function(){
	$("a#transit_it").click(function(){
        // $("#info-dialog").load("demo_test.txt");
		itemId = $(this).attr('item_id');
		branch = $(this).attr('branch');
		myAction = $(this).attr('my-action');
		// $("p#info-dialog").html('heres what I have ' + itemId + ', ' + branch + ', ' + myAction + '.');
		myURL = myAction + "&item_id=" + itemId + "&branch=" + branch;
		$("#info-dialog").load(
			"functions.php?action=" + myURL, 
			function(responseTxt, statusTxt, xhr){
				if(statusTxt == "error")
					$("#info-dialog").text("Error: " + xhr.status + ": " + xhr.statusText);
		});
    });
	$("a#complete_it").click(function(){
        // $("#info-dialog").load("demo_test.txt");
		itemId = $(this).attr('item_id');
		branch = $(this).attr('branch');
		myAction = $(this).attr('my-action');
		// $("p#info-dialog").html('heres what I have ' + itemId + ', ' + branch + ', ' + myAction + '.');
		myURL = myAction + "&item_id=" + itemId + "&branch=" + branch;
		$("#info-dialog").load(
			"functions.php?action=" + myURL, 
			function(responseTxt, statusTxt, xhr){
				if(statusTxt == "error")
					$("#info-dialog").text("Error: " + xhr.status + ": " + xhr.statusText);
		});
    });
	// Handles all the actions related to displaying information in the modal dialogue box.
	$("a#do_it").click(function(){
        // $("#info-dialog").load("demo_test.txt");
		itemId = $(this).attr('item_id');
		branch = $(this).attr('branch');
		myAction = $(this).attr('my-action');
		// $("p#info-dialog").html('heres what I have ' + itemId + ', ' + branch + ', ' + myAction + ', and ' + missingPartsString + '.');
		// $("p#info-dialog").html('heres what I have.');
		//confirm('The following pieces are missing: ' + missingPartsString + '. ');
		myURL = '';
		if (missingParts.length > 0) {
			myURL = myAction + "&item_id=" + itemId + "&branch=" + branch + "&data=" + encodeURIComponent(missingPartsString);
		} else {
			myURL = myAction + "&item_id=" + itemId + "&branch=" + branch;
		}
		$("#info-dialog").load(
			"functions.php?action=" + myURL, 
			function(responseTxt, statusTxt, xhr){
				if(statusTxt == "error")
					$("#info-dialog").text("Error: " + xhr.status + ": " + xhr.statusText);
		});
    });
	// Handles clicks from the
	$('input').click(function (e) {
		if ($(this).prop('checked')) {
			missingParts.push(this.value);
		} else {
			index = missingParts.indexOf(this.value);
			if (index > -1) {
				missingParts.splice(index, 1);
			}
		}
		// Format the string nicely.
		missingPartsString = '';
		for (var i = 0; i < missingParts.length -1; i++) {
			missingPartsString += missingParts[i];
			missingPartsString += ', '
		}
		if (missingParts.length > 1) {
			missingPartsString += 'and ';
			missingPartsString += missingParts[missingParts.length -1];
		} else {
			missingPartsString = missingParts[0];
		}
	});
});
</script>
</body>
</html>