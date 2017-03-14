#!/bin/bash

########################
# Script : getitnow.sh #
# Author : olivelias   #
# Version : 0.2	       #
# Date : 14/03/2017    #
########################

# V 0.2 (14/03/2017)
# - bannera added
# - check USB space available and alert if insufficent space
# - NTFS / EXT support
# - remove NTFS / FAT dirty bit if exist
#
# V 0.1 (17/12/2016)
# - FAT support !!

##########
## VARS ##
##########

# LOG file + initialization
LOG=/var/log/transfert.log
touch ${LOG}

# USB mountpoint
USB="/media/pi/USB"

# Music folder
MUSIC="/home/pi/Music"

# FS Type
FS=$(lsblk -f /dev/sd*1 | grep sd | awk '{print$2}')

# Local music folder size
LOCAL_SIZE=$(du -ks $MUSIC | awk '{print$1}')

# Init remote USB folder size
USB_SIZE=0

##########
# SCRIPT #
##########

echo "------ START ------"                                                      >> ${LOG} 2>&1

echo "### USB folder creation : ${USB} ###"                                     >> ${LOG} 2>&1
mkdir ${USB}                                                                    >> ${LOG} 2>&1

echo "### Umount USB if already mounted ${USB} ###"                             >> ${LOG} 2>&1
umount -f /dev/sd*1                                                             >> ${LOG} 2>&1

echo "### Mounting /dev/sd*1 partition ###"                                     >> ${LOG} 2>&1
echo "### Filesystem=$FS ###"                                                   >> ${LOG} 2>&1
if [ $FS = "ntfs" ] ; then
    echo "### Fix NTFS if USB key not safely removed  ###"                      >> ${LOG} 2>&1
    ntfsfix /dev/sd*1                                                           >> ${LOG} 2>&1
    mount -o rw,uid=pi,gid=users,iocharset=iso8859-1,utf8 /dev/sd*1 ${USB}      >> ${LOG} 2>&1
fi
if [ $FS = "vfat" ] ; then
    echo "### Fix FAT if USB key not safely removed  ###"                       >> ${LOG} 2>&1
    fsck -a /dev/sda1                                                           >> ${LOG} 2>&1
    mount -o rw,uid=pi,gid=users,iocharset=iso8859-1,utf8 /dev/sd*1 ${USB}      >> ${LOG} 2>&1
fi
if [ $FS = "ext*" ] ; then
    mount  /dev/sd*1 ${USB}                                                     >> ${LOG} 2>&1
    chown pi:users ${USB}
    chmod 750 ${USB}
fi

echo "### Check remaining size on USB ###"                                      >> ${LOG} 2>&1
USB_SIZE=$(df -k | grep "/dev/sd." | awk '{print $4}')

echo "### Comparison of local and remote size ###"                              >> ${LOG} 2>&1
if [ $USB_SIZE -lt $LOCAL_SIZE ] 
then
    su - pi -c "
        export DISPLAY=':0';
        terminator -fb --command='toilet -f big -F gay FULL;
        sleep 10;
    '"
    echo "### Insufficient disk space"                                          >> ${LOG} 2>&1
    echo "### Umount ${USB} directory ###"                                      >> ${LOG} 2>&1
    umount -f ${USB}                                                            >> ${LOG} 2>&1
    echo "### Remove ${USB} directory ###"                                      >> ${LOG} 2>&1
    rmdir ${USB}                                                                >> ${LOG} 2>&1
    echo "------ END ------"                                                    >> ${LOG} 2>&1
    exit 0
fi

echo "### Start of transfert ###"                                               >> ${LOG} 2>&1
su - pi -c "
    export DISPLAY=':0';
    terminator -fb --command='toilet -f big -F gay get it now;
    rsync -rltzuv --progress  /home/pi/Music/* /media/pi/USB/.;
    sleep 10;
'"                                                                              >> ${LOG} 2>&1

echo "### End of transfert ###"                                                 >> ${LOG} 2>&1
echo "### Umount ${USB} directory ###"                                          >> ${LOG} 2>&1
umount -f ${USB}                                                                >> ${LOG} 2>&1
echo "### Removing ${USB} directory  ###"                                       >> ${LOG} 2>&1
rmdir ${USB}                                                                    >> ${LOG} 2>&1
echo "------ END ------"                                                        >> ${LOG} 2>&1
exit 0
