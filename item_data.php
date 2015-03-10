<html><head><title>ILL Statistics</title>
<link rel="stylesheet" type="text/css" href="css/stats.css">
<script src="js/jquery-2.1.1.min.js"></script>
<script TYPE="text/javascript">
$(document).ready(function() {
	zebraRows('tbody tr:odd td', 'odd');
});
	
//used to apply alternating row styles
function zebraRows(selector, className)
{
  $(selector).removeClass(className).addClass(className);
}

$(function(){
	$("table").css("width", "80%");
	$("th").css("text-align", "left");
	$(".index").css("width", "50px");
	$(".u_date").css("width", "150px");
});

// Regular functions, that is not jQuery.
// function setDiscarded(){
// 	alert("discarding!");
// }
</script>
</head><body>

<?php 
ini_set('error_reporting', E_ALL);
// phpinfo();
require 'db.inc';




$sql = "";
if (empty($_GET['itemId'])){
	# If the item field is empty show the entire database of materials.
	$sql = "SELECT * FROM avincomplete ORDER BY CreateDate";
} else {
	# Show a specific item...
	$sql = "SELECT * FROM avincomplete WHERE ItemId='" . $_GET['itemId'] . "'";
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
echo "<table><thead><tr>";
echo "<th>Item ID</th>";
echo "<th>Title</th>";
echo "<th>Transit to:</th>";
echo "<th>Date</th>";
echo "<th>Discard</th>";
echo "<th>Complete</th>";
echo "<th>Contacted</th>";
echo "<th>Comments</th>";
echo "</tr></thead><tbody>";
$ret = $db->query($sql);
while ($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
	echo "<tr>";
	echo "<td>" . $row['ItemId'] . "</td>";
	echo "<td>" . $row['Title'] . "</td>";
	echo "<td>" . $row['Location'] . "</td>";
	echo "<td>" . $row['CreateDate'] . "</td>";
	echo "<td>"; if ($row['Discard'] > 0){ echo "Yes"; } else { echo "No"; } echo "</td>";
	echo "<td><input type='checkbox' ";	if ($row['Complete'] > 0){ echo "checked='yes'"; } echo "></td>";
	echo "<td><input type='checkbox' ";	if ($row['Contact'] > 0){ echo "checked='yes'";	} echo "></td>";
	echo "<td>" . $row['Comments'] . "</td>";
	echo "</tr>";
}
echo "</tbody></table>";

function setDiscarded(){
	$sql = "UPDATE avincomplete SET Discard=1 WHERE ItemId=" . $_GET['itemId'];
	$db->query($sql);
}
$db->close();


?>
</body></html>
