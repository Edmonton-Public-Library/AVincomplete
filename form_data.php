<?php
if (!empty($_POST)) {
 	// set the cookie with the submitted user data
	setcookie('branch_name',$_POST['branch_name']);
	// redirect the user to final landing page so cookie info is available
  	header("Location:index.php");
}
?>
