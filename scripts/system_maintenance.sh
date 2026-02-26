#!/bin/bash

set -o pipefail
export DEBIAN_FRONTEND=noninteractive

REPORT_FILE="/tmp/update_report.txt"

log() {
    echo "$1" | tee -a "$REPORT_FILE"
}

generate_report() {

    echo "===== Ubuntu Update & System Report =====" > "$REPORT_FILE"
    log "Date: $(date)"
    log ""

    log "Hostname: $(hostname)"

    if command -v lsb_release >/dev/null 2>&1; then
        log "OS Version: $(lsb_release -d | cut -f2)"
    else
        log "OS Version: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
    fi

    log ""
    log "CPU Info:"
    lscpu 2>/dev/null | grep -E 'Model name|Architecture|CPU\(s\)' >> "$REPORT_FILE" || true

    log ""
    log "Memory Info:"
    free -h >> "$REPORT_FILE" 2>/dev/null || true

    log ""
    log "Open Ports:"
    ss -tuln >> "$REPORT_FILE" 2>/dev/null || true

    log ""
    log "Updating package list..."
    apt-get update -qq >> "$REPORT_FILE" 2>&1 || log "apt-get update failed"

    log ""
    log "Available upgrades:"
    apt list --upgradable 2>/dev/null | grep -v "Listing..." >> "$REPORT_FILE" || true

    log ""
    if [ -f /var/run/reboot-required ]; then
        log "⚠️ Reboot is required after updates."
    else
        log "✅ No reboot required."
    fi

    log ""
    log "Report generated at: $REPORT_FILE"
    cat "$REPORT_FILE"
}

apply_updates() {

    log "Applying updates..."

    if ! apt-get update -qq; then
        log "❌ apt-get update failed"
        exit 1
    fi

    if ! apt-get upgrade -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold"; then
        log "❌ apt-get upgrade failed"
        exit 1
    fi

    apt-get autoremove -y || true

    generate_report
}

restart_if_needed() {
    if [ -f /var/run/reboot-required ]; then
        log "System requires reboot."
        reboot
    else
        log "No reboot required."
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
