#!/bin/bash

# This script is intended to apply security hardening best practices to an Ubuntu system.

# Exit on any error
set -e

# 1. Update the system
echo "Updating system packages..."
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y

# 2. Install essential security packages
echo "Installing essential security packages..."
apt-get install -y ufw fail2ban unattended-upgrades auditd apparmor

# 3. Enable and configure Uncomplicated Firewall (UFW)
echo "Configuring UFW firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable

# 4. Harden SSH Configuration
echo "Hardening SSH configuration..."
# Disable root login
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
# Disable password authentication
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Limit SSH access to specific users (replace 'user' with actual username)
echo "AllowUsers user" >> /etc/ssh/sshd_config
# Set SSH protocol to 2 (stronger security)
sed -i 's/^Protocol 1,2/Protocol 2/' /etc/ssh/sshd_config
# Restart SSH service
systemctl restart sshd

# 5. Enable automatic security updates
echo "Configuring automatic security updates..."
dpkg-reconfigure --priority=low unattended-upgrades

# 6. Disable unnecessary services
echo "Disabling unnecessary services..."
# Disable Avahi (zeroconf)
systemctl disable avahi-daemon
# Disable CUPS (printing service)
systemctl disable cups
# Disable Bluetooth service (if not required)
systemctl disable bluetooth

# 7. Disable IPv6 if not needed
echo "Disabling IPv6..."
# Check if IPv6 is in use
if sysctl net.ipv6.conf.all.disable_ipv6=1; then
  echo "IPv6 disabled."
else
  echo "IPv6 is already disabled."
fi

# 8. Enable AppArmor
echo "Enabling AppArmor..."
systemctl enable apparmor
systemctl start apparmor

# 9. Configure auditd
echo "Configuring auditd..."
systemctl enable auditd
systemctl start auditd

# 10. Remove unneeded packages
echo "Removing unneeded packages..."
apt-get purge -y snapd
apt-get autoremove -y

# 11. Check and configure sysctl for hardening
echo "Applying sysctl hardening settings..."
cat >> /etc/sysctl.conf <<EOF
# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Enable TCP SYN cookies to prevent SYN flood attacks
net.ipv4.tcp_syncookies = 1

# Disable ICMP Redirect Acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Prevent Source Routing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Enable IP Spoofing Protection
net.ipv4.conf.all.accept_source_route = 0
EOF
sysctl -p

# 12. Restrict core dumps
echo "Restricting core dumps..."
echo "* hard core 0" >> /etc/security/limits.conf

# 13. Check for weak file permissions
echo "Checking file permissions..."
find / -xdev -type f -exec chmod o-rwx {} \;
find / -xdev -type d -exec chmod o-rx {} \;

# 14. Set secure permissions on sensitive files
echo "Setting secure permissions on sensitive files..."
chmod 600 /etc/shadow
chmod 600 /etc/gshadow
chmod 644 /etc/passwd
chmod 644 /etc/group

# 15. Disable USB storage (if needed)
echo "Disabling USB storage..."
echo "blacklist usb-storage" > /etc/modprobe.d/blacklist-usb.conf

# 16. Install and configure rkhunter
echo "Installing and configuring rkhunter..."
apt-get install -y rkhunter
rkhunter --update
rkhunter --propupd

# 17. Configure time zone and NTP
echo "Configuring time zone and NTP..."
timedatectl set-timezone UTC
apt-get install -y ntp
systemctl enable ntp
systemctl start ntp

# 18. Set up logging and monitor logs
echo "Setting up log monitoring..."
apt-get install -y logwatch
logwatch --output file --mailto root --detail high

# 19. Final check and summary
echo "Security hardening complete! Please review system settings and logs for any further configuration."

# Reboot the system for some changes to take effect
echo "Rebooting system..."
reboot
