#!/bin/sh

echo "Applying FreeBSD Multi-Thread Optimization..."

# 1. Increase Kernel Performance for Multi-Threading
echo "Configuring kernel scheduler and performance settings.."
sysctl kern.sched.name=ULE
sysctl kern.sched.affinity=1
sysctl kern.hz=1000

# 2. Increase Max CPU Threads and Processes
echo "Increasing thread and process limits..."
sysctl kern.maxproc=100000
sysctl kern.maxthreads=200000
sysctl kern.ipc.maxsockbuf=16777216

# 3. Enable NUMA Awareness (if supported)
sysctl vm.numa=1
sysctl vm.phys_pager.numapolicy=1

# 4. Optimize CPU Affinity (ensure processes stay on assigned cores)
echo "Optimizing CPU affinity..."
cpuset -l 0-$(($(sysctl -n hw.ncpu) - 1)) -p $$

# 5. Enable Superpages for Better Memory Performance
echo "Enabling superpages..."
sysctl vm.pmap.pg_ps_enabled=1

# 6. Optimize ZFS for Multi-Threading (if using ZFS)
if [ -d "/usr/local/etc/zfs" ]; then
  echo "Tuning ZFS..."
  sysctl vfs.zfs.zil_replay_disable=1
  sysctl vfs.zfs.prefetch_disable=0
fi

# 7. Network and TCP Optimization
echo "Optimizing TCP buffer sizes..."
sysctl net.inet.tcp.sendspace=2097152
sysctl net.inet.tcp.recvspace=2097152
sysctl kern.ipc.maxsockbuf=16777216

# 8. Enable Asynchronous I/O
sysctl vfs.aio.enable_unsafe=1

# 9. Apply Changes Persistently
echo "Saving configurations to /etc/sysctl.conf..."
cat <<EOF >> /etc/sysctl.conf
kern.sched.name=ULE
kern.sched.affinity=1
kern.hz=1000
kern.maxproc=100000
kern.maxthreads=200000
kern.ipc.maxsockbuf=16777216
vm.numa=1
vm.phys_pager.numapolicy=1
vm.pmap.pg_ps_enabled=1
net.inet.tcp.sendspace=2097152
net.inet.tcp.recvspace=2097152
kern.ipc.maxsockbuf=16777216
vfs.aio.enable_unsafe=1
EOF

echo "Optimization is complete if you do not get any errors through this process. Reboot for changes to take effect."

