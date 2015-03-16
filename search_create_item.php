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
	<h2 class='sub-header'>Search results:</h2>
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
	echo "<p><a href='functions.php?action=create&item_id=$item&branch=$branch'><button type='button' class='btn btn-info btn-lg'>Report it now?</button></a>";
	// TODO: implement backend item of registration.
} else {
	echo "<p class='bg-success'>Item: <kbd>$item</kbd> found! ";
	if ($row['Location']){
		if ($row['Location'] === $branch){
			echo "I think the item should be here at <kbd>$branch</kbd>, check the AV shelf.";
		} else {
			echo "Transit to <kbd>".$row['Location']."</kbd>, and collect a star.<span class='glyphicon glyphicon-star'></span>";
		}
	} else {
		echo "I have this item registered, but the branch isn't specified, <br/>so I can't tell you where to send it. Do you want to ask around?";
	}
	// TODO: implement backend mark it complete function.
	// To mark something complete we call the functions.php script
	// below get with item id and the branch where the other part was found.
	// Should be a PUT or UPDATE rest call, but let's leave that for later.
	echo "</p><p><a href='functions.php?action=complete&item_id=$item&branch=$branch'><button type='button' class='btn btn-info btn-lg'>Mark it complete?</button></a>";
}
echo "<a href='index.php'>";
echo "<button type='button' class='btn btn-default btn-lg'>";
echo "<span class='glyphicon glyphicon-home'></span>";
echo "</button>";
echo "</a></p>";
$db->close();
?>


</div> <!-- container -->
<script>

</script>
</body>
</html>