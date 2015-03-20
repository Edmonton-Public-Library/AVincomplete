<!DOCTYPE html>
<html lang="en">
<head>
  <title>AV Incomplete</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  <link rel="stylesheet" href='css/style.css'>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
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
	  <a class="navbar-brand" href="index.php">EPL AV Incomplete</a>
	</div>
	<div id="navbar" class="navbar-collapse collapse">
	  <ul class="nav navbar-nav navbar-right">
		<li><a href="index.php"><span class="glyphicon glyphicon-home"></span></a></li>
		<li><a href="branch_items.php?branch=ALL"><span class="glyphicon glyphicon-wrench"></span></a></li>
		<li><a href="help.php"><span class="glyphicon glyphicon-info-sign"></span></a></li>
	  </ul>
	  <form class="navbar-form navbar-right">
		<input type="text" class="form-control" placeholder="Search...">
	  </form>
	</div>
  </div>
</nav>
<div class="container-fluid">
	<div class="col-sm-7">
	<h2 class="sub-header">Ok</h2>
	<div class='row'>
		<div class='col-md-2'>
			<p/>
				</div>
				<div class='col-md-4'>
						<p><?php 
							ini_set('error_reporting', E_ALL);
							// phpinfo();
							$message = '';
							if (! empty($_GET['msg'])){
								$message = $_GET['msg'];
							}
							echo  html_entity_decode($message);
						?>
						</p>
				<a href="index.php">
					<button type="button" class="btn btn-primary btn-block">
						<span class="glyphicon glyphicon-home"></span>
					</button>
				</a> 
			</p>
		</div>
	</div> <!-- columns -->
</div> <!-- container -->
</body></html>