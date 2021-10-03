#!/bin/bash
#(awk '{ print $2 }' /var/log/installer/media-info )
#Version=
#rep angeben wenn ohne kopieren installiert werden soll!
#Nemo
#rep="ppa:webupd8team/nemo"
rep=""
#Installiere VLC
pakete="vlc"

export DEBIAN_FRONTEND=noninteractive
if [ $( cat /etc/issue | cut -d" " -f2 | cut -d. -f1-2 ) != 20.04 ]  
then 
	read -p "Du benutzt kein Ubuntu Derivat der Version 20.04 Wenn du das Script trotzdem fortsetzen möchtest drücke j!"
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
#read -p "Wenn die oben genannten Angaben korrekt sind und alle nötigen Benutzer angelegt sind, drücke j!"
#echo    # (optional) move to a new line
#if [[ ! $REPLY =~ ^[Jj]$ ]]
#then
#	exit 1
#fi
#Config-Daten
verzeichnis=$(pwd)
#mkdir Install-Skript
#cd Install-Skript
#wget -O config.zip https://xxxx/index.php/s/ubuntu-Installation/download
#unzip config.zip
#cd NAS-Ubuntu-Installation/Download
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

		#thunderbird gegen evolution ersetzen
		#cd /home
		#declare dir=$i/.thunderbird
		#if [ -d $dir ] 
		#then
			#read -p "Das Verzeichnis Thunderbird existiert schon, soll es überschrieben werden? Dann drücke j!"
			#echo    # (optional) move to a new line
			#if [[ ! $REPLY =~ ^[Jj]$ ]]
			#then
			#	echo "kopiere Thunderbird nicht"
			#else
				#cd /home/$i
			#	#sudo smbclient //192.168.2.2/daten-raid -N -c 'prompt;recurse;cd Backup\Ubuntu-Installation\Download\;mget ".thunderbird"'
			#	cp -r /media/NAS/Download/.thunderbird /home/${i}/
			#	sudo chown -R $i:$i /home/${i}/.thunderbird
			#fi
		#else
			#cd /home/$i
			#sudo smbclient //192.168.2.2/daten-raid -N -c 'prompt;recurse;cd Backup\Ubuntu-Installation\Download\;mget ".thunderbird"'
			#cp -r /media/NAS/Download/.thunderbird /home/${i}/
			#sudo chown -R $i:$i /home/${i}/.thunderbird
		#fi
		#cd /home/$i
	sudo chown -R $i:$i /home/$i	
fi
done
#sudo umount /media/NAS
#sudo rmdir /media/NAS
fi
#Laptop Akkulaufzeit
read -p "Ist dies ein Laptop? Soll die Akkulaufzeit erhöht werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete tlp tlp-rdw smartmontools ethtool"`
fi

#Google Chrome
read -p "Soll Chromium installiert werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
    #if [ $Bit == 64 ]
    #then
        pakete=`echo "$pakete chromium-browser"`
    	#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    	#sudo dpkg -i google-chrome-stable_current_amd64.deb
    	#rm google-chrome-stable_current_amd64.deb
    #else
    
   # fi    	
fi

#guake
read -p "Soll das Programm guake (Terminal zum herunterklappen) installiert werden? Dann drücke j!"
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	pakete=`echo "$pakete guake"`
fi

#Terminal für den Nemo Dateimanager
#read -p "Soll ein Terminal in den Nemo Dateimanager integriert werden? Dann drücke j!"
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Jj]$ ]]
#				then
#				pakete=`echo "$pakete nautilus-terminal"`
				#echo "nemo-terminal gibt es noch nicht für 18.04"				
#				sudo cp -r /media/NAS/Download/.nautilus-terminal /home/${i}
#				cd /home/${i}
#				sudo smbclient //192.168.2.2/daten-raid -N -c 'prompt;recurse;cd Backup\Ubuntu-Installation\Download\;mget ".nautilus-terminal"'
#fi

#Skype - muss neu getestet werden! - snap oder deb?
#read -p "Soll Skype installiert werden? Dann drücke j!"
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Jj]$ ]]
#then
#	pakete=`echo "$pakete skype"`
#	if [ $Bit == 64 ]
#	then
#		pakete=`echo "$pakete gtk2-engines-murrine:i386 gtk2-engines-pixbuf:i386"`
#	fi	
#fi

read -p "Soll gajim für alle User automatisch gestartet werden? Dann drücke j!"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
	sudo sh -c 'echo "[Desktop Entry]" > /etc/xdg/autostart/gajim.desktop'
	sudo sh -c 'echo "Type=gajim" >> /etc/xdg/autostart/gajim.desktop'
	sudo sh -c 'echo "Name=gajim" >> /etc/xdg/autostart/gajim.desktop'
	sudo sh -c 'echo "Exec=gajim" >> /etc/xdg/autostart/gajim.desktop'
fi
#read -p "Soll Cairo-Dock installiert werden? (nur für schnell Rechner (Ab Dual Core)) Dann drücke j!"
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Jj]$ ]]
#then
	#Cairo-Dock
#	echo "deb http://ppa.launchpad.net/cairo-dock-team/ppa/ubuntu $(lsb_release -sc) main # Cairo-Dock-PPA" | sudo tee -a /etc/apt/sources.list
 #   	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E80D6BF5
#	pakete=`echo "$pakete cairo-dock cairo-dock-plug-ins"`
#	read -p "Soll ein Programm zum ändern des Desktops installiert werden? (Nur für erfahrene Nutzer!) Dann drücke j!"#
#	echo    # (optional) move to a new line
#	if [[ $REPLY =~ ^[Jj]$ ]]
#	then
#		pakete=`echo "$pakete compizconfig-settings-manager"`
#	fi 
#fi
#sudo apt-get -y install --no-install-recommends 

paketerec="digikam exiv2 kipi-plugins graphicsmagick-imagemagick-compat"
pakete=`echo "$pakete synaptic krita ubuntu-restricted-extras pidgin pinta nfs-common grub-customizer language-pack-kde-de y-ppa-manager libdvd-pkg smartmontools ethtool unoconv gnumeric appgrid mediathekview python3-axolotl gajim-omemo gajim-plugininstaller gajim-rostertweaks gajim-urlimagepreview python3-gnupg flatpak gnome-software gnome-software-plugin-flatpak ubuntu-restricted-extras language-pack-de-base language-pack-de fonts-symbola vlc libxvidcore4 libfaac0 gnupg2 lutris dayon kate konsole element-desktop"`
#outdatet: enigmail (wegen thunderbird) nemo
#gloobus-preview emo-compare nemo-fileroller nemo-compare nemo-media-columns nemo-pastebin nemo-seahorse nemo-share nemo-gloobus-sushi
# alt 14.04: && sudo /usr/share/doc/libdvdread4/install-css.sh
#popper
#nemo-preview 

#Entfernen
if [ `(awk '{ print $1 }' /var/log/installer/media-info )` = Ubuntu ] #Entfernt "Ubuntu Schnüffler"
then
sudo apt-get -y remove unity-webapps-common
fi

#Updaten
cd ~/Downloads/
#if [ "$1" = "rep" ]
#then
##Paketquellen
#Teamviewr

#wget https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc
#sudo apt-key add TeamViewer2017.asc
#sudo sh -c 'echo "deb http://linux.teamviewer.com/deb stable main" >> /etc/apt/sources.list.d/teamviewer.list'
#sudo apt update - nicht notwendig, wird später gemacht.
#rm TeamViewer2017.asc
#sudo sh -c 'echo "deb http://linux.teamviewer.com/deb stable main" >> /etc/apt/sources.list.d/teamviewer.list'
sudo apt install -y wget apt-transport-https
sudo wget -O /usr/share/keyrings/riot-im-archive-keyring.gpg https://packages.riot.im/debian/riot-im-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/riot-im-archive-keyring.gpg] https://packages.riot.im/debian/ default main" | sudo tee /etc/apt/sources.list.d/riot-im.list


sudo add-apt-repository -y ppa:regal/dayon

#mailnag/popper - ohne das Thunderbird aktiv ist wird auf neue eMails kontrolliert
#sudo add-apt-repository -y ppa:pulb/mailnag
#sudo add-apt-repository -y "deb http://ppa.launchpad.net/appgrid/stable/ubuntu xenial main"
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 241FE6973B765FAE #appgrid
sudo add-apt-repository -y ppa:appgrid/stable
sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager
sudo add-apt-repository -y ppa:lutris-team/lutris
#sudo add-apt-repository -y "deb http://ppa.launchpad.net/webupd8team/nemo/ubuntu xenial main" #Nemo gibt es noch nicht für 18.04!


#Aktiviert die Standard Ubuntu Quellen für Fremd-Software-Entwickler
sudo add-apt-repository -y "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" 
#sudo add-apt-repository -y ppa:nilarimogard/webupd8 gibt es noch nicht für 18.04!
#flatpack - ab Ubuntu 16.10 nicht mehr nötig
#sudo add-apt-repository -y ppa:alexlarsson/flatpak

echo $rep > rep.log

IFS=" "
oIFS=$IFS
for i in $rep; do
	sudo add-apt-repository -y $i
done
#fi

#pluma und mate-terminal löschen, da ersatz ist konsole und kate
read -p "Soll pluma gelöscht werden? Dann drücke j!"
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Jj]$ ]]
then
    sudo apt-get -y remove pluma*
fi

sudo apt-get update
sudo apt-get -y upgrade
echo $paketerec > paketerec.log
sudo apt -y install --no-install-recommends $paketerec
echo $pakete > pakete.log
sudo apt -y install $pakete

sudo update-alternatives --set x-terminal-emulator /usr/bin/konsole

sudo dpkg-reconfigure libdvd-pkg
#flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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
#	sudo add-apt-repository -y 'deb http://download.opensuse.org/repositories/home:/tabos-team:/release/xUbuntu_16.04/ ./'
#	wget -q http://download.opensuse.org/repositories/home:/tabos-team:/release/xUbuntu_16.04/Release.key -O- | sudo apt-key add - 
#	pakete=`echo "$pakete roger roger-plugins-fritzfon roger-plugins-google roger-plugins-thunderbird roger-plugins-vcard roger-plugins-notification roger-plugins-indicator"`
	#for i in $(ls /home); do
	#	if [ $i != "lost+found" ]		
	#	then
	#		sudo addgroup $i fax     ## BENUTZERNAME entsprechend anpassen
	#	fi	
	#done
	#newgrp - fax #führt zum scriptabbruch! 
sudo flatpak -y install flathub org.tabos.roger  
fi
sudo snap install carnet
#Nemo als Standard Dateimanager
#read -p "Soll Nemo der Standard Dateimanager werden? Dann drücke j!"
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Jj]$ ]]
#then
#	sudo apt install -y dconf-tools
#	gsettings set org.gnome.desktop.background show-desktop-icons false
#	xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

sudo apt -y --fix-broken install

#Aufräumen
rm -rf $verzeichnis/Install-Skript
	
#	NemoStandard=notLubuntu
#fi
#Autostartprogramme anzeigen
#sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
#echo "Installation abgeschlossen!"
#echo "Sind mehrere Desktop gewünscht, können diese unter Systemeinstellungen -> Darstellung -> Verhalten aktiviert werden."
#echo "Die versteckten Autostartprogramme können mit dem Befehl können mit folgendem Befehl wieder ausgeblendet werden:"
#echo "sudo sed -i "s/NoDisplay=false/NoDisplay=true/g" /etc/xdg/autostart/*.desktop"
#if [ $NemoStandard == notLubuntu ]
#then
#	echo "Wenn nautilus wieder der Standard Dateimanager werden soll, muss folgendes eingegeben werden:"
#	echo "gsettings set org.nemo.desktop show-desktop-icons false"
#	echo "gsettings set org.gnome.desktop.background show-desktop-icons true"
#fi
