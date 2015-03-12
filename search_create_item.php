<html>
<head>
<title>AV Incomplete</title>
<?php 
	ini_set('error_reporting', E_ALL);
	require 'db.inc';
	// phpinfo();
	// This page shows an item if one exists on record, and if not allows you to create it in the database.
?>
<script src='http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js'></script>
<style>
body {
  font: 13px/1.3 'Lucida Grande',sans-serif;
  color: #666;
}
</style>
</head>
<body>
<div id='results'></div>
<?php
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
		header("Location:new.php?item_id=$itemId&branch=$branch");
	}
} 
if (! defined($row['count'])){
	echo "<p>nothing</p>";
}
$db->close();
?>
<script>

</script>
</body>
</html>