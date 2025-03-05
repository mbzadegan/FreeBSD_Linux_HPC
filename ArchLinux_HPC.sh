#!/bin/bash

# Update system
echo "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install necessary tools and libraries
echo "Installing essential packages for HPC..."
sudo pacman -S --noconfirm \
    base-devel \
    gcc \
    clang \
    openmpi \
    libomp \
    boost \
    cmake \
    blas \
    lapack \
    hdf5 \
    python \
    python-pip \
    numactl \
    fftw \
    mpich \
    intel-mkl \
    intel-mpi \
    make \
    git \
    unzip \
    vim \
    nano

# Enable and start the OpenMPI service
echo "Enabling and starting OpenMPI service..."
sudo systemctl enable openmpi
sudo systemctl start openmpi

# Configure CPU governor for performance (e.g., set to 'performance' mode)
echo "Setting CPU governor to performance..."
echo 'performance' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set the number of NUMA nodes for performance tuning
echo "Configuring NUMA nodes..."
sudo sysctl -w vm.zone_reclaim_mode=1

# Enable huge pages for memory-intensive applications
echo "Enabling huge pages..."
echo "vm.nr_hugepages=2048" | sudo tee -a /etc/sysctl.d/99-hugepages.conf
sudo sysctl -p /etc/sysctl.d/99-hugepages.conf

# Optimizing TCP buffer sizes for high-speed network communication
echo "Optimizing TCP buffer sizes..."
echo "net.core.rmem_max = 16777216" | sudo tee -a /etc/sysctl.d/99-tcp-buffer.conf
echo "net.core.wmem_max = 16777216" | sudo tee -a /etc/sysctl.d/99-tcp-buffer.conf
echo "net.ipv4.tcp_rmem = 4096 87380 16777216" | sudo tee -a /etc/sysctl.d/99-tcp-buffer.conf
echo "net.ipv4.tcp_wmem = 4096 87380 16777216" | sudo tee -a /etc/sysctl.d/99-tcp-buffer.conf
sudo sysctl -p /etc/sysctl.d/99-tcp-buffer.conf

# Install MPI and OpenMP support in Python
echo "Installing MPI and OpenMP support in Python..."
pip install mpi4py

# Install benchmarking tools (e.g., Intel's High-Performance Linpack)
echo "Installing Intel Linpack for benchmarking..."
sudo pacman -S --noconfirm intel-mkl

# Optimize system for large parallel jobs (if needed)
echo "Configuring system for parallel jobs..."
sudo sysctl -w vm.swappiness=1
sudo sysctl -w vm.dirty_ratio=60

# Enable and configure the swap partition for performance
echo "Configuring swap partition for better performance..."
sudo systemctl enable dphys-swapfile
sudo systemctl start dphys-swapfile

# Update environment variables for OpenMPI and OpenMP
echo "Setting up environment variables for OpenMPI and OpenMP..."
echo "export PATH=\$PATH:/opt/openmpi/bin" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/openmpi/lib" >> ~/.bashrc
echo "export OMP_NUM_THREADS=8" >> ~/.bashrc
source ~/.bashrc

echo "HPC setup complete! Please reboot your system for all changes to take effect."
