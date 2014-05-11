#!/bin/bash

############################################################################
# Authors: Jivanjot S. Brar | A00774427  &&  Shan Bains | A00737179
# Date: 02.07.2014
# Usage: chmod +x monitor.sh  -->  ./monitor.sh
############################################################################

while true
do
	clear
	#iptables -t nat -v -L
	echo ''
	echo '[============================================{MONITORING}============================================]'
	iptables -L -n -v
	echo ''
	iptables -t nat -L PREROUTING
	echo ''
	iptables -t nat -L POSTROUTING
	sleep 1
done