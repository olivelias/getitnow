#!/bin/bash

########################
# Script : getitnow.sh #
# Author : olivelias   #
# Version : 0.2.0      #
# Date : 14/03/2017    #
########################

##########
#  VARS  #
##########

# LOG file + initialization
LOG=/var/log/transfert.log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>${LOG} 2>&1

# USB mountpoint
USB="/media/pi/USB"

# Folder
FOLDER="/home/pi/Music"

# FS Type
FS=$(lsblk -f /dev/sd*1 | grep sd | awk '{print$2}')

# Local folder size
LOCAL_SIZE=$(du -ks $FOLDER | awk '{print$1}')

# Init remote USB folder size
USB_SIZE=0

##########
# SCRIPT #
##########

echo "------ START ------"
date +%Y-%m-%d-%Hh%Mm%Ss

echo "### USB folder creation : ${USB} ###"
mkdir ${USB}

echo "### Umount USB if already mounted ${USB} ###"
umount -f /dev/sd*1

echo "### Mounting /dev/sd*1 partition ###"
echo "### Filesystem=$FS ###"
if [ $FS = "ntfs" ] ; then
    echo "### Fix NTFS if USB key not safely removed  ###"
    ntfsfix /dev/sd*1
    mount -o rw,uid=pi,gid=users,iocharset=iso8859-1,utf8 /dev/sd*1 ${USB}
fi
if [ $FS = "vfat" ] ; then
    echo "### Fix FAT if USB key not safely removed  ###"
    fsck -a /dev/sda1
    mount -o rw,uid=pi,gid=users,iocharset=iso8859-1,utf8 /dev/sd*1 ${USB}
fi
if [ $FS = "ext*" ] ; then
    mount  /dev/sd*1 ${USB}
    chown pi:users ${USB}
    chmod 750 ${USB}
fi

echo "### Check remaining size on USB ###"
USB_SIZE=$(df -k | grep "/dev/sd." | awk '{print $4}')

echo "### Comparison of local and remote size ###"
if [ $USB_SIZE -lt $LOCAL_SIZE ] 
then
    su - pi -c "
        export DISPLAY=':0';
        terminator -fb --command='toilet -f big -F gay FULL;
        sleep 10;
    '"
    echo "### Insufficient disk space"
    echo "### Umount ${USB} directory ###"
    umount -f ${USB}
    echo "### Remove ${USB} directory ###"
    rmdir ${USB}
    date +%Y-%m-%d-%Hh%Mm%Ss
    echo "------ END ------"
    exit 0
fi

echo "### Start of transfert ###"
su - pi -c "
    export DISPLAY=':0';
    terminator -fb --command='toilet -f big -F gay get it now;
    rsync -rltzuv --progress  /home/pi/Music/* /media/pi/USB/.;
    sleep 10;
'"

echo "### End of transfert ###"
echo "### Umount ${USB} directory ###"
umount -f ${USB}
echo "### Removing ${USB} directory  ###"
rmdir ${USB}
date +%Y-%m-%d-%Hh%Mm%Ss
echo "------ END ------"
exit 0
