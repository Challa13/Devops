#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

REPORT_FILE="/tmp/update_report.txt"

generate_report() {
    echo "===== Ubuntu Update & System Report =====" > "$REPORT_FILE"
    echo "Date: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    echo "Hostname: $(hostname)" >> "$REPORT_FILE"
    echo "OS Version: $(lsb_release -d | cut -f2)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    echo "CPU Info:" >> "$REPORT_FILE"
    lscpu | grep -E 'Model name|Architecture|CPU\(s\)' >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    echo "Memory Info:" >> "$REPORT_FILE"
    free -h >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    echo "Open Ports:" >> "$REPORT_FILE"
    ss -tuln >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    echo "Updating package list..." >> "$REPORT_FILE"
    apt-get update -qq >> "$REPORT_FILE" 2>&1

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

    apt-get update -qq
    apt-get upgrade -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold"

    apt-get autoremove -y

    generate_report
}

restart_if_needed() {
    if [ -f /var/run/reboot-required ]; then
        echo "System requires reboot. Restarting now..."
        reboot
    else
        echo "No reboot required."
    fi
}

if [[ "$1" == "--apply" ]]; then
    apply_updates
    if [[ "$2" == "--restart-if-needed" ]]; then
        restart_if_needed
    fi
else
    generate_report
fi
