pi4: update utils display desktop indi_kstars ccdciel_skychart phd vnc groups astrometry sample_startup
# wap


update:
	sudo apt update && apt -y upgrade
	sudo apt -y purge unattended-upgrades
	

#install general utilities
utils :
	sudo apt -y install net-tools mc git vim ssh x11vnc zsh synaptic fonts-roboto chromium-browser terminator remmina


display :
	sudo echo [all] > /boot/firmware/usercfg.txt
	sudo echo hdmi_force_hotplug=1 >> /boot/firmware/usercfg.txt
	sudo echo hdmi_ignore_edid=0xa5000080 >> /boot/firmware/usercfg.txt
	sudo echo hdmi_group=2 >> /boot/firmware/usercfg.txt
	sudo echo hdmi_mode=82 >> /boot/firmware/usercfg.txt
	sudo echo disable_overscan=1 >> /boot/firmware/usercfg.txt


desktop :
	sudo apt -y install kde-plasma-desktop plasma-nm  lightdm
#	apt -y install mate-desktop-environment lightdm
#	apt -y remove lxd lxd-client
#	rm -rf /etc/cloud/
#	rm -rf /var/lib/cloud/
#	apt -y install haveged
#	systemctl enable haveged
#	#fix wireless
#	sudo sed -i "s:0x48200100:0x44200100:g" /lib/firmware/brcm/brcmfmac43455-sdio.txt


indi_kstars :
	sudo apt-add-repository -y ppa:mutlaqja/ppa
	sudo apt update
	sudo apt -y install indi-full kstars-bleeding

astrometry :
	sudo apt -y install astrometry.net astrometry-data-tycho2 astrometry-data-2mass-08-19 astrometry-data-2mass-08-19 astrometry-data-2mass-07 astrometry-data-2mass-06 sextractor

#install ccdciel and skychart
ccdciel_skychart :
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2
	echo "deb http://www.ap-i.net/apt unstable main" > /tmp/1.tmp
	sudo cp /tmp/1.tmp /etc/apt/sources.list.d/skychart.list
	sudo apt update
	sudo apt -y install ccdciel skychart


#install phd2
phd :
	sudo add-apt-repository -y  ppa:pch/phd2
	sudo apt update && apt -y install phd2 phdlogview


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
	sudo echo  127.0.0.1 ubuntu >> /etc/hosts
#install hostapd, dnsmasq and create_ap
	sudo apt -y install hostapd dnsmasq make
	git clone https://github.com/oblique/create_ap
	cd create_ap
	sudo make install
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
	sudo echo [Unit] > $(VNC)
	sudo echo Description=Start x11vnc at startup. >> $(VNC)
	sudo echo After=multi-user.target >> $(VNC)
	sudo echo [Service]>> $(VNC)
	sudo echo Type=simple>> $(VNC)
	sudo echo ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared>> $(VNC)
	sudo echo [Install]>> $(VNC)
	sudo echo WantedBy=multi-user.target>> $(VNC)
	sudo x11vnc -storepasswd /etc/x11vnc.pass
	sudo systemctl enable x11vnc.service
	sudo systemctl start x11vnc.service


groups :
	sudo gpasswd --add ubuntu dialout


disable_auto_mount_of_dslr:
	gsettings set org.mate.media-handling automount false


#Optional software, which can be installed separately, e.g.  "sudo make joplin" will install joplin

#Joplin is note taking app. This version is command line driven and can be connected to Dropbox for notes storage. It has desktop and mobile flavors. Useful for storing lists of objects to image etc.
joplin:
	sudo apt install -y npm
	NPM_CONFIG_PREFIX=~/.joplin-bin npm install -g joplin
	sudo ln -s ~/.joplin-bin/bin/joplin /usr/bin/joplin

