<!DOCTYPE html>
<html lang="en">
<head>
  <title><?php if (! empty($_GET['branch'])){ echo $_GET['branch']; } ?> AV Incomplete</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"> -->
  <!-- <link rel="stylesheet" href='css/style.css'> -->
  <!-- <link rel="stylesheet" href='//cdn.datatables.net/1.10.5/css/jquery.dataTables.css'> -->
  <!--                      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> -->
  <!-- <script src="js/jquery-2.1.1.min.js"></script> -->
  <!-- <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script> -->
  <!-- <script src="//cdn.datatables.net/1.10.5/js/jquery.dataTables.min.js"></script> -->
  <!-- added for testing -->
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"> -->
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>
  <!-- <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script> -->
  <script src="js/bootstrap.min.js"></script>
  <!-- next line moves the table below the Nav-bar. See https://getbootstrap.com/components/#navbar for details -->
  <style>
  body { padding-top: 70px; }
  </style>
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
	  <a class="navbar-brand" href="index.php">EPL AV Incomplete <?php if (! empty($_GET['branch'])){ echo $_GET['branch']; } ?></a>
	</div>
	<div id="navbar" class="navbar-collapse collapse">
	  <ul class="nav navbar-nav navbar-right">
		<li><a href="https://staffweb.epl.ca/"><img src="https://avatars2.githubusercontent.com/u/4293855?v=3&s=20"/></a></li>
		<li><a href='index.php'>Home</a></li>
		<li><a href='branch_items.php?branch=ALL'>All AVI</a></li>
		<li><a href='help.php'>Help</a></li>
	  </ul>
	</div>
  </div>
</nav>

<!-- <div class="container-fluid"> -->
<div class="container">
<table id="items-table" class="table table-condensed table-hover table-striped" cellspacing="0" width="100%">
<!-- <table id="items-table" class="display" cellspacing="0" width="100%"> -->
	<thead>
		<tr>
			<th>Item ID</th>
			<th>Title</th>
			<th>Date</th>
			<!-- <th>Comments</th> -->
			<th>Customer</th>
			<th>Contact</th>
			<th>Complete</th>
			<th>Discard</th>
		</tr>
	</thead>
	
	<tfoot>
		<tr>
			<th>Item ID</th>
			<th>Title</th>
			<th>Date</th>
			<!-- <th>Comments</th> -->
			<th>Customer</th>
			<th>Contact</th>
			<th>Complete</th>
			<th>Discard</th>
		</tr>
	</tfoot>
	<tbody>
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
	$sql = "SELECT * FROM avincomplete WHERE Location='" . $_GET['branch'] . "' ORDER BY CreateDate";
}

$ret = $db->query($sql);
while ($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
	$itemId        = $row['ItemId'];
	$dateCreated   = $row['CreateDate'];
	// replace the spaces because they break the sorting.
	$date          = preg_replace("/\-/", "/", $row['CreateDate']);
	echo "	<tr>
		<td>" . $row['ItemId'] . "</td>
		<td>" . $row['Title'] . "</td>
		<td>" . $date. "</td>\n";
	# TODO add function to bring up a modal data entry window for comments.
	// if (strlen($row['Comments']) > 0){
		// echo "		<td>
			// <a my-action='comments' href='#' item_id='".$itemId."' branch='".$row['Location']."' 
				// class='comment btn btn-default btn-xs btn-block' data-toggle='modal' data-target='#commentsModal'>
				// <span class='glyphicon glyphicon-pencil'></span>
			// </a>
		// </td>\n";
	// } else {
		// echo "		<td>
			// <a my-action='comments' href='#' item_id='".$itemId."' branch='".$row['Location']."' 
				// class='comment btn btn-default btn-xs btn-block' data-toggle='modal' data-target='#commentsModal'>
				// <span class='glyphicon glyphicon-pencil'></span>
			// </a>
		// </td>\n";
	// }
	echo "		<td>
			<a my-action='info' href='#' item_id='".$itemId."' branch='".$row['Location']."' 
				class='info btn btn-primary btn-xs btn-block' data-toggle='modal' data-target='#infoModal'>
				info
			</a>
		</td>\n";
	if ($row['Contact'] == 1){
		echo "		<td>
			<button type='button' class='btn btn-default btn-xs btn-block'>
			contacted
			</button>
		</td>\n";
	} else {
		echo "		<td>
			<button type='button' class='btn btn-default btn-xs btn-block'>
			contacted
			</button>
		</td>\n";
	}
	if ($row['Complete'] == 1){
		echo "		<td>
			<a my-action='complete' href='#' item_id='".$itemId."' branch='".$row['Location']."' 
				class='av-button btn btn-default btn-xs btn-block' data-toggle='modal' data-target='#infoModal'>
				complete
			</a>
		</td>\n";
	} else {
		echo "		<td>
			<a my-action='complete' href='#' item_id='".$itemId."' branch='".$row['Location']."' 
				class='av-button btn btn-default btn-xs btn-block' data-toggle='modal' data-target='#infoModal'>
				complete
			</a>
		</td>\n";
	}
	if ($row['Discard'] == 1){
		echo "		<td>
			<a my-action='discard' href='#' item_id='".$itemId."' branch='".$row['Location']."' 
				class='av-button btn btn-default btn-xs btn-block' data-toggle='modal' data-target='#infoModal'>
				discard
			</a>
		</td>\n";
	} else {
		echo "		<td>
			<a my-action='discard' href='#' item_id='".$itemId."' branch='".$row['Location']."' 
				class='av-button btn btn-default btn-xs btn-block' data-toggle='modal' data-target='#infoModal'>
				discard
			</a>
		</td>\n";
	}
	echo "	</tr>\n";
}
$db->close();
?>
<!-- Modal dialog box -->
<div class='modal fade bs-example-modal-lg' id="infoModal" tabindex='-1' role='dialog' aria-labelledby='commentsModalLabel' aria-hidden='true'>
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
<div class="modal fade" id="commentsModal" tabindex="-1" role="dialog" aria-labelledby="basicModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="basicModalLabel">Notes</h4>
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
        <a id='cancel' class="btn btn-default" data-dismiss="modal">Close</a>
        <a id='save-comments' class="btn btn-primary" data-dismiss="modal">Save</a>
      </div>
    </div>
  </div>
</div>
<!-- End modal text box -->
	</tbody>
</table>
</div>

<script>

var isDescending = false;
$(document).ready(function(){
	// This command causes the functionality to break on additional pages. TODO: Why?
	// $('#items-table').dataTable({
       // order: [[ 2, "dsc" ]], // order on date entered.
	   // stateSave: true,
    // } );
	// Handles comments modal dialog box. add the action branch and item to the modal so we 
	// can fire an ajax request and know what we are talking about.
	// $("a.comment").click(function(){
		// var itemId = $(this).attr('item_id');
		// var branch = $(this).attr('branch');
		// var myAction = $(this).attr('my-action');
		////$("#info-dialog").text("item_id:"+itemId);
		//// alert("I ran");
		////$("#comment-text").text(itemId + " : " + branch + " : " + myAction);
		// $("#save-comments").attr('item_id', itemId);
		// $("#save-comments").attr('branch', branch);
		// $("#save-comments").attr('my-action', myAction);
		////$("textarea#comment-text").val('');
	// });
	
	// clear out the text area on click
	// $('textarea#comment-text').click('click focusin', function() {
		// $('textarea#comment-text').val('');
	// });
	
	// $("a#cancel").click(function(){
		// itemId = $(this).attr('item_id');
		// $("textarea#comment-text").val("");
		// $("#comment-text").text("");
		// $("#save-comments").attr('item_id', "");
		// $("#save-comments").attr('branch', "");
		// $("#save-comments").attr('my-action', "");
	// });
	
	// What to do when the save button is clicked.
	// $("a#save-comments").click(function(){
		// itemId = $(this).attr('item_id');
		// branch = $(this).attr('branch');
		// myAction = $(this).attr('my-action');
		// data   = encodeURIComponent($("textarea#comment-text").val());
		// $("#info-dialog").load(
			// "functions.php?action=" + myAction + "&item_id=" + itemId + "&branch=" + branch + "&data=" + data, 
			// function(responseTxt, statusTxt, xhr){
				// if(statusTxt == "error")
					// $("#comment-text").text("Error: " + xhr.status + ": " + xhr.statusText);
		// });
		// $("textarea#comment-text").val("");
		// $("#comment-text").text("");
		// $("#save-comments").attr('item_id', "");
		// $("#save-comments").attr('branch', "");
		// $("#save-comments").attr('my-action', "");
    // });
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
// Added to refress the page and show the discard or complete button with correct colouring.
setTimeout(function(){
   window.location.reload(1);
}, 20000);
</script>
</body>
</html>