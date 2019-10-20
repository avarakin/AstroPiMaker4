# Introduction

This project contains instructions and Makefile for setting up a Raspberry Pi 4 as an Astrophotography computer.
Ubuntu Server is used as a starting point.
Why using makefile as opposed to shell script? Because make stops execution in case of failures and can be invoked for the whole installation or for a part of it.

# List of features:
1. Installs most commonly used Astrophotography software:
* INDI
* Kstars
* PHD2
* CCDCiel
* Skychart
* Astrometry with sextractor
2. Sets up Wireless Access Point. Default name is RPI and password is password but can be changed in the script. Once connected to WAP,  IP address of PI is 10.0.0.1
3. Sets up x11vnc to be started automatically
4. Configures screen to be 1920x1080 for headless operation

Not implemented yet:
1. Configures USB to provide up to 1A of current to connected devices
2. Configures the onboard serial port for controlling an external device

# Installation
This method is based on installing Ubuntu Server and then replacing the firmware by Raspbian firmware and is based on the following instructions:

https://jamesachambers.com/raspberry-pi-ubuntu-server-18-04-2-installation-guide/

1. Downlaod image from:
http://cdimage.ubuntu.com/ubuntu/releases/19.10/release/ubuntu-19.10-preinstalled-server-armhf+raspi3.img.xz


2. Unpack and burn image into SD Card.

Here are the instructions for Ubuntu/Debian based PC. If you are using other OS, please use appropriate steps.
You need to replace /dev/xxxx at the end of last command with appropriate device for your SD Card. 
You can find it out using gparted, which will show all available devices on your computer.
*Please be very careful with this command as it will overwrite the disk without any prompts.*

```
sudo apt install gddrescue xz-utils
xz -d ubuntu-19.10-preinstalled-server-armhf+raspi3.img.xz
sudo ddrescue -D --force ubuntu-19.10-preinstalled-server-armhf+raspi3.img /dev/xxxx
```

3. Install firmware from Raspbian.

Insert/mount the micro SD card in your computer and navigate to the “boot” partition. Delete everything in the existing folder so it is completely empty.

Download firmware from:

https://github.com/raspberrypi/firmware/archive/master.zip

The latest firmware is everything inside master.zip “boot” folder (including subfolders). We want to extract everything from “boot” (including subfolders) to our micro SD’s “boot” partition that we just emptied in the previous step. Don’t forget to get the “overlays” folder as that contains overlays necessary to boot correctly.


4. Create/Update config.txt and cmdline.txt

Navigate to the micro SD /boot/ partition. Create a cmdline.txt file with the following line:

```
dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rootflags=noload net.ifnames=0
```

Next we are going to create config.txt with the following content:

```
## Enable audio (loads snd_bcm2835)
dtparam=audio=on
[pi4]
[all]
hdmi_force_hotplug=1
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=82
disable_overscan=1
```

5. Final steps

Connect Ethernet cable, put in the card into RPI and boot.
It may take up to 10 minutes to boot, especially if mouse is not connected, so be patient.
Once Raspberry is running, connect to it using ssh, with user/password : ubuntu/ubuntu
 and then run the following commands

```
sudo apt remove flash-kernel initramfs-tools
sudo apt-get install git make
git clone https://github.com/avarakin/AstroPi4.git
cd AstroPi4
sudo make
```
This will take an hour or so. It may ask some questions, so monitor the process.

6. Update firmware

Finally, you may want to update the firmware and install modules:
```
sudo make update_firmware
```

## Notes

1. Server version of Ubuntu has LXD and cloud software  which is not needed so it is removed
2. Random number generator is taking a lot of time during the boot so "haveged" random generator is installed as part of the installer script
