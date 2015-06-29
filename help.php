<!DOCTYPE html>
<html lang="en">
<head>
  <title>AV Incomplete help</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  <link rel="stylesheet" href='css/style.css'>
  <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> -->
  <script src="js/jquery-2.1.1.min.js"></script>
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
		<li><a href="https://staffweb.epl.ca/"><img src="https://avatars2.githubusercontent.com/u/4293855?v=3&s=20"/></a></li>
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
		<h1 class="sub-header">Help</h1>
		<p>
AV incomplete is meant to do as much of the work for staff as possible, thus freeing up your time
for more important, and frankly, more interesting things. AV incomplete can do the following task:
<ul>
<li>Accept a typed or scanned bar code.</li>
<li>AV incomplete will queue you about the status of this item. For example if the other parts are waiting at another branch.</li>
<li>If you don't enter a itme id you will be taken to your selected branches AV incomplete list, where you can look up customer
information, make notes on the item, mark an item complete, and even discard an item.</li>
<li>The rest is taken care of. Behind the scenes AV incomplete will cancel holds on the item, discharge the item to make 
complete itmes available for customers.</li>
<li>Discarded items will have any holds cancelled and AV incomplete will charge the item to the selected branches' discard card.</li>
</ul>
For more information please refer to <a href="http://ilswiki.epl.ca/index.php/Avincomplete.pl">ILS Wiki</a>.
		</p>
		<h2 class="sub-header">Definition</h2>
		<p>
Any multi-part material (typically audio visual material, hence AV) whose 
enjoyment is impeded because part of it is missing. Examples include a CD or DVD 
cover that is dropped in a SmartChute, or a CD that is checked in via a sorter. 

In general:
Any circulate-able set of material <code>S</code> is said to be incomplete if 
missing any parts in the range of <code>p(0) to p(n-1)</code>, where p(0) 
is the RFID material and <code>p(1-n)</code> are the remaining un-RFID'ed parts.


Missing (or mis-matched) parts include:
<div class="list-group">
<a href="#" class="list-group-item active">Component</a>
<a href="#" class="list-group-item">Case</a>
<a href="#" class="list-group-item">Insert / booklet</a>
<a href="#" class="list-group-item">Disc 1</a>
<a href="#" class="list-group-item">Disc 'n'</a>
</div>
This can also be thought of in terms of an 'active' ingredient, like a DVD disc or a 'inactive' ingredient, like an insert or box.
<h2 class="sub-header">Project</h2>
<p>
Vicky is chairing the AV Incomplete group that is investigating how to reduce the 
number of AVSNAG items that end up as DISCARD. The following represents the 
proposed new AV incomplete method.
</p>

<h2 class="sub-header"> Background </h2>
<p>
In 2012, 20,307 items were returned incomplete to EPL branches. Of these items 2,259, 
valued at $59,575, were discarded as they were not matched up. Handling AV incomplete 
items is a time consuming process. A one month snapshot (January 25-February 25 2013) 
shows that EPL spends 150 hours of staff time per month working on AV incomplete items. 
The cost in both staff time and lost materials thus warranted a review of current 
AV incomplete procedures.
</p>

<h2 class="sub-header">Proposal</h2>
<p>
The AV Incomplete Review Team proposes the creation of a web services powered application 
that staff will use to mark items AV incomplete. Staff would access this application 
by navigating to a URL, and would then input an item ID for an incomplete item. 
The script would work in the following way:
</p>
<div class="list-group">
<a href="#" class="list-group-item active">Conditions</a>
<a href="#" class="list-group-item">If the script detects that this item is already on another branch's or 
the same branch's AV card, an alert is generated telling the staff member to send their piece to the other branch.</a> 
<a href="#" class="list-group-item">If the script does not detect that the item is already on an 
AV card, the item is discharged then checked out to the local branch's AV card. A copy level hold 
is placed on the item so that if the other piece appears at another branch the two pieces are matched up.</a>
<a href="#" class="list-group-item">If the previous customer has an email address on file, and email will be 
sent to the customer asking them to return the missing piece. No further follow up occurs.</a>
<a href="#" class="list-group-item">If the previous customer does not have an email address on file, 
the customer's barcode, phone number, and the title appears on a weekly AV contact list for that branch 
to phone. After the phone call is made, no further follow up occurs.</a>
<a href="#" class="list-group-item">After 3 months, items would be discarded from the AV incomplete 
shelves as per current procedures.</a>
</div>
<p>
The AV team proposes testing phone calls at 1 or 2 branches for 3 months to determine if this additional 
work adds any value to the process (ie. through a greater percentage of items returned, without increasing 
overall staff time spent on the process). If there is not an increase in the amount of material returned 
by customers during the pilot, customers could be notified by email only.
</p><p>
The AV team does not propose billing customers for items returned incomplete due to 
communication and customer service issues this method would present. If a customer were 
immediately billed for an incomplete item but returned the other piece to another branch, 
it would be difficult for staff to know that piece 1 was at branch A and piece 2 at 
branch B, as there is no "incomplete" status in Workflows. Additionally, some items 
would be checked in through smart chutes or sorters as the RFID tag was present, but 
would need to be checked back out or billed by staff. Without communicating to the 
customer why this is happening, customers may have difficulty interpreting their 
accounts online, and may have incomplete items marked as claims returned when they 
tell branch staff that they returned the item in question. Given that only 11% of 
the total number of AV incomplete items appear not to have been returned in 2012, 
it is anticipated that the complexity of managing a billing or checkout process 
would increase the staff time involved in AV incomplete processing while increasing 
customer confusion and would not significantly increase the amount or value of 
material returned.
		</p>

<div class="list-group">
<a href="#" class="list-group-item active">Goals and benefits</a>
<a href="#" class="list-group-item">The snags/incomplete process would be simplified, thus reducing errors.
<a href="#" class="list-group-item">Customers with email addresses will be notified about AV incomplete 
items they have returned, thus increasing the overall rate of returns for these items.</a>
<a href="#" class="list-group-item">Pieces of items that are at 2 branches will no longer inadvertently 
be discarded rather than matched up due to processing errors. Currently, staff do not check previous 
borrower information after items are discharged through sorters/smart chutes, resulting in items sitting 
on 2 separate branch AV shelves for 90 days and then discarded.</a>
<a href="#" class="list-group-item">Customers will now be billed for late fees for incomplete items 
that are returned late. As items are checked out to AV snags card with an override rather than 
discharged under current procedures, customers are not charged overdue fines for items returned late and incomplete.</a>
<a href="#" class="list-group-item">Provides statistics on loss and recovery of borrowed material.</a>

		</p>
	</div>
</div> <!-- container -->
</body></html>