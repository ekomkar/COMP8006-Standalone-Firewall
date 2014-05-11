#!/bin/bash

#########################################################################################
# ASSIGNMENT 2 - CREATING A STANDALONE FIREWALL		                                    #
#																						#
# AUTHORS: 	Jivanjot S. Brar 	| A00774427  											#
#			Shan Bains 			| A00737179                     						#
#																						#
# USAGE: chmod +x Firewall_Rules.sh  -->  ./Firewall_Rules.sh                           #
#########################################################################################

PS3='Do you wish to setup Firewall Rules(Yes/No): '
select opt in YES NO
do 
    case $opt in
        YES)
            #########################################################################################
            #                          USER CONFIGUREABLE SECTION                                   #
            #########################################################################################

            ALLOW_FIREWALL_DP=0

            PRIMARY_INTERFACE="em1"

            SECONDARY_INTERFACE="p3p1"

            POST_ROUTE_IP="192.168.0.23"    	# CHANGE THIS

            INTERNAL_IP_SUB="192.168.1.0/24"	# CHANGE THIS

            SECONDARY_WK_IP="192.168.1.22"		# CHANGE THIS

            SECONDARY_FW_IP="192.168.1.23"		# CHANGE THIS

            ANYADDR="0/0"

            TCP_ALLOWED_PORTS_IN="20,21,22,53,80,443"

            TCP_ALLOWED_PORTS_OUT="20,21,22,53,80,443"

            PORT_NOT_ALLOWED="23"

            UDP_ALLOWED_PORTS_IN="53,67,68,80"

            UDP_ALLOWED_PORTS_OUT="53,67,68,80"

            MINIMUM_DELAYS="ssh,ftp"

            MAXIMUM_THROUGHOUT="ftp-data"

            ICMP_TYPES="echo-request, echo-reply, source-quench, time-exceeded, destination-unreachable, network-unreachable, host-unreachable, protocol-unreachable, port-unreachable"

            ICMP="0,3,8"
            #ICMP="0,3,4,5,8,11,12,13,14,15,16,17,18"

            DROP_SYN_PORTS="1024:65535"

            DROP_EXT_UDP_PORT_TRAFFIC="32768:32775,137:139"

            DROP_EXT_TCP_PORT_TRAFFIC="32768:32775,137:139,111,515"


            #########################################################################################
            #                          DO NOT EDIT ANYTHING BELOW                                   #
            #########################################################################################

            iptables -F
            iptables -X

            iptables -P INPUT ACCEPT
            iptables -P OUTPUT ACCEPT
            iptables -P FORWARD ACCEPT


            iptables -P INPUT DROP 
            iptables -P OUTPUT DROP
            iptables -P FORWARD DROP

            #iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -j ACCEPT
            #iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -j ACCEPT
			
			#
			# RULES TO ALLOW WEB TRAFFIC ON THE FIREWALL MACHINE
			#
            if [ $ALLOW_FIREWALL_DP -eq 1 ]; then 

                    # TCP DNS
                    iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
                    iptables -A INPUT -p tcp --sport 53 -j ACCEPT
                    # UDP DNS
                    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
                    iptables -A INPUT -p udp --sport 53 -j ACCEPT

                    # 6. Allowing DHCP Services
                    iptables -A OUTPUT -p udp --dport 67:68 -j ACCEPT
                    iptables -A INPUT -p udp --sport 67:68 -j ACCEPT

                    # 12. Allowing Inbound HTTPS (port 443)
                    iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
                    iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

                    # 13. Allowing Outbound HTTPS (port 443)
                    iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
                    iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

                    iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
                    iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

                    # 13. Allowing Outbound HTTPS (port 443)
                    iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
                    iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
            fi 


            ########################## FIREWALL RULES START HERE #################################


            # TCP DNS
            iptables -A FORWARD -p tcp --dport 53 -j ACCEPT
            iptables -A FORWARD -p tcp --sport 53 -j ACCEPT

            # UDP DNS
            iptables -A FORWARD -p udp --dport 53 -j ACCEPT
            iptables -A FORWARD -p udp --sport 53 -j ACCEPT

            # 6. Allowing DHCP Services
            iptables -A FORWARD -p udp --dport 67:68 -j ACCEPT
            iptables -A FORWARD -p udp --sport 67:68 -j ACCEPT

			# FTP and SSH services, set control connections to "Minimum Delay" and FTP data to "Maximum Throughput
            iptables -A PREROUTING -t mangle -p tcp -m multiport --sport 22 -j TOS --set-tos Minimize-Delay 
            iptables -A PREROUTING -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay 
            iptables -A PREROUTING -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput

            # Inbound TCP packets on allowed port
            iptables -A FORWARD -o $SECONDARY_INTERFACE -i $PRIMARY_INTERFACE -p tcp -m multiport --dport $TCP_ALLOWED_PORTS_IN -m state --state NEW,ESTABLISHED -j ACCEPT
            iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p tcp -m multiport --sport $TCP_ALLOWED_PORTS_IN -m state --state ESTABLISHED   -j ACCEPT

            # Outbound TCP packets on allowed port
            iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p tcp -m multiport --dport $TCP_ALLOWED_PORTS_OUT -m state --state NEW,ESTABLISHED  -j ACCEPT
            iptables -A FORWARD -o $SECONDARY_INTERFACE -i $PRIMARY_INTERFACE -p tcp -m multiport --sport $TCP_ALLOWED_PORTS_OUT -m state --state ESTABLISHED  -j ACCEPT

            
            # Inbound UDP packets on allowed port	
            #iptables -A FORWARD -p udp -m multiport --dport $UDP_ALLOWED_PORTS_IN  -j ACCEPT
            #iptables -A FORWARD -p udp -m multiport --sport $UDP_ALLOWED_PORTS_IN  -j ACCEPT
			#iptables -A FORWARD -o $SECONDARY_INTERFACE -i $PRIMARY_INTERFACE -p udp -m multiport --dport $UDP_ALLOWED_PORTS_IN  -j ACCEPT
            #iptables -A FORWARD -o $PRIMARY_INTERFACE -i $SECONDARY_INTERFACE -p udp -m multiport --sport $UDP_ALLOWED_PORTS_IN  -j ACCEPT
            iptables -A FORWARD -m multiport -p udp -i $PRIMARY_INTERFACE --dport $UDP_ALLOWED_PORTS_IN -j ACCEPT
            iptables -A FORWARD -m multiport -p udp -i $SECONDARY_INTERFACE --sport $UDP_ALLOWED_PORTS_IN -j ACCEPT

            # Outbound UDP packets on allowed port
            #iptables -A FORWARD -p udp -m multiport --dport $UDP_ALLOWED_PORTS_OUT  -j ACCEPT
            #iptables -A FORWARD -p udp -m multiport --sport $UDP_ALLOWED_PORTS_OUT  -j ACCEPT
            #iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p udp -m multiport --dport $UDP_ALLOWED_PORTS_OUT  -j ACCEPT
            #iptables -A FORWARD -o $SECONDARY_INTERFACE -i $PRIMARY_INTERFACE -p udp -m multiport --sport $UDP_ALLOWED_PORTS_OUT  -j ACCEPT
            iptables -A FORWARD -m multiport -p udp -i $SECONDARY_INTERFACE -d $ANYADDR --dport $UDP_ALLOWED_PORTS_OUT -j ACCEPT
            iptables -A FORWARD -m multiport -p udp -i $PRIMARY_INTERFACE -s $ANYADDR --sport $UDP_ALLOWED_PORTS_OUT -j ACCEPT
            
			# Accept fragments
            iptables -A FORWARD -f -j ACCEPT
            
			# Do not accept any packets with a source address from the outside matching your internal network ***********
            iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -s $INTERNAL_IP_SUB -j DROP

            # You must ensure that you reject those connections that are coming the "wrong" way (i.e.,inbound SYN packets to high port)
            iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p tcp --syn --dport $DROP_SYN_PORTS -j DROP

            # DROP ALL Telnet traffic
            iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p tcp -m multiport --dport $PORT_NOT_ALLOWED -j DROP
            iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p tcp -m multiport --sport $PORT_NOT_ALLOWED -j DROP

            # DROP all external traffic that is directed towards ports 32768 - 32775,137 - 139 and tcp ports111 & 515
            # UDP
            iptables -A FORWARD -o $SECONDARY_INTERFACE -i $PRIMARY_INTERFACE -p udp -m multiport --dport $DROP_EXT_UDP_PORT_TRAFFIC -j DROP
            iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p udp -m multiport --dport $DROP_EXT_UDP_PORT_TRAFFIC -j DROP
            # TCP
            iptables -A FORWARD -o $SECONDARY_INTERFACE -i $PRIMARY_INTERFACE -p tcp -m multiport --dport $DROP_EXT_TCP_PORT_TRAFFIC -j DROP
            iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p tcp -m multiport --dport $DROP_EXT_TCP_PORT_TRAFFIC -j DROP
            

			#[========================================={ ICMP }=========================================]

			if [ `echo $ICMP | grep -c "0" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 0 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 0 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "3" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 3 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 3 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "4" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 4 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 4 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "5" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 5 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 5 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "8" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 8 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 8 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "11" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 11 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 11 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "12" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 12 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 12 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "13" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 13 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 13 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "14" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 14 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 14 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "15" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 15 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 15 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "16" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 16 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 16 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "17" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 17 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 17 -j ACCEPT
			fi
			if [ `echo $ICMP | grep -c "18" ` -gt 0 ]
			then
				 # Inbound / Outbound ICMP packets based on type numbers
						iptables -A FORWARD -i $PRIMARY_INTERFACE -o $SECONDARY_INTERFACE -p icmp --icmp-type 18 -j ACCEPT
						iptables -A FORWARD -i $SECONDARY_INTERFACE -o $PRIMARY_INTERFACE -p icmp --icmp-type 18 -j ACCEPT
			fi


            echo "[========================================================]"
            echo "[  STANDALONE FIREWALL RULES DEPLOYED                    ]"
            echo "[========================================================]"
            echo ''
            echo ''
            echo ''

            break
            ;;
        NO)
			iptables -F
            iptables -X
            iptables -t nat -F
            iptables -t nat -X

            iptables -P INPUT ACCEPT
            iptables -P OUTPUT ACCEPT
            iptables -P FORWARD ACCEPT
        
            echo "[========================================================]"
            echo "[  SETUP ABORTED                                         ]"
            echo "[========================================================]"
            
            break
            ;;
    esac
done
