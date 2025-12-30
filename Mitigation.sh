#!/bin/bash

# Thames Water Immediate Containment Script
# Blocks C2 communication and unauthorized Modbus traffic.

echo "[+] Implementing Thames Water Incident Containment Rules..."

# Block all traffic to/from the malicious C2 server
iptables -A INPUT -s 198.51.100.12 -j DROP
iptables -A OUTPUT -d 198.51.100.12 -j DROP
echo "[+] Blocked all traffic to/from C2 server 198.51.100.12"

# Restrict Modbus (port 502) to authorized engineering subnet ONLY
# This rule DROPs Modbus traffic from any source NOT in the 10.0.1.0/24 subnet.
iptables -A INPUT -p tcp --dport 502 ! -s 10.0.1.0/24 -j DROP
echo "[+] Restricted Modbus/TCP port 502 to authorized engineering subnet (10.0.1.0/24) only."

# Log the blocked packets for forensics
iptables -A INPUT -s 198.51.100.12 -j LOG --log-prefix "BLOCKED_C2_IN: "
iptables -A OUTPUT -d 198.51.100.12 -j LOG --log-prefix "BLOCKED_C2_OUT: "
iptables -A INPUT -p tcp --dport 502 ! -s 10.0.1.0/24 -j LOG --log-prefix "BLOCKED_UNAUTH_MODBUS: "
echo "[+] Logging rules applied. Check /var/log/kern.log or /var/log/messages for logs."

echo "[+] Immediate containment measures completed successfully."