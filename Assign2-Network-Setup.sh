#!/bin/bash

#########################################################################################
# Assignment 2 - Creating a Standalone Firewall.                                        #
#																						#
# Authors: Jivanjot S. Brar | A00774427  &&  Shan Bains | A00737179                     #
#																						#
# Usage: chmod +x Assign2-Network-Setup.sh  -->  ./Assign2-Network-Setup.sh             #
#########################################################################################



#########################################################################################
#                          USER CONFIGUREABLE SECTION                                   #
#########################################################################################
PRIMARY_INTERFACE="em1"
SECONDARY_INTERFACE="p3p1"
POST_ROUTE_IP="192.168.0.23"		# CHANGE THIS
SECONDARY_WK_IP="192.168.1.22"		# CHANGE THIS
SECONDARY_FW_IP="192.168.1.23"		# CHANGE THIS
INTERNAL_IP_SUB="192.168.1.0/24"	# CHANGE THIS
IP_FORWARD="1"

#########################################################################################
#                          DO NOT EDIT ANYTHING BELOW                                   #
#########################################################################################

echo ''
echo 'SETTING UP SECONDARY SUBNET & GATEWAY'
echo ''

iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

PS3='Are you a Firewall Host or Internal Workstation (Enter option Number): '
select opt in Work-Station Firewall Reset Exit
do
    case $opt in
	Work-Station) ########################## WORKSTATION RULES START HERE #################################
            ifconfig $PRIMARY_INTERFACE down
            ifconfig $SECONDARY_INTERFACE up
            ifconfig $SECONDARY_INTERFACE $SECONDARY_WK_IP
            ifconfig $SECONDARY_INTERFACE

            echo $IP_FORWARD > /proc/sys/net/ipv4/ip_forward

            #route del default gw 192.168.1.23 $SECONDARY_INTERFACE
            route add default gw $SECONDARY_FW_IP $SECONDARY_INTERFACE
            #route del -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.23 $SECONDARY_INTERFACE
            #route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.23 $SECONDARY_INTERFACE

            route -n
			
			echo 'domain ad.bcit.ca' > /etc/resolv.conf
			echo 'search ad.bcit.ca' > /etc/resolv.conf
			echo 'nameserver 142.232.191.38' > /etc/resolv.conf
			echo 'nameserver 142.232.191.39' > /etc/resolv.conf
			
            vim /etc/resolv.conf

            echo "[========================================================]"
            echo "[  WORKSTATION: SUBNET & GATEWAY SETUP COMPLETE          ]"
            echo "[========================================================]"
            echo ''
            break
            ;;  ########################## WORKSTATION RULES END HERE #################################
#
#
        Firewall) ########################## FIREWALL RULES START HERE #################################
            ifconfig $SECONDARY_INTERFACE $SECONDARY_FW_IP
            ifconfig $SECONDARY_INTERFACE
            
            #route del -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.0.23
            route add -net $INTERNAL_IP_SUB gw $SECONDARY_FW_IP $SECONDARY_INTERFACE
            route -n
            echo ''
            echo ''
            
            iptables -A POSTROUTING -t nat -s $INTERNAL_IP_SUB -o $PRIMARY_INTERFACE -j SNAT --to-source $POST_ROUTE_IP
            iptables -A PREROUTING -t nat -i $PRIMARY_INTERFACE -j DNAT --to-destination $SECONDARY_WK_IP

            iptables -L -x -v -t nat

            echo 'ip_forward'
            echo $IP_FORWARD > /proc/sys/net/ipv4/ip_forward
            cat /proc/sys/net/ipv4/ip_forward
            echo ''

            echo ''
            echo ''
            echo '/etc/resolv.conf'
            cat /etc/resolv.conf
            echo ''
            echo ''
            echo ''
            
            echo "[========================================================]"
            echo "[  FIREWALL: SUBNET & GATEWAY SETUP COMPLETE             ]"
            echo "[========================================================]"
            echo ''
            echo 'Deploying Firewall Rules'
            echo ''
            chmod +x Firewall_Rules.sh
            ./Firewall_Rules.sh
            break
            ;; ########################## FIREWALL RULES END HERE #################################

		Reset)
			
			ifconfig $PRIMARY_INTERFACE up
            ifconfig $SECONDARY_INTERFACE down
			
			iptables -F
			iptables -t nat -F
			iptables -X
			iptables -t nat -X

			iptables -P INPUT ACCEPT
			iptables -P OUTPUT ACCEPT
			iptables -P FORWARD ACCEPT
			
			echo "[========================================================]"
            echo "[  RESET COMPLETE                                        ]"
            echo "[========================================================]"
			
			break
			;;
			
        Exit)
		
            echo "[========================================================]"
            echo "[  SETUP ABORTED                                         ]"
            echo "[========================================================]"
            break
            ;;
        *) echo 'Invalid Option, Choose Appropriate Option Number';;
    esac
done
