pi4: tz update utils speedup display mate-desktop indi_kstars ccdciel_skychart phd vnc groups astrometry sample_startup syncthing
# wap

tz:
	sudo dpkg-reconfigure tzdata

update:
	sudo apt update
	sudo apt -y upgrade
	sudo apt -y purge unattended-upgrades
	

#install general utilities
utils :
	sudo apt -y install net-tools firefox mc git vim ssh x11vnc zsh synaptic fonts-roboto terminator remmina chromium-browser

display :
	sudo sh -c "echo '[all]' > /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_force_hotplug=1' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_ignore_edid=0xa5000080' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_group=2' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'hdmi_mode=82' >> /boot/firmware/usercfg.txt"
	sudo sh -c "echo 'disable_overscan=1' >> /boot/firmware/usercfg.txt"


kde-desktop :
	sudo apt -y install kde-plasma-desktop plasma-nm  lightdm

speedup :
	sudo apt -y purge cloud-init
	sudo rm -rf /etc/cloud/
	sudo rm -rf /var/lib/cloud/


mate-desktop :
	sudo apt -y install mate-desktop-environment lightdm


indi_kstars :
	sudo apt-add-repository -y ppa:mutlaqja/ppa
	sudo apt update
#Some packages, required for indi-full are not available, so we have to install packages one by one
	sudo apt -y install indi-bin indi-dsi indi-asi indi-sbig indi-sx indi-gphoto gphoto2
	sudo apt -y install kstars-bleeding

astrometry :
	sudo apt -y install astrometry.net astrometry-data-tycho2 astrometry-data-2mass-08-19 astrometry-data-2mass-08-19 astrometry-data-2mass-07 astrometry-data-2mass-06 sextractor

#install ccdciel and skychart
ccdciel_skychart :
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2
	sudo sh -c "echo 'deb http://www.ap-i.net/apt unstable main' > /etc/apt/sources.list.d/skychart.list"
	sudo apt update
	sudo apt -y install ccdciel skychart


#install phd2
phd :
	sudo add-apt-repository -y  ppa:pch/phd2
	sudo apt update
	sudo apt -y install phd2 phdlogview


#create a sample INDI startup shell script
sample_startup :
	echo "indiserver -v indi_lx200_OnStep indi_sbig_ccd indi_asi_ccd indi_sx_wheel" > ~/indi.sh
	chmod 777 ~/indi.sh


#Setting up Wireless Access Point
wap :
#before doing everything eles, need to disable built in name resolver 
	sudo systemctl stop systemd-resolved
	sudo systemctl disable systemd-resolved
	sudo rm /etc/resolv.conf
	sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
	sudo chattr -e /etc/resolv.conf
	sudo chattr +i /etc/resolv.conf
	sudo sh -c "echo  '127.0.0.1 ubuntu' >> /etc/hosts"
#install hostapd, dnsmasq and create_ap
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

astap:
	wget https://phoenixnap.dl.sourceforge.net/project/astap-program/star_databases/g17_star_database_mag17.deb
	sudo dpkg -i g17_star_database_mag17.deb
	wget https://svwh.dl.sourceforge.net/project/astap-program/linux_installer/astap_armhf.deb
	sudo dpkg -i astap_armhf.deb

groups :
	sudo gpasswd --add ubuntu dialout


disable_auto_mount_of_dslr:
	gsettings set org.mate.media-handling automount false


syncthing:
	curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
	echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	sudo apt-get update
	sudo apt-get install syncthing
	sudo systemctl enable syncthing@ubuntu.service
	sudo systemctl start syncthing@ubuntu.service

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

