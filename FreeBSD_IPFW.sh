#!/bin/sh

echo "Configuring FreeBSD Firewall with IPFW for High Performance."

# Enable IPFW in rc.conf
sysrc firewall_enable="YES"
sysrc firewall_type="open"  # Change to "workstation" or "client" if needed
sysrc firewall_logging="YES"

# Enable Dummynet for Traffic Shaping
sysrc dummynet_enable="YES"

# Load necessary kernel modules
kldload dummynet
kldload ipfw
kldload ipdivert

# Optimize Kernel for Multi-Threaded Packet Processing
sysctl net.isr.maxthreads=$(sysctl -n hw.ncpu)  # Set threads equal to CPU cores
sysctl net.isr.bindthreads=1                     # Bind threads to CPUs
sysctl net.isr.dispatch=deferred                 # Improve efficiency in high-load conditions
sysctl net.inet.tcp.fastforwarding=1             # Enable fast forwarding for performance
sysctl net.inet.ip.dummynet.io_fast=1            # Optimize Dummynet

# Create Basic IPFW Rules
echo "Setting up firewall rules..."
ipfw -q flush  # Clear existing rules

ipfw add 100 allow ip from any to any via lo0
ipfw add 200 deny ip from any to 127.0.0.0/8
ipfw add 300 deny ip from 127.0.0.0/8 to any
ipfw add 400 allow ip from any to any established
ipfw add 500 allow tcp from any to any out keep-state
ipfw add 600 allow udp from any to any out keep-state
ipfw add 700 allow icmp from any to any
ipfw add 800 deny log all from any to any  # Block everything else

# Setup Dummynet Traffic Shaping (Example: Limit bandwidth for a specific IP)
ipfw pipe 1 config bw 100Mbit/s delay 10ms
ipfw add 900 pipe 1 ip from any to 192.168.1.100  # Limit this IP to 100 Mbps

# Save IPFW rules
service ipfw start
service ipfw save

echo "IPFW firewall setup complete!"
