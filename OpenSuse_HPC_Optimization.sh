#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


echo "Tuning openSUSE for Multi-threading and HPC Performance..."

# Set CPU governor to performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance > "$cpu"
done
echo "CPU governor set to performance"

# Enable NUMA balancing
echo 1 > /proc/sys/kernel/numa_balancing
echo "NUMA balancing enabled."

# Set kernel scheduler tuning for HPC
sysctl -w kernel.sched_min_granularity_ns=10000000
sysctl -w kernel.sched_wakeup_granularity_ns=15000000
echo "Scheduler tuned for HPC workloads."

# Increase maximum number of open file descriptors
ulimit -n 1048576
echo "Max open files increased."

# Enable hugepages for better memory performance
echo 1 > /sys/kernel/mm/transparent_hugepage/enabled
echo 1 > /sys/kernel/mm/transparent_hugepage/defrag
echo "Transparent hugepages enabled."

# Optimize network settings for high-performance computing
sysctl -w net.core.rmem_max=134217728
sysctl -w net.core.wmem_max=134217728
sysctl -w net.core.rmem_default=134217728
sysctl -w net.core.wmem_default=134217728
echo "Network buffer sizes optimized."

# Disable unneeded services to free up CPU resources
systemctl disable cups
systemctl disable bluetooth
systemctl disable avahi-daemon
echo "Unnecessary services disabled."

# Apply tuned performance profile if installed
if command -v tuned-adm &> /dev/null; then
    tuned-adm profile throughput-performance
    echo "Tuned profile set to throughput-performance."i

# Set swappiness to a lower value for better memory performance
sysctl -w vm.swappiness=10
echo "Swappiness set to 10."

# Reload sysctl settings
sysctl -p

echo "HPC tuning complete. Please reboot for all changes to take effect."
