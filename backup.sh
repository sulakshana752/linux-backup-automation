#!/bin/bash

# ==========================================
# Linux Backup Automation Script
# Author: Sula Jayasekara
# Description:
#   Creates compressed backups of selected directories,
#   logs activity, and removes older backups based on retention.
# ==========================================

set -uo pipefail

# -------- CONFIGURATION --------
BACKUP_NAME="system_backup"
BACKUP_DEST="/var/backups/my_backups"
LOG_FILE="/var/log/backup_script.log"

# List directories to back up
SOURCE_DIRS=(
    "/etc"
    "/home"
    "/var/www"
)

# Number of recent backups to keep
RETENTION_COUNT=5

# -------- FUNCTIONS --------
log_message() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

check_directories() {
    local missing=0

    for dir in "${SOURCE_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            log_message "ERROR: Source directory does not exist: $dir"
            missing=1
        fi
    done

    if [ "$missing" -ne 0 ]; then
        log_message "Backup aborted because one or more source directories are missing."
        exit 1
    fi
}

create_backup_destination() {
    if [ ! -d "$BACKUP_DEST" ]; then
        mkdir -p "$BACKUP_DEST"
        if [ $? -ne 0 ]; then
            log_message "ERROR: Failed to create backup destination: $BACKUP_DEST"
            exit 1
        fi
        log_message "Created backup destination: $BACKUP_DEST"
    fi
}

create_log_file() {
    local log_dir
    log_dir="$(dirname "$LOG_FILE")"

    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" || {
            echo "ERROR: Failed to create log directory: $log_dir"
            exit 1
        }
    fi

    touch "$LOG_FILE" || {
        echo "ERROR: Failed to create log file: $LOG_FILE"
        exit 1
    }
}

perform_backup() {
    local timestamp backup_file
    timestamp="$(date '+%Y%m%d_%H%M%S')"
    backup_file="${BACKUP_DEST}/${BACKUP_NAME}_${timestamp}.tar.gz"

    log_message "Starting backup: $backup_file"

    tar -czf "$backup_file" "${SOURCE_DIRS[@]}" 2>>"$LOG_FILE"
    if [ $? -eq 0 ]; then
        log_message "Backup completed successfully: $backup_file"
    else
        log_message "ERROR: Backup failed."
        exit 1
    fi
}

cleanup_old_backups() {
    log_message "Checking for old backups to remove..."

    mapfile -t backup_files < <(ls -1t "${BACKUP_DEST}/${BACKUP_NAME}"_*.tar.gz 2>/dev/null)

    local total_backups="${#backup_files[@]}"

    if [ "$total_backups" -le "$RETENTION_COUNT" ]; then
        log_message "No old backups to remove. Total backups: $total_backups"
        return
    fi

    for ((i=RETENTION_COUNT; i<total_backups; i++)); do
        rm -f "${backup_files[$i]}"
        if [ $? -eq 0 ]; then
            log_message "Removed old backup: ${backup_files[$i]}"
        else
            log_message "WARNING: Failed to remove old backup: ${backup_files[$i]}"
        fi
    done
}

main() {
    create_log_file
    log_message "========== Backup job started =========="
    check_directories
    create_backup_destination
    perform_backup
    cleanup_old_backups
    log_message "========== Backup job finished =========="
}

main
