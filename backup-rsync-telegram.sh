#!/bin/bash
## Christos Prassas - 0.04 - 20180829
############################################
##
## VARIABLES
##
# Set source location
BACKUP_FROM="/home/"

# Set target location
BACKUP_TO="/usbhdd/srv/" #Backup destination or you can use the backup dev below....
#BACKUP_DEV="XXXXXXXX-1df2-476a-a22a-XXXXXXXXXXXX" #UUID of the disk - after format check again with fdisk -l , ls -l /dev/disk/by-uuid , 
BACKUP_MNT="/usbhdd"
#BACKUP_EXCLUDE_BIN=".tras*" #If you have one excluded directory use a variable, else use an excluded command directly to rsync

# Log file
LOG_FILE="/var/log/backup_daily.log"
###########################################
##
## SCRIPT
##

# Check that the log file exists
if [ ! -e "$LOG_FILE" ]; then
        touch "$LOG_FILE"
        echo "Log File - OK..."
fi

# Check that source dir exists and is readable.
if [ ! -r  "$BACKUP_FROM" ]; then
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to read source dir." >> "$LOG_FILE"
		echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to read source dir."
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync." >> "$LOG_FILE"
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync. Check the log file..."
        echo "" >> "$LOG_FILE"
        exit 1
else
		echo "Backup Source - OK..."		
fi

# Check if the drive is mounted
if ! mountpoint "$BACKUP_MNT"; then
        echo "$(date "+%Y-%m-%d %k:%M:%S") - WARNING: Backup device needs mounting!" >> "$LOG_FILE"
        echo "$(date "+%Y-%m-%d %k:%M:%S") - WARNING: Backup device needs mounting!"

        # If not, mount the drive
  #      if mount -U "$BACKUP_DEV" "$BACKUP_MNT"; then
  #              echo "$(date "+%Y-%m-%d %k:%M:%S") - Backup device mounted." >> "$LOG_FILE"
 #		echo "$(date "+%Y-%m-%d %k:%M:%S") - HDD mounted successfully!"
 #        else
 #               echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to mount backup device." >> "$LOG_FILE"
 #               echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to mount backup device."
 #               echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync." >> "$LOG_FILE"
 #               echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync. Check the log file."
 #               echo "" >> "$LOG_FILE"
 #               exit 1
  #      fi
else
		echo "Mount Backup Destination - OK..."
fi

# Check that target dir exists and is writable.
if [ ! -w  "$BACKUP_TO" ]; then
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to write to target dir." >> "$LOG_FILE"
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to write to target dir."
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync." >> "$LOG_FILE"
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync. Check the log file."
        echo "" >> "$LOG_FILE"
        exit 1
else
		echo "Target Dir Exists and Writeable - OK..."
fi

# Start entry in the log
echo "$(date "+%Y-%m-%d %k:%M:%S") - Sync started." >> "$LOG_FILE"
echo "$(date "+%Y-%m-%d %k:%M:%S") - Sync started... Please wait."
# find old backup files and delete them. Keep only the last 7 backups
find "$BACKUP_TO" -mtime +6 -type f -delete
# Start sync
#if rsync -avz --delete --exclude "$BACKUP_EXCLUDE_BIN" "$BACKUP_FROM" "$BACKUP_TO" &>> "$LOG_FILE"; then
rsync -avz --stats -h --exclude "/home/excludedDir/" --exclude ".tras*" "$BACKUP_FROM" "$BACKUP_TO" &&

# End entry in the log
echo "" >> "$LOG_FILE" &&

if [ "$?" -eq "0" ]; #If rsync finished successfully then send ok message else fail.
then
	curl "https://api.telegram.org/botXXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/sendMessage?chat_id=-XXXXXXXXXXXXXXXXXXXX&text=Backup%20OK"
	echo "Is Everything OK?..."
else
	curl "https://api.telegram.org/botXXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/sendMessage?chat_id=-XXXXXXXXXXXXXXXXXXXX&text=Backup%20Failed"
fi
# Unmount the drive so it does not accidentally get damaged or wiped
#if umount "$BACKUP_MNT"; then
#	echo "$(date "+%Y-%m-%d %k:%M:%S") - Backup device unmounted." >> "$LOG_FILE"
#	echo "$(date "+%Y-%m-%d %k:%M:%S") - Backup device unmounted... Bye."
#else
#	echo "$(date "+%Y-%m-%d %k:%M:%S") - WARNING: Backup device could not be unmounted." >> "$LOG_FILE"
#	echo "$(date "+%Y-%m-%d %k:%M:%S") - WARNING: Backup device could not be unmounted."
#fi


exit 0
