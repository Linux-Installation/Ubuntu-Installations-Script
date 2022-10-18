#!/bin/bash
#(awk '{ print $2 }' /var/log/installer/media-info )
rep=""
pakete=""
service="" #be careful not fully implemented now!
remove=""

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
	declare dir=/home/$i/.dayon
	if [ -d $dir ] 
	then
	    overwriteDayon=true
	    sudo rm -rf /home/$i/.dayon
	fi
	if [ ! -d $dir ] || [ overwriteDayon==true ]
	then
		#echo $dir
		sudo mv -f $config/.dayon /home/$i							 
	fi		

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
		sudo mv -f $config/.config/gajim /home/$i/.config								 
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
		sudo mv -f $config/.config/google-chrome /home/$i/.config								 
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
		sudo mv -f $config/.mozilla /home/$i/
	fi
	sudo chown -R $i:$i /home/$i	
fi
done
fi
#Gaming on AMD/Intel
read -p "Möchtest du Games spielen und hast eine AMD/Intel Grafikkarte?"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
sudo add-apt-repository ppa:kisak/kisak-mesa
	pakete=`echo "$pakete mesa-vulkan-drivers mesa-vulkan-drivers:i386"`
fi

#Laptop Akkulaufzeit
read -p "Ist dies ein Laptop? Soll die Akkulaufzeit erhöht werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete tlp tlp-rdw smartmontools ethtool"`
	service=`echo "$service tlp.service"`
	#TODO Find PPA for TLPUI - https://github.com/d4nj1/TLPUI
fi

#Google Chrome
read -p "Soll Chromium installiert werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
    pakete=`echo "$pakete chromium-browser"`
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

paketerec="digikam exiv2 kipi-plugins graphicsmagick-imagemagick-compat"
pakete=`echo "$pakete synaptic krita-l10n ubuntu-restricted-extras pidgin pinta nfs-common language-pack-kde-de libdvd-pkg smartmontools unoconv mediathekview python3-axolotl python3-gnupg gnome-software gnome-software-plugin-flatpak language-pack-de fonts-symbola vlc libxvidcore4 libfaac0 gnupg2 lutris dayon kate konsole element-desktop firefox-locale-de firefox"`
remove=`echo "$remove firefox"`

sudo snap remove firefox
sudo apt remove -y $remove

#Updaten
cd ~/Downloads/
sudo apt install -y wget apt-transport-https
sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list

#Firefox ppa
sudo add-apt-repository -y ppa:mozillateam/ppa
#Don't use canonical firefox package
sudo sh -c 'echo "Package: firefox*" >> /etc/apt/preferences.d/mozillateamppa'
sudo sh -c 'echo "Pin: release o=LP-PPA-mozillateam" >> /etc/apt/preferences.d/mozillateamppa'
sudo sh -c 'echo "Pin-Priority: 501" >> /etc/apt/preferences.d/mozillateamppa'

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

sudo update-alternatives --set x-terminal-emulator /usr/bin/konsole

sudo dpkg-reconfigure libdvd-pkg
#flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#https://github.com/Bajoja/indicator-kdeconnect
read -p "Soll das Programm KDE-Connect-Monitor (Zugriff von und aufs Handy) installiert werden? Dann drücke j!"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	##sudo add-apt-repository -y ppa:webupd8team/indicator-kdeconnect outdated!
	sudo flatpak -y install flathub com.github.bajoja.indicator-kdeconnect
	sudo apt -y install kdeconnect
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
flatpak install flathub net.davidotek.pupgui2  
fi


#sudo snap install carnet

if [ ! -z $service ]
then
sudo systemctl enable $service
fi
sudo apt -y --fix-broken install
sudo dpkg-reconfigure -plow unattended-upgrades
#Aufräumen
rm -rf $verzeichnis/Install-Skript
