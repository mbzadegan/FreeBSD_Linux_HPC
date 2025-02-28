#!/bin/bash

# Ensure you are running this script as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Starting HPC Customization for Ubuntu..."

# Step 1: Update and install essential packages
echo "Updating system and installing essential packages..."
apt update && apt upgrade -y
apt install -y build-essential cmake gcc gfortran openmpi-bin openmpi-common libopenmpi-dev \
liblapack-dev libblas-dev libfftw3-dev slurm-wlm nvidia-cuda-toolkit

# Step 2: Disable unnecessary services
echo "Disabling unnecessary services..."
systemctl disable apache2
systemctl disable bluetooth
systemctl stop apache2
systemctl stop bluetooth

# Step 3: Disable Swap
echo "Disabling swap..."
swapoff -a
sed -i '/swap/d' /etc/fstab

# Step 4: Optimize File System (noatime, nodiratime)
echo "Optimizing file system for I/O..."
sed -i 's/defaults/noatime,nodiratime/' /etc/fstab

# Step 5: Set CPU Governor to Performance
echo "Setting CPU governor to performance mode..."
cpufreq-set -g performance

# Step 6: Enable HugePages (for large memory usage applications)
echo "Enabling HugePages for better memory management..."
echo "vm.nr_hugepages=1024" >> /etc/sysctl.conf
sysctl -p

# Step 7: Optimize Networking (TCP buffer size)
echo "Optimizing network settings for high throughput..."
sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sysctl -w net.ipv4.tcp_wmem="4096 87380 16777216"

# Step 8: Set I/O Scheduler to "noop"
echo "Setting I/O scheduler to 'noop' for high throughput..."
echo "noop" > /sys/block/sda/queue/scheduler

# Step 9: Install Real-Time Kernel (Optional)
echo "Installing Real-Time Kernel..."
apt install -y linux-image-rt

# Step 10: Configure CPU Affinity (example for 4 cores)
echo "Configuring CPU Affinity (example for 4 cores)..."
echo "taskset -c 0-3 ./my_hpc_program" >> ~/.bashrc

# Step 11: Install Slurm for Job Scheduling
echo "Installing Slurm for workload management..."
apt install -y slurm-wlm

# Step 12: Configure and Install custom kernel (optional)
echo "Downloading and configuring custom kernel..."
cd /usr/src
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.x.x.tar.xz
tar -xvf linux-5.x.x.tar.xz
cd linux-5.x.x
make menuconfig  # You will need to manually configure the kernel. Follow the interactive menu.
make
make modules_install
make install

# Step 13: Remove Swap entry from /etc/fstab
echo "Removing swap entry from /etc/fstab..."
sed -i '/swap/d' /etc/fstab

# Step 14: Reboot the system
echo "Customization complete! Rebooting system for changes to take effect..."
reboot

