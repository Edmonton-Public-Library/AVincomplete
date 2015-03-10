<html><head><title>AV Incomplete</title>
<style>
.error{
	color: red;
	margin-left: 100px;
    margin-right: auto;
}
</style>
<!-- <script src="js/jquery-2.1.1.min.js"></script> 
<script TYPE="text/javascript">
</script>-->
</head><body>
<img class='error' src='images/broken_robot.jpg'>

<?php 
ini_set('error_reporting', E_ALL);
// phpinfo();
$message = '';
if (! empty($_GET['msg'])){
	$message = $_GET['msg'];
}
echo "<div class='error'>Oh oh " . html_entity_decode($message) . "</div>";
?>
<p class='mail'>
<?php echo "<a href='mailto:itshelp@epl.ca?Subject=AV%20incomplete%20Error%20" . htmlentities($message) . "' target='_top'>If you get stuck...</a>"; ?>
</p>
</body></html>