#!/bin/bash
if [ $EUID -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

mount_disk () {
    if ! cryptsetup status backup &> /dev/null; then
		echo -n $(doas -u vin pass show Uncategorized/Backup/password) | cryptsetup open \
            --type tcrypt \
            --veracrypt \
            /dev/disk/by-id/usb-WD_My_Book_25EE_575834314439375233413344-0:0-part1 backup -d - 

		if [ $? -ne 0 ] ; then
			echo "Could not open the volume. Wrong password?"
			exit 1
        fi
    fi

    mount /dev/mapper/backup /mnt/backup

    if [ ! -f /mnt/backup/.mounted ]; then
        echo "Something went wrong while mounting"
        exit 1
    fi
}

backup () {
    # To view backed up files, first have disk mounted, then use
    #   `borg mount /path/to/repo /mnt/mountpoint'
    # To unmount, use `borg umount /mnt/mountpoint'
	BORG_CACHE_DIR=/mnt/backup/cache borg create \
		--debug \
		--stats \
		--progress \
		--show-rc \
		--compression zstd,10 \
		--exclude-caches \
		--exclude-from /mnt/backup/Scadrial/.bak-ignore \
		/mnt/backup/Scadrial::{hostname}{now:%Y-%m-%dT%H%M%S} \
		/

	if [ $? -ne 0 ] ; then 
		echo "Backup failed."
		exit 1
	fi

	if [[ $check -eq 1 ]] ; then
		borg check \
			--debug \
			--progress \
			--show-rc \
			--last 1 \
			/mnt/backup/Scadrial

		if [ $? -ne 0 ] ; then 
			echo "Verification failed."
			exit 1
		fi
	fi
}

prune () {
    borg prune \
         --list \
         --prefix '{hostname}' \
         --show-rc \
         --keep-daily 7 \
         --keep-weekly 4 \
         --keep-monthly 6 \
         /mnt/backup/Scadrial

	if [ $? -ne 0 ] ; then 
		echo "Pruning failed."
		exit 1
	fi
}

unmount () {
    umount /mnt/backup

    while [ -f /mnt/backup/.mounted ]; do
        sleep 1
    done

    cryptsetup close backup &> /dev/null
}

export check=$CHECK
if [ ! -f /mnt/backup/.mounted ]; then
    mount_disk
    if [[ "$1" == "prune" ]]; then
        prune
    else
        backup
    fi
    unmount
else
    if [[ "$1" == "prune" ]]; then
        prune
    else
        backup
    fi
    unmount
fi
unset check
