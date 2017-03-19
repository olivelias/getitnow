# getitnow !

A small bash script that automates the transfer of a folder when a USB key ( or external drive ) is plugged in.

Originally written to share free music in a shop using a Raspberry PI

# Requirements

*  1 Raspberry pi ( tested on Raspberry PI 3 Model B )
*  1 Screen  ( like this one : https://www.raspberrypi.org/products/raspberry-pi-touch-display/ )
*  1 USB stick

# Installation

*  download the latest release
*  edit getitnow.sh and set your FOLDER path ( in VARS section )
*  put "50-usb_custom.rules" in "/etc/udev/rules.d/"
*  put "getitnow.sh" in "/home/pi/Scripts/" ( script folder can be changed, edit the "50-usb_custom.rules" and change the PATH )

# Info

* If the USB key has several partitions, the transfer will be done on the first partition
