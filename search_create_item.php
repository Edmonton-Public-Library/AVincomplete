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
	<p>''The whole is greater than the sum of it's parts.'' - unknown</p>
  </div>
  <p>Item: <?php if (empty($_GET['item_id'])){ echo '??'; } else { echo $_GET['item_id']." "; } ?>
<?php
ini_set('error_reporting', E_ALL);
require 'db.inc';
// phpinfo();
// This page shows an item if one exists on record, and if not allows you to create it in the database.
# Get the count of items in the database.
// $sql = "SELECT count(*) as count FROM avincomplete";// WHERE ItemId=" . $_GET['item_id'];
$sql = "SELECT count(*) as count FROM avincomplete WHERE ItemId=" . $_GET['item_id'];
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
while ($row = $ret->fetchArray(SQLITE3_ASSOC)){
	if ($row['count'] == 0){
		echo " hasn't been reported as incomplete yet.</p><p><button type='button' class='btn btn-info btn-lg'>Report it now</button></p>";
		//header("Location:new.php?item_id=$itemId&branch=$branch");
	} else {
		echo "<p>found it.</p>";
	}
} 

$db->close();
?>
</div>
<script>

</script>
</body>
</html>