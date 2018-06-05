<!DOCTYPE html>
<html lang="en">
<head>
  <title><?php if (! empty($_GET['branch'])){ echo $_GET['branch']; } ?> Incomplete Item*</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"> -->
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link rel="stylesheet" href='css/style.css'>
  <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> -->
  <script src="js/jquery-2.1.1.min.js"></script>
  <!-- <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script> -->
  <script src="js/bootstrap.min.js"></script>
</head>
<body>
<div class="container">
<div class="col-sm-4">
	<form role='form' action='data.php' method='GET'>
	<!-- <form role='form' action='outage.php' method='GET'> -->
		<h2 class="form-signin-heading">Incomplete Item</h2>
		<div class="form-group">
		<label for="sel1">Select your branch:</label>
		<select class="form-control" id="sel1" name='branch' required>
			<?php if (isset($_COOKIE['branch'])){
				$branch = $_COOKIE['branch'];
				echo "<option selected='$branch'>$branch</option>";
			} ?>
			<option value='ABB'>ABB</option>
			<option value='CAL'>CAL</option>
			<option value='CLV'>CLV</option>
			<option value='CPL'>CPL</option>
			<option value='CSD'>CSD</option>
			<option value='HIG'>HIG</option>
			<option value='HVY'>HVY</option>
			<option value='IDY'>IDY</option>
			<option value='JPL'>JPL</option>
			<option value='LHL'>LHL</option>
			<option value='LON'>LON</option>
			<option value='MEA'>MEA</option>
			<option value='MCN'>MCN</option>
			<option value='MLW'>MLW</option>
			<option value='MNA'>MNA</option>
			<option value='RIV'>RIV</option>
			<option value='SPW'>SPW</option>
			<option value='STR'>STR</option>
			<option value='WHP'>WHP</option>
			<option value='WMC'>WMC</option>
			<option value='WOO'>WOO</option>
			<option value='ALL'>ALL</option>
		</select>
		<br>
		<label for="item_id" class="sr-only">Bar code</label>
		<input id='barcode' type="text" name='item_id' maxlength='14' class="form-control" placeholder="Item bar code" autofocus>
		<button class="btn btn-lg btn-primary btn-block" type="submit">Let's go!</button>
		</div> <!-- form group -->
	</form>
	<p>
		<a href="#">copyright (c)</span></a> 2015-2018 Edmonton Public Library&nbsp;
		<a href="help.php">Help</span></a>&nbsp;
		<a href="https://staffweb.epl.ca/"><img src="https://avatars2.githubusercontent.com/u/4293855?v=3&s=50"/></a>&nbsp;
		(* The app formerly known as AVIncomplete.)
	</p>
</div> <!-- /container -->
<script>
// Clears the input fields if you set focus on them.
$(document).ready(function(){
    $('input').on('click focusin', function() {
		this.value = '';
	});
});
</script>
</body>
</html>