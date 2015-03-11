<html><head><title>AV Incomplete</title>
<style>

</style>
<script src="js/jquery-2.1.1.min.js"></script>
<script TYPE="text/javascript">

</script>
</head><body>
<div class='error'></div>
<?php 
ini_set('error_reporting', E_ALL);
// phpinfo();
// require 'db.inc';
$branch = '';
$itemId = '';
if (! empty($_GET)) {
 	if (! empty($_GET['branch'])){
		$branch = $_GET['branch'];
		if ($branch != 'ALL'){ // don't set the branch to all if choosen, it isn't a valid location if we have to create items.
			setcookie('branch',$_GET['branch']);
		}
		echo "<h3>branch set to '$branch'</h3>";
	}
	if (! empty($_GET['item_id'])){
		$itemId = trim($_GET['item_id']);
		echo "<h3>$itemId</h3>";
		if (preg_match("/\d{14}/", $itemId)){
			echo "<p>looks like a good one.</p>";
			if (strcmp($branch, 'ALL') == 0){ // don't set the branch to all if choosen, it isn't a valid location if we have to create items.
				$msg = "ALL is not a valid branch location. Click back and select the item's current location branch.";
				header("Location:error.php?msg=$msg");
			}
			echo "<p>branch is set to '$branch'</p>";
			// redirect to page to show item with routing if exists and if not get information about item and enter in database.
			header("Location:search_create_item.php?item_id=$itemId&branch=$branch");
		} else {
			$msg = "Invalid bar code '$itemId' isn't 14 digits.";
			header("Location:error.php?msg=$msg");
		}		
	} else { # None empty item id
		echo "<h3>itemId not set.</h3>";
		// redirect to page to show branch items.
		header("Location:branch_items.php?branch=$branch");
	}
} else {
	$msg = htmlentities('No branch or barcode submitted in page data.php');
	header("Location:error.php?msg=$msg");
}
// $sql = "";
// if (empty($_GET['item_id'])){
	// # If the item field is empty show the entire database of materials.
	// $sql = "SELECT * FROM avincomplete ORDER BY CreateDate";
// } else {
	// # Show a specific item...
	// $sql = "SELECT * FROM avincomplete WHERE ItemId='" . $_GET['itemId'] . "'";
// }
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
// echo "<table><thead><tr>";
// echo "<th>Item ID</th>";
// echo "<th>Title</th>";
// echo "<th>Transit to:</th>";
// echo "<th>Date</th>";
// echo "<th>Discard</th>";
// echo "<th>Complete</th>";
// echo "<th>Contacted</th>";
// echo "<th>Comments</th>";
// echo "</tr></thead><tbody>";
// $ret = $db->query($sql);
// while ($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
	// echo "<tr>";
	// echo "<td>" . $row['ItemId'] . "</td>";
	// echo "<td>" . $row['Title'] . "</td>";
	// echo "<td>" . $row['Location'] . "</td>";
	// echo "<td>" . $row['CreateDate'] . "</td>";
	// echo "<td>"; if ($row['Discard'] > 0){ echo "Yes"; } else { echo "No"; } echo "</td>";
	// echo "<td><input type='checkbox' ";	if ($row['Complete'] > 0){ echo "checked='yes'"; } echo "></td>";
	// echo "<td><input type='checkbox' ";	if ($row['Contact'] > 0){ echo "checked='yes'";	} echo "></td>";
	// echo "<td>" . $row['Comments'] . "</td>";
	// echo "</tr>";
// }
// echo "</tbody></table>";

// function setDiscarded(){
	// $sql = "UPDATE avincomplete SET Discard=1 WHERE ItemId=" . $_GET['itemId'];
	// $db->query($sql);
// }
// $db->close();


?>
</body></html>