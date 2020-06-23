# Introduction

This project contains instructions and Makefile for setting up a Raspberry Pi 4 as an Astrophotography computer.
Ubuntu Server 20.04 32 bits is used as a starting point.
Why using makefile as opposed to shell script? Because make stops execution in case of failures and can be invoked for the whole installation or for a part of it.

# Warning
This script is better suited for users, who have experience with Linux and want to build a system from scratch, utilizing official images from Ubuntu. 
In case if you don't have experience with Linux, it is suggested to install Astroberry image or buy StellarMate image.

# List of features:
1. Installs most commonly used Astrophotography software:
* INDI
* Kstars
* PHD2
* CCDCiel
* Skychart
* Astrometry with sextractor
* ASTAP plate solver, which is much faster than astrometry
2. Sets up Wireless Access Point. Default name is RPI and password is password but can be changed in the script. Once connected to WAP,  IP address of PI is 10.0.0.1
3. Sets up x11vnc to be started automatically
4. Configures screen to be 1920x1080 for headless operation
5. Defaults to KDE Desktop, but Gnome and Mate can also be installed 
6. Miscellaneous software
* Joplin notes app (broken under 20.04)
* Syncthing for syncing images into processing PC
* Arduino IDE 
* Latest Libraw with Canon CR3 support. At this point, only CCDCiel is working with this library, Ekos crashes with it
7. Fully headless operation

# Installation

1. Downlaod image

http://d3s68rdjvu5sgr.cloudfront.net/ubuntu-20.04-preinstalled-server-armhf%2Braspi.img.xz

2. Unpack and burn image into SD Card.

3. Connect to Pi

Connect Ethernet cable, put the card into RPI and boot.

Once green networking LED starts blinking, you can try to find the RPI on the network using nmap.
Replace 192.168.1.0 by your network's subnet:

```
nmap -p 22 --open -sV 192.168.1.0/24
```


Once you identify IP of your PI,  login into it using ssh, with user/password : ubuntu/ubuntu, e.g.:

```
ssh ubuntu@192.168.1.100
```

It will ask to change the password.

4. Install the software

Run the following commands.
At some point installer will ask to select Display Manager. You need to chose lightdm.

```
sudo apt update
sudo apt install -y git make
git clone https://github.com/avarakin/AstroPiMaker4.git
cd AstroPiMaker4
make
```
This will take an hour or so. It may ask some questions, so monitor the process.
You will need to reboot Pi after that.
Once Pi is up, you should be able to see it as RPI in the list of available Access Points. Password is "password" but can be changed in the script. Once connected to WAP,  IP address of PI is 10.0.0.1

# Steps after installation
1. Reboot the system.
2. Connect to it using VNC
3. Installer creates a startup script indi.sh in home directory which you need to edit to include your drivers
4. In case if you run Gnome, you can change the look and feel of desktop to be more conventional by opening Gnome Tweaks tool and enabling "Dash to Panel" and "System Monitor" extensions

