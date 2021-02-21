########################################################################
# Makefile for project pipe 
# Created: Mon May 25 15:12:15 MDT 2015
#
# Moves the driver script notify_customers.sh to EPLAPP working directory.
#    Copyright (C) 2015  Andrew Nisbet
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# Written by Andrew Nisbet at Edmonton Public Library
# Rev: 
#      0.0 - Dev. 
########################################################################
# Change comment below for appropriate server.
PRODUCTION_SERVER=edpl.sirsidynix.net
USER=sirsi
REMOTE=/software/EDPL/Unicorn/EPLwork/cronjobscripts/Mailerbot/AVIncomplete/
LOCAL=~/projects/avincomplete/db/
APP=notify_customers.sh
.PHONY: production
test_running:
	ps aux | grep avincomplete
production:
	scp ${LOCAL}${APP} ${USER}@${PRODUCTION_SERVER}:${REMOTE}

