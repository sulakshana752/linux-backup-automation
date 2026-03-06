# Linux Backup Automation Script

A Bash script for automating compressed backups of Linux directories with logging and retention cleanup.

## Features

- Backs up multiple directories
- Creates timestamped `.tar.gz` archives
- Logs all actions and errors
- Automatically removes older backups
- Easy to schedule with cron

## File

- `backup.sh` - Main backup automation script

## Configuration

Edit these variables in the script:

- `BACKUP_NAME` - base name for backup files
- `BACKUP_DEST` - backup destination directory
- `LOG_FILE` - log file path
- `SOURCE_DIRS` - directories to back up
- `RETENTION_COUNT` - number of backups to keep

## Example Source Directories

```bash
SOURCE_DIRS=(
    "/etc"
    "/home"
    "/var/www"
)
