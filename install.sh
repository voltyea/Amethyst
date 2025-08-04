#!/bin/bash

rfkill unblock wlan
rfkill unblock bluetooth

# adding chaotic-aur
if [ ! -f /etc/pacman.d/chaotic-mirrorlist ]; then

  {
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB

    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  } || { exit 1; }

  if ! grep -qF "[chaotic-aur]" /etc/pacman.conf; then
    echo -e "\n\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    sudo pacman -Syu
  fi
fi

#adding insults to sudo
echo "Defaults insults" | sudo tee /etc/sudoers.d/insults

#Pacman stuff
if ! grep -qF "ILoveCandy" /etc/pacman.conf; then
  if grep -q "^\[options\]" /etc/pacman.conf; then
    # Append ILoveCandy under existing [options]
    sudo sed -i '/^\[options\]/a ILoveCandy' /etc/pacman.conf
  else
    # Add new [options] section with ILoveCandy
    echo -e "\n[options]\nILoveCandy" | sudo tee -a /etc/pacman.conf
  fi
fi

sudo sed -i 's/^#Color$/Color/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf

#enabling multilib repository
if grep -q "^#[multilib]" /etc/pacman.conf; then
  sudo sed -i 's/^#[multilib]$/[multilib]/' /etc/pacman.conf
fi
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  sudo tee -a /etc/pacman.conf >/dev/null <<EOF
  [multilib]
  Include = /etc/pacman.d/mirrorlist
EOF
fi
sudo sed -i '/^\[multilib\]/,/^\[/{s/^#\(Include = \/etc\/pacman\.d\/mirrorlist\)/\1/}' /etc/pacman.conf

sudo pacman -Syu --needed rate-mirrors paru
sudo curl -o /usr/bin/update https://raw.githubusercontent.com/voltyea/Amethyst/main/update
sudo chmod +x /usr/bin/update
update
update
sudo pacman -Syu
curl -o /tmp/conflict_pkg.lst https://raw.githubusercontent.com/voltyea/Amethyst/main/conflict_pkg.lst
xargs -a /tmp/conflict_pkg.lst paru -Syu --needed
curl -o /tmp/pkg.lst https://raw.githubusercontent.com/voltyea/Amethyst/main/pkg.lst
xargs -a /tmp/pkg.lst paru -Syu --needed

#cpu stuff
vendor=$(grep -m 1 'vendor_id' /proc/cpuinfo | awk '{print $3}')
case "$vendor" in
GenuineIntel)
  sudo pacman -S --needed intel-ucode intel-media-driver libva-intel-driver vulkan-intel lib32-vulkan-intel
  ;;
AuthenticAMD)
  sudo pacman -S --needed amd-ucode libva-mesa-driver vulkan-radeon xf86-video-amdgpu xf86-video-ati lib32-vulkan-radeon
  ;;
esac

#changing grub timeout
if grep -q "^GRUB_TIMEOUT=" /etc/default/grub; then
  sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
fi

#changing systemd logind.conf so that it won't turn off wifi when laptop lid is closed
# Set HandleLidSwitch=ignore in /etc/systemd/logind.conf to prevent suspend on lid close
if grep -qE '^\s*HandleLidSwitch=' /etc/systemd/logind.conf; then
  sudo sed -i 's/^\s*HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
else
  echo 'HandleLidSwitch=ignore' | sudo tee -a /etc/systemd/logind.conf
fi

#installing rust
rustup default stable

#installing dotfiles
git clone https://github.com/voltyea/dotfiles.git $HOME/.local/share/Elements/
git -C $HOME/.local/share/Elements/ pull
default="Anemo"
cp -r $HOME/.local/share/Elements/dotfiles/$default/. $HOME/

#setting up sddm theme
sudo mkdir -p /etc/sddm.conf.d/
sudo cp $HOME/.local/share/Elements/sddm/$default/sddm.conf /etc/sddm.conf.d/
sudo cp -r $HOME/.local/share/Elements/sddm/$default/$default/ /usr/share/sddm/themes/

#Copying Wallpapers
git clone https://github.com/voltyea/Wallpapers.git $HOME/Wallpapers/
git -C $HOME/Wallpapers/ pull

#Setting up touchpad tapping and user profile picture.
sudo curl -o /usr/share/sddm/faces/$USER.face.icon https://raw.githubusercontent.com/voltyea/Amethyst/main/user_face_icons/user.face.icon
sudo mkdir -p /etc/X11/xorg.conf.d/
sudo curl -o /etc/X11/xorg.conf.d/30-touchpad.conf https://raw.githubusercontent.com/voltyea/Amethyst/main/30-touchpad.conf
curl -o $HOME/.face.icon https://raw.githubusercontent.com/voltyea/Amethyst/main/user_face_icons/user.face.icon

#install catppuccin cursor theme
#copying the catppuccin-mocha mauve cursor theme, you can change it if you like.
cp -r /usr/share/icons/catppuccin-mocha-mauve-cursors/ $HOME/.local/share/icons/
cp -r /usr/share/icons/catppuccin-mocha-mauve-cursors/ $HOME/.icons/
sudo cp -r /usr/share/icons/catppuccin-mocha-mauve-cursors/ /usr/share/themes/
cp -r /usr/share/icons/catppuccin-mocha-mauve-cursors/ $HOME/.themes/

#setting the gtk xcursor theme
gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-mauve-cursors'

#setting the flatpak theme
flatpak override --filesystem=$HOME/.themes:ro --filesystem=$HOME/.icons:ro --user

#remapping keys (keyd)
sudo systemctl enable keyd --now
sudo mkdir -p /etc/keyd/
sudo curl -o /etc/keyd/default.conf https://raw.githubusercontent.com/voltyea/Amethyst/main/default.conf
sudo usermod -aG keyd $USER
sudo usermod -aG input $USER

#Applying gtk theme
mkdir -p $HOME/.local/share/themes/
cp -r /usr/share/themes/. $HOME/.local/share/themes/
sudo flatpak override --filesystem=$HOME/.local/share/themes
FLAVOR="mocha"
ACCENT="mauve"
sudo flatpak override --env=GTK_THEME="catppuccin-${FLAVOR}-${ACCENT}-standard+default"

#installing nessecary fonts
sudo mkdir -p /usr/local/share/fonts/

sudo curl -o /usr/local/share/fonts/icomoon.ttf https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/icomoon/fonts/icomoon.ttf
sudo curl -o "/usr/local/share/fonts/JetBrains Mono Nerd.ttf" "https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/JetBrains/JetBrains%20Mono%20Nerd.ttf"
sudo curl -o /usr/local/share/fonts/Midorima-PersonalUse-Regular.ttf https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/midorima/Midorima-PersonalUse-Regular.ttf
sudo curl -o /usr/local/share/fonts/Rusillaserif-Light.ttf https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/rusilla_serif/Rusillaserif-Light.ttf
sudo curl -o /usr/local/share/fonts/Rusillaserif-Regular.ttf https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/rusilla_serif/Rusillaserif-Regular.ttf
sudo curl -o "/usr/local/share/fonts/SF Pro Display Bold.otf" "https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/SF%20Pro%20Display/SF%20Pro%20Display%20Bold.otf"
sudo curl -o "/usr/local/share/fonts/SF Pro Display Regular.otf" "https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/SF%20Pro%20Display/SF%20Pro%20Display%20Regular.otf"
sudo curl -o /usr/local/share/fonts/StretchPro.otf https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/StretchPro/StretchPro.otf
sudo curl -o "/usr/local/share/fonts/Suisse Int'l Mono.ttf" "https://raw.githubusercontent.com/voltyea/Amethyst/main/fonts/Suisse%20Int'l%20Mono/Suisse%20Int'l%20Mono.ttf"

fc-cache -fv

#rtw89 fixes
sudo curl -o /usr/lib/modprobe.d/70-rtw89.conf https://raw.githubusercontent.com/voltyea/Amethyst/main/70-rtw89.conf

#starting services
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service
systemctl --user enable pipewire pipewire-pulse wireplumber

#regenerating mkinitcpio and the grub config
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

#Changing shell to fish

FISH_PATH=$(command -v fish)
CURRENT_SHELL=$(basename "$SHELL")

if [ "$CURRENT_SHELL" != "fish" ]; then
  chsh -s "$FISH_PATH" $USER
fi

#rebooting the system
while true; do
  read -p "Do you want to reboot the system now? (Y/n): " answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
  if [[ -z "$answer" || "$answer" == "yes" || "$answer" == "y" ]]; then
    echo "Rebooting now..."
    sudo reboot
    break
  elif [[ "$answer" == "no" || "$answer" == "n" ]]; then
    echo "Reboot canceled."
    break
  else
    echo "Invalid input. Please enter yes or no."
  fi
done
