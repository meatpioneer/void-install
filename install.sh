#!/bin/bash

# goto-like function for bash
# continuing after reboot
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}
start=${1:-"start"}
jumpto $start
start:
if [ -f reboot1.txt ]; then
	jumpto reboot1
else
	echo "continue"
fi

# # # # > Bases
# # # make sure void-linux is up-to-date
sudo xbps-install --yes -Su

# # # flatpak is a 3rd party package manager
# # # polkit creates an organized way for non-privileged tasks to communicate with privileged ones
# # # dbus is a mechanism that allows communication between multiple processes running concurrently
sudo xbps-install --yes base-devel wget flatpak polkit dbus elogind meson ninja vsv neovim neofetch xorg alacritty ranger htop chromium

# a repo that contains the xbps source packages collection
git clone https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap

# gtk3
 sudo xbps-install --yes gtk+3-devel

# add flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ranger config
sudo mkdir ~/.config/ranger
sudo chmod 777 ~/.config/ranger

# nvim config
sudo mkdir -p ~/.config/nvim
cd ~/.config/nvim
sudo touch init.vim
sudo bash -c 'echo "set number" >> ~/.config/nvim/init.vim'
cd

# # # curl is a cmd tool that is used to transfer data from a server
# # # rust is a lower level programming language. it enforces memory safety, meaning that all references point to valid memory, without a garbage collector
# force yes
sudo xbps-install --yes curl
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
> ~/reboot1.txt
sudo reboot

# start from reboot
reboot1:
sudo rustup default stable

# # # vim-plug is a nvim and vim plugin manager
sudo sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# # # java is a programming lanuage. it uses the java runtime environment
sudo xbps-install --yes openjdk-jre openjdk11-jre openjdk17-jre openjdk21-jre

# modify bash profile (add XDG_RUNTIME_DIR)
sudo xbps-install --yes dumb_runtime_dir

# # # # > Graphical Environment
# # # waybar is a bar for wayland
# # # tofi is an applauncher
# # # sway is a tiling window manager and wayland compositor
# # # wayland is a replacement for the X11 window system aimed to be easier to develop, extend, and maintain. 
# # # wayland is the protocol that applications can use to talk to a display server in order to make themselves visible and get input from the user. 
# # # a wayland server is called a "compositor". applications are Wayland clients
sudo xbps-install --yes qt5-wayland qt6-wayland sway Waybar tofi
sudo xbps-install --yes --repository=hostdir/binpkgs wlroots

# sway config
sudo mkdir -p ~/.config/sway/
sudo cp /etc/sway/config ~/.config/sway/config
sudo sed -i '10s/.*/set $mod Mod1/' ~/.config/sway/config
sudo sed -i '17s/.*/set $term alacritty/' ~/.config/sway/config
sudo sed -i '21s/.*/set $menu tofi-drun | wmenu | xargs swaymsg exec --/' ~/.config/sway/config
~/.config/sway/config

# tofi config
sudo mkdir -p ~/.config/tofi
sudo cp /etc/xdg/tofi/config ~/.config/tofi
sudo sed -i '276s/.*/        drun-launch = true/' ~/.config/tofi/config

# # # sov is workspace overview for sway
git clone https://github.com/milgra/sov.git
cd sov
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install

# # # wsbg is a wallpaper utility for sway
sudo xbps-install --yes scdoc
git clone https://github.com/saibier/wsbg.git
cd wsbg
meson setup build/
ninja -C build/
sudo ninja -C build/ install

# # # wlay is a graphical output manager for wayland
sudo xbps-install --yes extra-cmake-modules glfw-wayland glfw-devel
# git clone https://github.com/atx/wlay.git
# cd wlay
#sudo mkdir build
# cd build
# cmake ..
# make
# ./wlay
# cd

# # # base16 & base16 universal manager

# xinit display manager
> ~/.xinitrc
echo "exec dbus-run-session sway" >> ~/.xinitrc

# # # greetd is a system login and authentication daemon for wayland display managers
sudo xbps-install --yes greetd

# # # tuigreet is a wayland greeter for greetd
# # do not use vt value of 1 because grub is already set to such
# (\”) is interpreted as (“)
git clone https://github.com/apognu/tuigreet && cd tuigreet
sudo cargo build --release
sudo mv target/release/tuigreet /usr/local/bin/tuigreet
sudo mkdir /var/cache/tuigreet
sudo chown ailbhe:ailbhe /var/cache/tuigreet
sudo chmod 0755 /var/cache/tuigreet
sudo sed -i '11s/.*/command = \"tuigreet --cmd sway\”/' /etc/greetd/config.toml
sudo sed -i '16s/.*/user = \“ailbhe\”/' /etc/greetd/config.toml

# # # # > Experience
# desktop portal (for specific gui interactions and other)
sudo xbps-install --yes xdg-desktop-portal xdg-desktop-portal-wlr

# default application handler
sudo cargo install handlr-regex

# # # pipewire is an audio pipeline
sudo xbps-install --yes pipewire wireplumber pavucontrol rtkit
sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

# append autostart pipewire to sway config
sudo bash -c 'echo "exec pipewire" >> /home/ailbhe/.config/sway/config'
sudo bash -c 'echo "exec pipewire-pulse" >> /home/ailbhe/.config/sway/config'
sudo bash -c 'echo "exec wireplumber" >> /home/ailbhe/.config/sway/config'

# # # cmus is a music player
sudo xbps-install flac cmus
cd ~/.config/cmus
sudo touch rc.conf
sudo bash -c 'echo "set output_plugin=alsa" >> ~/.config/cmus/rc.conf'
sudo bash -c 'echo "set dsp.alsa.device=default" >> ~/.config/cmus/rc.conf'
sudo bash -c 'echo "set mixer.alsa.device=default" >> ~/.config/cmus/rc.conf'
sudo bash -c 'echo "set mixer.alsa.channel=Master" >> ~/.config/cmus/rc.conf'
cd /usr/share/applications
sudo touch cmus.desktop
sudo bash -c 'echo "[Desktop Entry]" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Version=1.0" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Name=cmus" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Type=Application" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Comment=A small, fast and powerful console music player" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Terminal=true" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Exec=cmus" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Categories=ConsoleOnly;Audio;Player;" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "GenericName=Music player" >> /usr/share/applications/cmus.desktop'
sudo bash -c 'echo "Keywords=cmus;audio;player;" >> /usr/share/applications/cmus.desktop'
cd

# # # nvm is a manager for javascript node
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
nvm install 20
nvm use 20

# # # mpv is a free media player for the command line
# # # mpv-image-viewer is an image viewer for mpv
sudo xbps-install --yes mpv

# make flatpak work
sudo bash -c 'echo "export $(dbus-launch)" >> /etc/profile'

# # # modrinth is a 3rd party minecraft launcher
# modrinth
sudo flatpak install -y flathub com.modrinth.ModrinthApp

# # # steam is a games platform
sudo flatpak install -y flathub com.valvesoftware.Steam

# # # electron is a framework for building desktop applications
# sudo xbps-install electron19 electron24

# # # discord is a chat and audio/video calling service
# cd void-packages
#echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
# ./xbps-src pkg discord
# sudo xbps-install --repository=hostdir/binpkgs/nonfree discord

# # # betterdiscord is an addon to discord
# curl -O https://raw.githubusercontent.com/bb010g/betterdiscordctl/master/betterdiscordctl
# chmod +x betterdiscordctl
# sudo mv betterdiscordctl /usr/local/bin

# # # yubikey is a security key
xbps-install --yes u2f-hidraw-policy gnupg2-scdaemon yubikey-manager pcsc-ccid pcsclite

# # # # > End
# change ~/ permissions
sudo chown -R ailbhe:ailbhe ~/
sudo chmod -R 755 ~/
# add to /var/service (dbus, greetd)
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/greetd /var/service
# delete reboot files
sudo rm -r reboot1.txt
