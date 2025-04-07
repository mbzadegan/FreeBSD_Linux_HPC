#!/bin/bash
# Gentoo/Calculate Linux Optimization Script for Multi-Threaded Performance
# Run this script as root

set -e

echo "Starting system optimization.."

# 1. Optimize Kernel Parameters
sysctl -w kernel.sched_autogroup_enabled=0
sysctl -w vm.swappiness=1
sysctl -w vm.nr_hugepages=1024
sysctl -w net.core.somaxconn=65535
sysctl -w net.ipv4.tcp_fastopen=3
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.ip_local_port_range="1024 65535"

# Persist kernel settings
echo "kernel.sched_autogroup_enabled=0" >> /etc/sysctl.conf
echo "vm.swappiness=1" >> /etc/sysctl.conf
echo "vm.nr_hugepages=1024" >> /etc/sysctl.conf
echo "net.core.somaxconn=65535" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse=1" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range=1024 65535" >> /etc/sysctl.conf
sysctl -p

# 2. Set CPU Governor to Performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "performance" > "$cpu"
done

# 3. Set File Limits
cat <<EOF >> /etc/security/limits.conf
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 1048576
* hard nproc 1048576
EOF

# 4. Optimize Filesystem I/O
for disk in /sys/block/sd*; do
    echo bfq > "$disk/queue/scheduler"
done

# 5. Enable OpenMP in GCC
emerge --ask sys-devel/gcc --newuse openmp

echo "Optimization complete. Please reboot your system."
