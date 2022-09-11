pi4: tz update utils speedup display mate-desktop indi kstars ccdciel skychart phd realvnc groups astrometry sample_startup syncthing dnsmasq autostart astap wap

x86: update utils groups indi kstars ccdciel skychart phd astrometry sample_startup tigervnc syncthing dnsmasq astap wap
#astap
#realvnc autostart speedup display

extras: arduino libraw

tz:
	sudo dpkg-reconfigure tzdata

update:
	sudo apt update
	sudo apt upgrade -y
	sudo apt purge -y unattended-upgrades



serial:
	sudo echo enable_uart=1 >> /boot/config.txt
	sudo sed -i.bak 's/console=serial0,115200//'  /boot/firmware/cmdline.txt
	sudo systemctl stop serial-getty@ttyS0.service
	sudo systemctl disable serial-getty@ttyS0.service
	sudo sh -c "echo  'KERNEL==\"ttyS0\", SYMLINK+=\"serial0\" GROUP=\"tty\" MODE=\"0660\"' > /etc/udev/rules.d/80-serial.rules"
	sudo sh -c "echo  'KERNEL==\"ttyAMA0\", SYMLINK+=\"serial1\" GROUP=\"tty\" MODE=\"0660\"' >> /etc/udev/rules.d/80-serial.rules"
	cat /etc/udev/rules.d/80-serial.rules
	#sudo udevadm control --reload-rules
	#sudo udevadm trigger
	
serial_after_reboot:
	sudo chgrp -h tty /dev/serial0
	sudo chgrp -h tty /dev/serial1
	sudo adduser $$USER tty
	sudo adduser $$USER dialout


nomachine:
	wget https://download.nomachine.com/download/7.3/Raspberry/nomachine_7.3.2_1_armhf.deb
	sudo dpkg -i nomachine_7.3.2_1_armhf.deb
	rm nomachine_7.3.2_1_armhf.deb


#install general utilities
utils :
	sudo apt -y install curl net-tools firefox mc git vim ssh x11vnc zsh synaptic fonts-roboto terminator remmina chromium-browser

autostart:
	sudo sh -c "echo [SeatDefaults] > /etc/lightdm/lightdm.conf"
	sudo sh -c "echo greeter-session=lightdm-gtk-greeter >> /etc/lightdm/lightdm.conf"
	sudo sh -c "echo autologin-user=ubuntu >> /etc/lightdm/lightdm.conf"


display :
	sudo sh -c "echo '[all]' > /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_force_hotplug=1' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_ignore_edid=0xa5000080' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_group=2' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_mode=82' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'disable_overscan=1' >> /boot/firmware/usercfg.txt"


lxde-desktop :
	sudo sudo apt install -y lubuntu-desktop

kde-desktop :
	sudo apt -y install kde-plasma-desktop plasma-nm  lightdm

speedup :
	sudo apt -y purge cloud-init
	sudo rm -rf /etc/cloud/
	sudo rm -rf /var/lib/cloud/


mate-desktop :
	sudo apt -y install mate-desktop-environment lightdm


gnome-desktop :
	sudo apt -y install lightdm gnome-tweaks gnome-shell-extension-dash-to-panel gnome-system-monitor gnome-shell-extension-system-monitor gnome-session

indi :
	sudo apt-add-repository -y ppa:mutlaqja/ppa
	sudo apt update
	sudo apt -y install indi-full

kstars :
	sudo apt-add-repository -y ppa:mutlaqja/ppa
	sudo apt update
	sudo apt -y install kstars-bleeding gsc

astrometry :
	sudo apt -y install astrometry.net astrometry-data-tycho2 astrometry-data-2mass-08-19 astrometry-data-2mass-08-19 astrometry-data-2mass-07 astrometry-data-2mass-06 sextractor

#install ccdciel and skychart
skychart :
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2
	sudo sh -c "echo 'deb http://www.ap-i.net/apt unstable main' > /etc/apt/sources.list.d/skychart.list"
	sudo apt update
	sudo apt -y install skychart

ccdciel :
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2
	sudo sh -c "echo 'deb http://www.ap-i.net/apt unstable main' > /etc/apt/sources.list.d/skychart.list"
	sudo apt update
	sudo apt -y install ccdciel



#install phd2
phd :
	sudo add-apt-repository -y  ppa:pch/phd2
	sudo apt update
	sudo apt -y install phd2 phdlogview


#create a sample INDI startup shell script
sample_startup :
	echo "indiserver -v indi_lx200_OnStep indi_sbig_ccd indi_asi_ccd indi_sx_wheel" > ~/indi.sh
	chmod 777 ~/indi.sh


dnsmasq :
	sudo systemctl stop systemd-resolved
	sudo systemctl disable systemd-resolved
	sudo rm /etc/resolv.conf
	sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
	sudo chattr -e /etc/resolv.conf
	sudo chattr +i /etc/resolv.conf
	sudo sh -c "echo  '127.0.0.1 ubuntu' >> /etc/hosts"
	sudo apt -y install dnsmasq

wap :
	sudo apt -y install hostapd dnsmasq make
	git clone https://github.com/oblique/create_ap
	cd create_ap && sudo make install
	#configure access point id and password
	sudo sed -i.bak 's/SSID=MyAccessPoint/SSID=RPI/'  /etc/create_ap.conf 
	sudo sed -i.bak 's/PASSPHRASE=12345678/PASSPHRASE=password/'  /etc/create_ap.conf 
	sudo systemctl enable create_ap
	sudo systemctl start create_ap
	sudo systemctl status create_ap
	echo It would be a good idea to reboot now!

auto_login:
	sudo sh -c "echo '[SeatDefaults]' > /etc/lightdm/lightdm.conf"
	sudo sh -c "echo 'greeter-session=lightdm-gtk-greeter' >> /etc/lightdm/lightdm.conf"
	sudo sh -c "echo 'autologin-user=ubuntu' >> /etc/lightdm/lightdm.conf"

#configure x11vnc 
VNC=/lib/systemd/system/x11vnc.service
vnc :
	sudo sh -c "echo '[Unit]' > $(VNC)"
	sudo sh -c "echo 'Description=Start x11vnc at startup.' >> $(VNC)"
	sudo sh -c "echo 'After=multi-user.target' >> $(VNC)"
	sudo sh -c "echo '[Service]'>> $(VNC)"
	sudo sh -c "echo 'Type=simple'>> $(VNC)"
	sudo sh -c "echo 'ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared'>> $(VNC)"
	sudo sh -c "echo '[Install]'>> $(VNC)"
	sudo sh -c "echo 'WantedBy=multi-user.target'>> $(VNC)"
	sudo x11vnc -storepasswd /etc/x11vnc.pass
	sudo systemctl enable x11vnc.service
	sudo systemctl start x11vnc.service


astap_x86:
	#wget https://versaweb.dl.sourceforge.net/project/astap-program/linux_installer/astap_amd64.deb
	#wget https://cytranet.dl.sourceforge.net/project/astap-program/star_databases/h18_star_database_mag18_astap.deb
	sudo dpkg -i astap_amd64.deb h18_star_database_mag18_astap.deb
	rm astap_amd64.deb h18_star_database_mag18_astap.deb


astap:
	wget https://sourceforge.net/projects/astap-program/files/star_databases/g17_star_database_mag17_astap.deb
	sudo dpkg -i g17_star_database_mag17_astap.deb
	wget https://sourceforge.net/projects/astap-program/files/linux_installer/astap_armhf.deb
	sudo dpkg -i astap_armhf.deb
	rm astap_armhf.deb  g17_star_database_mag17_astap.deb

groups :
	sudo usermod -a -G dialout $(USER)

disable_auto_mount_of_dslr:
	gsettings set org.mate.media-handling automount false


realvnc_x86:
	wget https://downloads.realvnc.com/download/file/vnc.files/VNC-Server-6.10.1-Linux-x64.deb
	sudo dpkg -i VNC-Server-6.10.1-Linux-x64.deb
	sudo systemctl start vncserver-virtuald.service
	sudo systemctl start vncserver-x11-serviced.service
	sudo systemctl enable vncserver-virtuald.service
	sudo systemctl enable vncserver-x11-serviced.service
	rm VNC-Server-6.10.1-Linux-x64.deb
	#the commands below are needed if you want to use 3rd party vnc clients, while connecting to Pi 
	sudo vncpasswd -service
	sudo sh -c "echo Authentication=VncAuth >> /root/.vnc/config.d/vncserver-x11"
	sudo systemctl restart vncserver-x11-serviced.service


realvnc:
	wget https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.2-Linux-ARM.deb
	sudo mkdir -p /opt/vc/lib
	sudo cp lib/*.so /opt/vc/lib
	sudo dpkg -i VNC-Server-6.7.2-Linux-ARM.deb 
	sudo systemctl start vncserver-virtuald.service
	sudo systemctl start vncserver-x11-serviced.service
	sudo systemctl enable vncserver-virtuald.service
	sudo systemctl enable vncserver-x11-serviced.service
	rm VNC-Server-6.7.2-Linux-ARM.deb
	#the commands below are needed if you want to use 3rd party vnc clients, while connecting to Pi 
	sudo vncpasswd -service
	sudo sh -c "echo Authentication=VncAuth >> /root/.vnc/config.d/vncserver-x11"
	sudo systemctl restart vncserver-x11-serviced.service

upgrade_vnc:
	sudo systemctl stop x11vnc.service
	sudo systemctl disable x11vnc.service
	make realvnc

tigervnc :
	sudo apt -y install tigervnc-standalone-server tigervnc-common
	#vncserver
	#populate config file
	echo geometry=1920x1080 > ~/.vnc/config
	echo alwaysshared >> ~/.vnc/config
	echo localhost=no >> ~/.vnc/config
	#add user
	sudo sh -c "echo :1=$(USER) >>  /etc/tigervnc/vncserver.users"
	#populate xstartup
	echo "#!/bin/sh" > ~/.vnc/xstartup
	echo "unset SESSION_MANAGER">> ~/.vnc/xstartup
	echo "unset DBUS_SESSION_BUS_ADDRESS">> ~/.vnc/xstartup
	echo "/usr/bin/cinnamon-session">> ~/.vnc/xstartup
	#echo "[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup" >> ~/.vnc/xstartup
	#echo "[ -r $(HOME)/.Xresources ] && xrdb $(HOME)/.Xresources" >> ~/.vnc/xstartup
	echo "x-window-manager &" >> ~/.vnc/xstartup
	chmod u+x ~/.vnc/xstartup
	#create service
	sudo systemctl enable tigervncserver@:1.service
	sudo systemctl start tigervncserver@:1.service
	sudo systemctl status tigervncserver@:1.service




syncthing:
	curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
	echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	sudo apt-get update
	sudo apt-get install syncthing
	sudo systemctl enable syncthing@"$$USER".service
	sudo systemctl start syncthing@"$$USER".service

#Optional software, which can be installed separately, e.g.  "sudo make joplin" will install joplin

#Joplin is note taking app. This version is command line driven and can be connected to Dropbox for notes storage. It has desktop and mobile flavors. Useful for storing lists of objects to image etc.
joplin:
	sudo apt install -y npm
	NPM_CONFIG_PREFIX=~/.joplin-bin npm install -g joplin
	sudo ln -s ~/.joplin-bin/bin/joplin /usr/bin/joplin

arduino:
	wget https://downloads.arduino.cc/arduino-1.8.12-linuxarm.tar.xz
	xz -d arduino-1.8.12-linuxarm.tar.xz
	tar xvf arduino-1.8.12-linuxarm.tar
	sudo mv arduino-1.8.12 /opt
	sudo /opt/arduino-1.8.12/install.sh

libraw:
	sudo apt -y install git build-essential autoconf libtool
	mkdir -p ~/source
	cd ~/source && git clone https://github.com/LibRaw/LibRaw.git && cd LibRaw && autoreconf --install && ./configure && make
	cd ~/source && git clone https://github.com/pchev/libpasraw.git && cd libpasraw/raw && make -f Makefile.dev && cp libpasraw.so.1.1 ~/source/LibRaw/lib/.libs && ln -s ~/source/LibRaw/lib/.libs/libpasraw.so.1.1 ~/source/LibRaw/lib/.libs/libpasraw.so.1
	echo "export LD_LIBRARY_PATH=~/source/LibRaw/lib/.libs && ccdciel"   > ~/ccdciel.sh
	chmod 777 ~/ccdciel.sh


build_kstars:
	sudo apt -y install build-essential cmake git libeigen3-dev libcfitsio-dev zlib1g-dev libindi-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev  libkf5kio-dev kinit-dev libkf5newstuff-dev kdoctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libnova-dev libgsl-dev libraw-dev libkf5notifyconfig-dev wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme
	#mkdir -p ~/Projects/build/kstars && cd ~/Projects && git clone git://anongit.kde.org/kstars.git
	cd ~/Projects/build/kstars && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Debug ~/Projects/kstars && make
