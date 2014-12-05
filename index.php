<html>
<head>
<title>AV Incomplete</title>
<?php 
	ini_set('error_reporting', E_ALL);
	require 'db_func.php.inc';
	// phpinfo();
	echo "<title>AV Incomplete</title>";
?>
<link rel="stylesheet" type="text/css" href="css/stats.css">
</head>
<body>
<?php
  $branch = "";
  if (! isset($_COOKIE['branch_name'])){
    echo "<h2>Select your branch</h2>";
  	echo "<form action='form_data.php' method='POST'>";
    echo "<select name='branch_name'>";
    echo "<option value='MNA'>MNA</option>";
    echo "<option value='MLW'>MLW</option>";
    echo "<option value='WMC'>WMC</option>";
    echo "<option value='LHL'>LHL</option>";
    echo "<option value='LON'>LON</option>";
    echo "<option value='JPL'>JPL</option>";
    echo "<option value='HIG'>HIG</option>";
    echo "<option value='WOO'>WOO</option>";
    echo "<option value='STR'>STR</option>";
    echo "<option value='CLV'>CLV</option>";
    echo "<option value='MEA'>MEA</option>";
    echo "<option value='CAL'>CAL</option>";
    echo "<option value='CSD'>CSD</option>";
    echo "<option value='IDY'>IDY</option>";
    // echo "<option value='LES'>LES</option>"; // Lewis estates when available.
    echo "<option value='RIV'>RIV</option>";
    echo "<option value='SPW'>SPW</option>";
    echo "<option value='CPL'>CPL</option>";   
    echo "</select>";
    echo "<div><input type='submit' value='submit'></div>";
    echo "</form>";
  } else {
    echo "<p class='current_branch'>branch set to: <b>" . $_COOKIE['branch_name'] . "</b>. If this is incorrect delete the related cookie.</p>";
    $branch = $_COOKIE['branch_name'];
    echo "<form action='item_data.php' method='GET'>";
    echo '<input type="text" name="itemId">';
    echo '<div id="submit_itemId"><input type="submit" value="Go"></div>';
    echo "</form>";
  }
  
?>
</body>
</html>