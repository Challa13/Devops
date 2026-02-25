#!/bin/bash

# Script: update_check.sh
# Purpose: Check and apply Ubuntu updates with optional reboot
# Generates system info report (CPU, memory, ports, hostname, OS version)

REPORT_FILE="/tmp/update_report.txt"

generate_report() {
    echo "===== Ubuntu Update & System Report =====" > "$REPORT_FILE"
    echo "Date: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Hostname & OS version
    echo "Hostname: $(hostname)" >> "$REPORT_FILE"
    echo "OS Version: $(lsb_release -d | cut -f2)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # CPU info
    echo "CPU Info:" >> "$REPORT_FILE"
    lscpu | grep -E 'Model name|Architecture|CPU\(s\)' >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Memory info
    echo "Memory Info:" >> "$REPORT_FILE"
    free -h >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Open ports
    echo "Open Ports:" >> "$REPORT_FILE"
    sudo ss -tuln >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Updates
    echo "Updating package list..." >> "$REPORT_FILE"
    sudo apt update -qq >> "$REPORT_FILE" 2>&1

    echo "" >> "$REPORT_FILE"
    echo "Available upgrades:" >> "$REPORT_FILE"
    apt list --upgradable 2>/dev/null | grep -v "Listing..." >> "$REPORT_FILE"

    echo "" >> "$REPORT_FILE"
    if [ -f /var/run/reboot-required ]; then
        echo "⚠️ Reboot is required after updates." >> "$REPORT_FILE"
    else
        echo "✅ No reboot required." >> "$REPORT_FILE"
    fi

    echo "" >> "$REPORT_FILE"
    echo "Report generated at: $REPORT_FILE"
    cat "$REPORT_FILE"
}

apply_updates() {
    echo "Applying updates..."
    sudo apt upgrade -y
    sudo apt autoremove -y
    generate_report
}

restart_if_needed() {
    if [ -f /var/run/reboot-required ]; then
        echo "System requires reboot. Restarting now..."
        sudo reboot
    else
        echo "No reboot required."
    fi
}

# Main logic
case "$1" in
    "")
        # No args → just generate report
        generate_report
        ;;
    "--apply")
        apply_updates
        ;;
    "--apply"*"--restart-if-needed")
        apply_updates
        restart_if_needed
        ;;
    *)
        echo "Usage: $0 [--apply] [--apply --restart-if-needed]"
        exit 1
        ;;
esac
