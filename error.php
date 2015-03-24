
<h4 class="sub-header">Oops
<?php 
	ini_set('error_reporting', E_ALL);
	// phpinfo();
	$message = '';
	if (! empty($_GET['msg'])){
		$message = $_GET['msg'];
	}
	echo  html_entity_decode($message);
?>
</h5>
<p>
	<a href="index.php">
		<button type="button" class="btn btn-primary btn-block">
			<span class="glyphicon glyphicon-home"></span>
		</button>
	</a> 
</p>
<p class="text-center">
	ITS help?&nbsp;&nbsp;
	<a href='mailto:itshelp@epl.ca?Subject=AV%20incomplete%20Error%20 
	<?php echo htmlentities($message); ?>' target='_top'>
	<span class="glyphicon glyphicon-envelope"></span>
	</a>
</p>