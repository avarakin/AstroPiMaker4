# Introduction

This project contains instructions and Makefile for setting up a Raspberry Pi 4 as an Astrophotography computer.
Ubuntu Server 19.10.1 is used as a starting point.
Why using makefile as opposed to shell script? Because make stops execution in case of failures and can be invoked for the whole installation or for a part of it.


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
5. Comes with KDE Desktop. Keep in mind that only minimal subset of KDE is installed. 
6. Miscellaneous software
* Joplin notes app
* Syncthing for syncing images into processing PC
* Arduino IDE 

# Installation

1. Downlaod image for 19.10:

http://cdimage.ubuntu.com/releases/19.10.1/release/ubuntu-19.10.1-preinstalled-server-armhf+raspi3.img.xz

or 20.04:

http://d3s68rdjvu5sgr.cloudfront.net/ubuntu-20.04-preinstalled-server-armhf%2Braspi.img.xz

2. Unpack and burn image into SD Card.

Here are the instructions for Ubuntu/Debian based PC. If you are using other OS, please use appropriate for your system steps.
You need to replace /dev/xxxx at the end of last command with appropriate device for your SD Card. 
You can find it out using gparted, which will show all available devices on your computer.
*Please be very careful with this command as it will overwrite the disk without any prompts.*

```
sudo apt install -y gddrescue xz-utils
xz -d ubuntu-19.10.1-preinstalled-server-armhf+raspi3.img.xz
sudo ddrescue -D --force ubuntu-19.10.1-preinstalled-server-armhf+raspi3.img /dev/xxxx
```


3. Connect to Pi

Connect Ethernet cable, put the card into RPI and boot.

Once green networking LED starts blinking, you can try to find the RPI on the network using nmap.
Replace 192.168.200.0 by your network's subnet:

```
nmap -p 22 --open -sV 192.168.200.0/24
```


Once you identify IP of your PI,  login into it using ssh, with user/password : ubuntu/ubuntu, e.g.:

```
ssh ubuntu@192.168.200.100
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
