<html>
<head>
<title>AV Incomplete</title>

<script src='http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js'></script>
<style>
body {
  font: 13px/1.3 'Lucida Grande',sans-serif;
  color: #666;
}
.go_button{
	height: 75px;
	width: 75px;
}

</style>
</head>
<body>
	<div class='branch_selection'>
	<div class='prompt'></div>
	<form action='data.php' method='GET'>
		<br>branch:<br>
		<select name='branch'>
		<?php if (isset($_COOKIE['branch'])){
			$branch = $_COOKIE['branch'];
			echo "<option selected='$branch'>$branch</option>";
		} ?>
		<option value='MNA'>MNA</option>
		<option value='MLW'>MLW</option>
		<option value='WMC'>WMC</option>
		<option value='LHL'>LHL</option>
		<option value='LON'>LON</option>
		<option value='JPL'>JPL</option>
		<option value='HIG'>HIG</option>
		<option value='WOO'>WOO</option>
		<option value='STR'>STR</option>
		<option value='CLV'>CLV</option>
		<option value='MEA'>MEA</option>
		<option value='CAL'>CAL</option>
		<option value='CSD'>CSD</option>
		<option value='IDY'>IDY</option>
		<!-- <option value='LES'>LES</option> // Lewis estates when available. -->
		<option value='RIV'>RIV</option>
		<option value='SPW'>SPW</option>
		<option value='CPL'>CPL</option>
		<option value='ALL'>ALL</option>
		</select>
		<br>Item ID:<br>
		<input id='barcode' type="text" name='item_id' maxlength='14' size='14'>
		<!-- add the text field for optional barcode input. Submit will handle both functions. -->
		<div><input id='submit_barcode' class='go_button' type='image' src='images/go.png' alt='Submit'></div>
	</form>
	</div>
<script>
// Clears the input fields if you set focus on them.
$(document).ready(function(){
    $('input').on('click focusin', function() {
		this.value = '';
	});
	$("#submit_barcode").submit(function(e){
		if (e.which === '\n\n\n'){
			this.preventDefault();
		}
	});
});
</script>
</body>
</html>