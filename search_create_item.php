<!DOCTYPE html>
<html lang='en'>
<head>
  <title><?php if (! empty($_GET['branch'])){ echo $_GET['branch']; } ?> AV Incomplete</title>
  <meta charset='utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1'>
  <link rel='stylesheet' href='http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'>
  <link rel='stylesheet' href='css/style.css'>
  <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'></script>
  <script src='http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js'></script>
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
	  <a class='navbar-brand' href='index.php'>EPL AV Incomplete</a>
	</div>
	<div id='navbar' class='navbar-collapse collapse'>
	  <ul class='nav navbar-nav navbar-right'>
		<li><a href='index.php'><span class='glyphicon glyphicon-home'></span></a></li>
		<li><a href='branch_items.php?branch=ALL'><span class='glyphicon glyphicon-wrench'></span></a></li>
		<li><a href='help.php'><span class='glyphicon glyphicon-info-sign'></span></a></li>
	  </ul>
	  <form class='navbar-form navbar-right'>
		<input type='text' class='form-control' placeholder='Search...'>
	  </form>
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
$sql = "SELECT count(*) as count, Location FROM avincomplete WHERE ItemId=" . $_GET['item_id'];
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
	echo "<p><a href='functions.php?action=create&item_id=$item&branch=$branch'><button type='button' class='btn btn-primary btn-lg'>Report it now?</button></a>";
} else {
	echo "<p class='bg-success'>Item: <kbd>$item</kbd> found! ";
	if ($row['Location']){
		if ($row['Location'] === $branch){
			echo "I think the item should be here at <kbd>$branch</kbd>, check the AV shelf.";
			echo "</p><p><a href='functions.php?action=complete&item_id=$item&branch=$branch'><button type='button' class='btn btn-primary btn-lg'>Mark it complete?</button></a>";
		} else {
			echo "Transit to <kbd>".$row['Location']."</kbd>, and collect a star.<span class='glyphicon glyphicon-star'></span>";
			echo "</p><p><a href='functions.php?action=complete&item_id=$item&branch=$branch'><button type='button' class='btn btn-primary btn-lg'>Transit to ".$row['Location']."?</button></a>";
		}
	} else {
		echo "I have this item registered, but the branch isn't specified, <br/>so I can't tell you where to send it. Do you want to ask around?";
	}
}
echo "<a href='index.php'>";
echo "<button type='button' class='btn btn-default btn-lg'>";
echo "<span class='glyphicon glyphicon-home'></span>";
echo "</button>";
echo "</a></p>";
$db->close();
?>

		</div> <!-- 2nd column -->
	</div> <!-- columns -->
</div> <!-- container -->
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
<script>
$(document).ready(function(){
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
});
</script>
</body>
</html>