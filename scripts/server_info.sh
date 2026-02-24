#!/bin/bash

echo "========================================"
echo "        SERVER INFORMATION REPORT       "
echo "========================================"

echo ""
echo "1. Hostname Information"
echo "----------------------------------------"
hostnamectl 2>/dev/null || hostname

echo ""
echo "2. OS Information"
echo "----------------------------------------"
cat /etc/os-release 2>/dev/null

echo ""
echo "3. Uptime Information"
echo "----------------------------------------"
uptime -p
uptime

echo ""
echo "4. CPU Information"
echo "----------------------------------------"
lscpu | grep -E 'Model name|CPU\(s\)|Core|Thread|Architecture'

echo ""
echo "5. Memory Usage"
echo "----------------------------------------"
free -h

echo ""
echo "6. Disk Usage"
echo "----------------------------------------"
df -hT | grep -v tmpfs

echo ""
echo "7. Load Average"
echo "----------------------------------------"
cat /proc/loadavg

echo ""
echo "8. Network Information"
echo "----------------------------------------"
ip -brief addr 2>/dev/null || ifconfig

echo ""
echo "9. Logged In Users"
echo "----------------------------------------"
who

echo ""
echo "10. Top 5 Processes by Memory Usage"
echo "----------------------------------------"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

echo ""
echo "11. Top 5 Processes by CPU Usage"
echo "----------------------------------------"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6

echo ""
echo "========================================"
echo "        END OF REPORT                   "
echo "========================================"
