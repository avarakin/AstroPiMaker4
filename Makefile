pi4: update pi4_setup utils indi_kstars ccdciel_skychart phd vnc groups astrometry disable_auto_mount_of_dslr sample_startup groups wap



disable_auto_mount_of_dslr:
	gsettings set org.mate.media-handling automount false

update:
	apt-get update && apt-get -y upgrade 
	apt-get -y purge unattended-upgrades
	
update_firmware:
	git clone --depth 1 https://github.com/raspberrypi/firmware
	cp -r firmware/boot/* /boot/firmware/
	cp -r firmware/modules/* /lib/modules

#install general utilities
utils :
	apt -y install mc git vim ssh x11vnc zsh synaptic fonts-roboto chromium-browser terminator remmina

system_setup :
	apt -y install mate-desktop-environment lightdm
	apt -y remove lxd lxd-client
	rm -rf /etc/cloud/
	rm -rf /var/lib/cloud/
	apt -y install haveged
	systemctl enable haveged
	#fix wireless
	sudo sed -i "s:0x48200100:0x44200100:g" /lib/firmware/brcm/brcmfmac43455-sdio.txt


indi_kstars :
	apt-add-repository -y ppa:mutlaqja/ppa
	apt-get update
	apt-get -y install indi-full kstars-bleeding

astrometry :
	apt-get -y install astrometry.net astrometry-data-tycho2 astrometry-data-2mass-08-19 astrometry-data-2mass-08-19 astrometry-data-2mass-07 astrometry-data-2mass-06 sextractor

#install ccdciel and skychart
ccdciel_skychart :
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2
	echo "deb http://www.ap-i.net/apt unstable main" > /tmp/1.tmp && cp /tmp/1.tmp /etc/apt/sources.list.d/skychart.list
	apt-get update && apt-get -y install ccdciel skychart


#install phd2
phd :
	add-apt-repository -y  ppa:pch/phd2 && apt-get update && apt-get -y install phd2 phdlogview


#create a sample INDI startup shell script
sample_startup :
	echo "indiserver -v indi_lx200_OnStep indi_sbig_ccd indi_asi_ccd indi_sx_wheel" >> /home/ubuntu/indi.sh
	chmod 777 /home/ubuntu/indi.sh
	chown ubuntu:ubuntu /home/ubuntu/indi.sh


#Setting up Wireless Access Point
wap :
	apt-get -y install hostapd dnsmasq make
	cd ~ && git clone https://github.com/oblique/create_ap && cd create_ap && make install
	#configure access point id and password
	sed -i.bak 's/SSID=MyAccessPoint/SSID=RPI/'  /etc/create_ap.conf 
	sed -i.bak 's/PASSPHRASE=12345678/PASSPHRASE=password/'  /etc/create_ap.conf 
	systemctl enable create_ap
	systemctl start create_ap
	systemctl status create_ap
	echo It would be a good idea to reboot now!


#configure x11vnc 
VNC=/lib/systemd/system/x11vnc.service
vnc :
	echo [Unit] > $(VNC)
	echo Description=Start x11vnc at startup. >> $(VNC)
	echo After=multi-user.target >> $(VNC)
	echo [Service]>> $(VNC)
	echo Type=simple>> $(VNC)
	echo ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared>> $(VNC)
	echo [Install]>> $(VNC)
	echo WantedBy=multi-user.target>> $(VNC)
	x11vnc -storepasswd /etc/x11vnc.pass
	systemctl enable x11vnc.service
	systemctl start x11vnc.service


groups :
	gpasswd --add ubuntu dialout



#Optional software, which can be installed separately, e.g.  "sudo make joplin" will install joplin

#Joplin is note taking app. This version is command line driven and can be connected to Dropbox for notes storage. It has desktop and mobile flavors. Useful for storing lists of objects to image etc.
joplin:
	apt-get install -y npm
	NPM_CONFIG_PREFIX=~/.joplin-bin npm install -g joplin
	ln -s ~/.joplin-bin/bin/joplin /usr/bin/joplin

