#!/bin/sh
####################################################################################### 
# File:   Test_Script.sh
#
# Authors: Jivanjot S. Brar | A00774427  &&  Shan Bains | A00737179 
#
# Usage: chmod +x Test_Script.sh -->  ./Test_Script.sh > Test_Results.txt
#
# Created on Feb 9, 2014, 6:17:14 PM
#######################################################################################


#######################################################################################
#                          USER CONFIGUREABLE SECTION                                 #
#######################################################################################


EXT_IP="192.168.0.23"
SECONDARY_WK_IP="192.168.1.22"


#######################################################################################
#                           Testing scripts - Don't change                            #
#######################################################################################

echo "################################################################################"
echo "# FIREWALL TESTING STARTS AT `date`                                            #"
echo "################################################################################"
echo
echo
echo
echo
echo "[=====================================================================================]"
echo "[ 1) TESTING NMAP SCAN OF THE FIREWALL: SHOULD SHOW PORT 22, 80, 443 AND 11 OPEN AT LEAST"
nmap -T4 -A -v $EXT_IP

echo
echo
echo "[===============================================================================]"
echo "[==================================={ TCP }=====================================]"
echo "[===============================================================================]"
echo
echo "[ 2) TESTING TCP PACKETS ON ALLOWED PORTS 22, SHOULD BE 0% PACKET LOSS"
hping3 $EXT_IP -c 3 -S -p 22

echo
echo
echo "[========================================================================]"
echo "[ 3) TESTING TCP PACKETS ON ALLOWED PORTS 80, SHOULD BE 0% PACKET LOSS"
hping3 $EXT_IP -c 3 -S -p 80

echo
echo
echo "[========================================================================]"
echo "[ 4) TESTING TCP PACKETS ON ALLOWED PORTS 443, SHOULD BE 0% PACKET LOSS"
hping3 $EXT_IP -c 3 -S -p 80

echo
echo
echo "[========================================================================]"
echo "[ 5) TESTING FOR NOT ALLOWABLE TCP PORTS(eg. port 111), SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP -c 3 -p 111 -S

echo
echo
echo "[===============================================================================]"
echo "[==================================={ UDP }=====================================]"
echo "[===============================================================================]"
echo
echo "[ 6) TESTING UDP PACKETS ON ALLOWED PORTS 53, SHOULD BE 0% PACKET LOSS"
hping3 $EXT_IP --udp -c 3 -p 80

echo
echo
echo "[========================================================================]"
echo "[ 7) TESTING UDP PACKETS ON NOT ALLOWED PORTS 137, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP --udp -c 3 -p 137

echo
echo
echo "[================================================================================]"
echo "[==================================={ ICMP }=====================================]"
echo "[================================================================================]"
echo
echo "[ 8) TESTING ICMP PACKETS ON ALLOWED PORTS USING PING, SHOULD BE 0% PACKET LOSS"
ping $EXT_IP -c 3

echo
echo
echo "[========================================================================]"
echo "[ 9) TESTING ICMP PACKETS ON NOT ALLOWED PORTS, SHOULD BE 100% PACKET LOSS"
#hping3 --traceroute -V -1 $EXT_IP -c 3

echo
echo
echo "[========================================================================]"
echo "[ 10) TESTING DROP PACKETS WITH A SOURCE ADDRESS FROM THE OUTSIDE MATCHING YOUR"
echo "[     INTERNAL NETWORK, SHOULD BE 100% PACKET LOSS "
hping3 $EXT_IP -c 3 --spoof $SECONDARY_WK_IP

echo
echo
echo "[========================================================================]"
echo "[ 11) TESTING ACCEPT FRAGMENTS, SHOULD BE 0% PACKET LOSS"
hping3 $EXT_IP -c 3 -f -p 443 -d 200 -S

echo
echo
echo "[========================================================================]"
echo "[ 12) TESTING SYN PACKETS THAT ARE COMMING THE THE WRONG WAY (i.e. high ports)"
echo "[ SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP -c 3 -p 1025 -S

echo 
echo
echo "[========================================================================]"
echo "[ 13) TESTING, ACCEPT ALL TCP CONNECTIONS THAT BELONG TO AN EXISTING CONNECTION, SHOULD BE 0% LOSS]"
hping3 $EXT_IP -A -c 3 -p 80

echo 
echo
echo "[========================================================================]"
echo "[ 14) TESTING DROP INCOMING TCP PACKETS WITH BOTH SYN,FIN ARGUMENTS SET, SHOULD BE 100% LOSS]"
hping3 $EXT_IP -S -F -c 3 -p 80

echo
echo
echo "[========================================================================]"
echo "[ 15) TESTING DROP ALL TELNET PACKETS, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP -c 3 -p 23 -S

echo
echo
echo "[========================================================================]"
echo "[ 16) TESTING DROP INCOMING UDP PACKETS BETWEEN 32768-32775, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP --udp -c 3 -p 32769

echo
echo
echo "[========================================================================]"
echo "[ 17) TESTING DROP INCOMING UDP PACKETS BETWEEN 137-139, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP --udp -c 3 -p 138

echo
echo
echo "[========================================================================]"
echo "[ 18) TESTING DROP INCOMING TCP PACKETS BETWEEN 32768-32775, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP -S -c 3 -p 32770

echo
echo
echo "[========================================================================]"
echo "[ 19) TESTING DROP INCOMING TCP PACKETS BETWEEN 137-139, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP -S -c 3 -p 138

echo
echo
echo "[========================================================================]"
echo "[ 20) TESTING DROP INCOMING TCP PACKETS TO PORT 111, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP -S -c 3 -p 111

echo
echo
echo "[========================================================================]"
echo "[ 21) TESTING DROP INCOMING TCP PACKETS TO PORT 515, SHOULD BE 100% PACKET LOSS"
hping3 $EXT_IP -S -c 3 -p 515

echo
echo
echo "################################################################################"
echo "# FIREWALL TESTING ENDED AT `date`                                             #"
echo "################################################################################"
