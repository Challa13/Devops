#!/bin/bash

# Script: update_check.sh
# Purpose: Check and apply Ubuntu updates with optional reboot

REPORT_FILE="/tmp/update_report.txt"

generate_report() {
    echo "===== Ubuntu Update Report =====" > "$REPORT_FILE"
    echo "Date: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

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
if [[ "$1" == "--apply" ]]; then
    apply_updates
    if [[ "$2" == "--restart-if-needed" ]]; then
        restart_if_needed
    fi
else
    generate_report
fi
