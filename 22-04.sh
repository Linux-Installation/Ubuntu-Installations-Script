#!/bin/bash
#(awk '{ print $2 }' /var/log/installer/media-info )
rep=""
pakete=""
service="" #be careful not fully implemented now!
remove=""

sudo apt-get update
sudo apt-get -y dist-upgrade

export DEBIAN_FRONTEND=noninteractive
if [ $( cat /etc/issue | cut -d" " -f2 | cut -d. -f1-2 ) != 22.04 ]  
then 
	read -p "Du benutzt kein Ubuntu Derivat der Version 22.04 Wenn du das Script trotzdem fortsetzen möchtest drücke j!"
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Jj]$ ]]
	then
    		exit 1
	fi
fi
if [ $(uname -m) = x86_64 ]
then
	Bit=64
elif [ $(uname -m) = i686 ]
then
	Bit=32
else
	echo "Konnte weder eine 32 Bit, noch eine 64 Bit Version vorfinden!"
	echo "Breche ab!"
	exit 1
fi
sudo sed -i "/recordfail_broken=/{s/1/0/}" /etc/grub.d/00_header
sudo update-grub
#Config-Daten
verzeichnis=$(pwd)
config=$(pwd)/download

if [ "$1" = "" ] || [ "$1" = "rep" ]
then
#Kopiere bei Bedarf Firefox, Chromium und gajim Einstellungen
alterUser=`who | awk '{ print $1 }'`

for i in $(ls /home); do
if [ $i != "lost+found" ]		
then
    #dayon
    sudo mkdir -p /home/$i/.dayon
	sudo cp -rf $config/.dayon /home/$i
	#hide Dayon Assistant
	sudo mkdir -p /home/$i/.local/share/applications
	sudo mv $config/.local/share/applications/dayon_assistant.desktop /home/$i/.local/share/applications/
	#gajim
	declare dir=/home/$i/.config/gajim
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis .config/gajim existiert schon, soll es überschrieben werden? Dann drücke j!"
	#	echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere gajim nicht"
		else
		    overwriteGajim=true
		    sudo rm -rf /home/$i/.config/gajim
		fi
	fi
	if [ ! -d $dir ] || [ overwriteGajim==true ]
	then
		#echo $dir
		sudo mkdir -p /home/$i/.config
		sudo cp -rf $config/.config/gajim /home/$i/.config								 
	fi		
	
	#Google Chrome
	declare dir=/home/$i/.config/google-chrome
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis .config/google-chrome existiert schon, soll es überschrieben werden? Dann drücke j!"
	#	echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere Google Chrome nicht"
		else
		    overwriteChrome=true
		    sudo rm -rf /home/$i/.config/google-chrome
		fi
	fi
	if [ ! -d $dir ] || [ overwriteChrome==true ]
	then
		#echo $dir
		sudo mkdir -p /home/$i/.config
		sudo cp -rf $config/.config/google-chrome /home/$i/.config								 
	fi		
	
	#Vivaldi
	declare dir=/home/$i/.config/vivaldi
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis .config/vivaldi existiert schon, soll es überschrieben werden? Dann drücke j!"
	#	echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere Vivaldi nicht"
		else
		    overwriteChrome=true
		    sudo rm -rf /home/$i/.config/vivaldi
		fi
	fi
	if [ ! -d $dir ] || [ overwriteChrome==true ]
	then
		#echo $dir
		sudo mkdir -p /home/$i/.config
		sudo cp -rf $config/.config/vivaldi /home/$i/.config								 
	fi	
	
	#firefox
	declare dir=/home/$i/.mozilla
	if [ -d $dir ] 
	then
		read -p "Das Verzeichnis Firefox existiert schon, soll es überschrieben werden? Dann drücke j!"
		echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Jj]$ ]]
		then
			echo "kopiere Firefox nicht"
		else
		    overwriteFirefox=true
		    sudo rm -rf /home/$i/.mozilla
		fi
	fi
	if [ ! -d $dir ] || [ overwriteFirefox==true ]
	then
	    #echo $dir
		sudo cp -rf $config/.mozilla /home/$i/
	fi
	#autostart
	sudo mkdir -p /home/$i/.config/autostart/
	sudo cp -rf $config/.config/autostart/* /home/$i/.config/autostart/*
	sudo chown -R $i:$i /home/$i	
fi
done
fi
#Gaming on AMD/Intel
read -p "Möchtest du Games spielen und hast eine AMD/Intel Grafikkarte? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
  sudo add-apt-repository -y ppa:kisak/kisak-mesa
	pakete=`echo "$pakete dxvk mesa-vulkan-drivers mesa-vulkan-drivers:i386"`
fi

#Vivaldi (Chromium based Browser)
read -p "Soll Vivaldi (Chromium based Browser) installiert werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
    echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list
    pakete=`echo "$pakete vivaldi-stable"`
fi


#gajim
read -p "Do you want to install gajim? Then press y!"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete gajim-plugininstaller gajim-rostertweaks gajim-urlimagepreview gajim-omemo"`
	read -p "Soll gajim für alle User automatisch gestartet werden? Dann drücke j!"
    #echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Jj]$ ]]
    then
        sudo sh -c 'echo "[Desktop Entry]" > /etc/xdg/autostart/gajim.desktop'
        sudo sh -c 'echo "Type=gajim" >> /etc/xdg/autostart/gajim.desktop'
        sudo sh -c 'echo "Name=gajim" >> /etc/xdg/autostart/gajim.desktop'
        sudo sh -c 'echo "Exec=gajim" >> /etc/xdg/autostart/gajim.desktop'
    fi
fi

#flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#https://github.com/Bajoja/indicator-kdeconnect
read -p "Soll das Programm KDE-Connect-Monitor (Zugriff von und aufs Handy) installiert werden? Dann drücke j!"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	##sudo add-apt-repository -y ppa:webupd8team/indicator-kdeconnect outdated!
	sudo flatpak -y install flathub com.github.bajoja.indicator-kdeconnect
	pakete=`echo "$pakete kdeconnect"`
fi

#Fritz!Box
read -p "Soll das Programm Roger Router (ehemals ffgtk) für die Fritz!Box installiert werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
sudo flatpak -y install flathub org.tabos.roger  
fi

#ProtonUp
read -p "Soll das Programm ProtonUp-Qt installiert werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
sudo flatpak -y install flathub net.davidotek.pupgui2  
fi

#Laptop Akkulaufzeit
read -p "Ist dies ein Laptop? Soll die Akkulaufzeit erhöht werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete tlp tlp-rdw smartmontools ethtool"`
	service=`echo "$service tlp.service"`
	sudo flatpak -y install flathub com.github.d4nj1.tlpui
	#TODO Find PPA for TLPUI - https://github.com/d4nj1/TLPUI
fi

#Ubuntu Mate
read -p "Are you using Ubuntu Mate and want to install the Advanced Mate Menu and a tool to administrativ users? Then press j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
    pakete=`echo "$pakete mate-menu gnome-system-tools"`
fi

#no 22.04 yet
#y-ppa-manager
#Entfernen
#pluma löschen, da ersatz ist konsole und kate
read -p "Soll pluma gelöscht werden? Dann drücke j!"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	remove=`echo "$remove pluma*"`
fi

paketerec="digikam exiv2 kipi-plugins graphicsmagick-imagemagick-compat hw-probe"
pakete=`echo "$pakete synaptic krita krita-l10n ubuntu-restricted-extras pidgin pinta nfs-common language-pack-kde-de libdvd-pkg smartmontools unoconv mediathekview python3-axolotl python3-gnupg gnome-software gnome-software-plugin-flatpak language-pack-de fonts-symbola vlc libxvidcore4 libfaac0 gnupg2 lutris dayon kate konsole element-desktop redshift-gtk firefox-l10n-de firefox"`
remove=`echo "$remove firefox*"`

sudo snap remove firefox
sudo apt remove -y $remove

#Updaten
cd ~/Downloads/
sudo apt install -y wget apt-transport-https
sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list

#Firefox ppa
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
#Don't use canonical firefox package
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

sudo add-apt-repository -y ppa:regal/dayon

#no 22.04 yet
#sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager

#Aktiviert die Standard Ubuntu Quellen für Fremd-Software-Entwickler
sudo add-apt-repository -y "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" 

echo $rep > rep.log

IFS=" "
oIFS=$IFS
for i in $rep; do
	sudo add-apt-repository -y $i
done
#fi

sudo apt-get update
sudo apt-get -y dist-upgrade
echo $paketerec > paketerec.log
sudo apt -y install --no-install-recommends $paketerec
echo $pakete > pakete.log
sudo apt -y install $pakete

#hide Dayon Assistant
sudo mv $config/usr/share/applications/dayon_assistant.desktop /usr/share/applications/

sudo update-alternatives --set x-terminal-emulator /usr/bin/konsole

sudo dpkg-reconfigure libdvd-pkg


#sudo snap install carnet

if [ ! -z $service ]
then
sudo systemctl enable $service
fi
sudo apt -y --fix-broken install
sudo dpkg-reconfigure -plow unattended-upgrades
sudo cp -f $config/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
sudo cp -f $config/firefoxUpdateOnShutdown.service /etc/systemd/system/firefoxUpdateOnShutdown.service
sudo systemctl daemon-reload
sudo systemctl enable firefoxUpdateOnShutdown.service

#Hardware probe
sudo -E hw-probe -all -upload
sudo apt-get purge -y hw-probe

#Aufräumen
rm -rf $verzeichnis/Install-Skript
