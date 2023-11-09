
# AV Incomplete

## New to This Version

* Items that have LOST bills must necessarily have been attended to by staff and they have decided to charge the customer, so there is no need to store these in AVIncomplete.

## Product Description

Perl script and PHP web site written by Andrew Nisbet for Edmonton Public Library, and is distributable by the enclosed license.

Definition: any audio visual material whose enjoyment is impeded because part of it is missing.

or more specifically:

A multi-part circulate-able material that is missing one or more parts. Examples include a CD or DVD cover that is dropped in a SmartChute, or a CD that is checked in via a sorter. In general:


Any circulate-able set of material S is said to be incomplete if missing any parts in the range of p(0)-p(n-1), where p(0) is the RFID material and p(1-n) are the remaining un-RFID'ed parts.


Missing (or mis-matched) parts include:

Case
* Insert
* Disc 1
* Disc 'n'
This can also be thought of in terms of an 'active' ingredient, like a DVD disc or a 'inactive' ingredient, like an insert or box.

## Background

In 2012, 20,307 items were returned incomplete to EPL branches. Of these items 2,259, valued at $59,575, were discarded as they were not matched up. Handling AV incomplete items is a time consuming process. A one month snapshot (January 25-February 25 2013) shows that EPL spends 150 hours of staff time per month working on AV incomplete items. The cost in both staff time and lost materials thus warranted a review of current AV incomplete procedures.

## Proposal

The AV Incomplete Review Team proposes the creation of a web services powered application that staff will use to mark items AV incomplete. Staff would access this application by navigating to a URL, and would then input an item ID for an incomplete item. The script would work in the following way:

If the script detects that this item is already on another branch’s or the same branch’s AV card, an alert is generated telling the staff member to send their piece to the other branch.
If the script does not detect that the item is already on an AV card, the item is discharged then checked out to the local branch’s AV card. A copy level hold is placed on the item so that if the other piece appears at another branch the two pieces are matched up.
If the previous customer has an email address on file, and email will be sent to the customer asking them to return the missing piece. No further follow up occurs.
If the previous customer does not have an email address on file, the customer’s barcode, phone number, and the title appears on a weekly AV contact list for that branch to phone. After the phone call is made, no further follow up occurs.
After 3 months, items would be discarded from the AV incomplete shelves as per current procedures.
The AV team proposes testing phone calls at 1 or 2 branches for 3 months to determine if this additional work adds any value to the process (ie. through a greater percentage of items returned, without increasing overall staff time spent on the process). If there is not an increase in the amount of material returned by customers during the pilot, customers could be notified by email only.

The AV team does not propose billing customers for items returned incomplete due to communication and customer service issues this method would present. If a customer were immediately billed for an incomplete item but returned the other piece to another branch, it would be difficult for staff to know that piece 1 was at branch A and piece 2 at branch B, as there is no “incomplete” status in Workflows. Additionally, some items would be checked in through smart chutes or sorters as the RFID tag was present, but would need to be checked back out or billed by staff. Without communicating to the customer why this is happening, customers may have difficulty interpreting their accounts online, and may have incomplete items marked as claims returned when they tell branch staff that they returned the item in question. Given that only 11% of the total number of AV incomplete items appear not to have been returned in 2012, it is anticipated that the complexity of managing a billing or checkout process would increase the staff time involved in AV incomplete processing while increasing customer confusion and would not significantly increase the amount or value of material returned.


## Goals and Benefits

The AV team believes the above approach will confer the following benefits:

The snags/incomplete process would be simplified, thus reducing errors.
Customers with email addresses will be notified about AV incomplete items they have returned, thus increasing the overall rate of returns for these items.
Pieces of items that are at 2 branches will no longer inadvertently be discarded rather than matched up due to processing errors. Currently, staff do not check previous borrower information after items are discharged through sorters/smart chutes, resulting in items sitting on 2 separate branch AV shelves for 90 days and then discarded.
Customers will now be billed for late fees for incomplete items that are returned late. As items are checked out to AV snags card with an override rather than discharged under current procedures, customers are not charged overdue fines for items returned late and incomplete.
Provides statistics on loss and recovery of borrowed material.

* If the script detects that this item is already on another branch’s or the same branch’s AV card, an alert is generated telling the staff member to send their piece to the other branch.

* If the script does not detect that the item is already on an AV card, the item is discharged then checked out to the local branch’s AV card. A copy level hold is placed on the item so that if the other piece appears at another branch the two pieces are matched up.

* If the previous customer has an email address on file, and email will be sent to the customer asking them to return the missing piece. No further follow up occurs.

* If the previous customer does not have an email address on file, the customer’s barcode, phone number, and the title appears on a weekly AV contact list for that branch to phone. After the phone call is made, no further follow up occurs.

* After 3 months, items would be discarded from the AV incomplete shelves as per current procedures.

## avincomplete.pl

Creates and manages av incomplete sqlite3 database. Note: -c and -d flags rebuild the avsnag cards and discard cards for a branch based on profiles. The branch id must appear as the first 3 letters of its name like: SPW-AVSNAG, or RIV-DISCARD, for a discard card.

## Repository Information

This product is under version control using Git at [av incomplete](https://github.com/anisbet/AVincomplete).

## Dependencies

* sqlite3 - Which is available on systems through modern versions of python.
* [cancelholds.pl](https://github.com/Edmonton-Public-Library/cancelholds)
* [pipe.pl](https://github.com/anisbet/pipe)
* [dischargeitem.pl](https://github.com/Edmonton-Public-Library/dischargeitem)
* [chargeitems.pl](https://github.com/Edmonton-Public-Library/chargeitems)

## Known Issues

CSS fixes due.