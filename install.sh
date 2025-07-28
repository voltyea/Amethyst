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
sudo chmod +x ./update
sudo cp ./update /usr/bin
update
update
sudo pacman -Syu
xargs -a ./conflict_pkg.lst paru -Syu --needed
xargs -a ./pkg.lst paru -Syu --needed

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
mkdir -p "$HOME/.local/share/amethyst/"
git clone https://github.com/voltyea/dotfiles.git $HOME/.local/share/amethyst/dotfiles/
git -C $HOME/.local/share/amethyst/dotfiles/ pull
rsync -a --exclude-from="$HOME/.local/share/amethyst/dotfiles/.rsyncignore" $HOME/.local/share/amethyst/dotfiles/ $HOME/ &&
  stow -d "$HOME/.local/share/amethyst/dotfiles/" -t $HOME/ . --adopt

#copying wallpapers
git clone https://github.com/voltyea/my_wallpapers.git $HOME/wallpapers/
git -C $HOME/wallpapers/ pull

#installing sddm theme
sudo chmod +x ./sddm.sh
./sddm.sh
cp dotfiles/sddm/user_face_icons/user.face.icon $HOME/.face.icon
#install catppuccin cursor theme
sudo chmod +x ./cursor.sh
./cursor.sh

#remapping keys
sudo chmod +x ./key.sh
./key.sh

#Applying gtk theme
sudo chmod +x ./gtk.sh
./gtk.sh

#installing nessecary fonts
sudo chmod +x ./font.sh
./font.sh

#installing the amethyst-cli script. Usage- just type "amethyst-cli"
sudo chmod +x ./amethyst-cli
sudo cp ./amethyst-cli /usr/bin

#setting default gtk theme
#cp -r ./gtk_theme/gtk-3.0/ $HOME/.config/
#cp ./gtk_theme/.gtkrc-2.0 $HOME/
#cp -r ./gtk_theme/nwg-look/ $HOME/.config/
#cp -r ./gtk_theme/xsettingsd/ $HOME/.config/

#setting electron flags
#cp ./electron_flags/electron-flags.conf $HOME/.config/
#cp ./electron_flags/spotify-flags.conf $HOME/.config/

#hyprpaper
#cp ./hyprpaper/hyprpaper.conf $HOME/.config/hypr/hyprpaper.conf

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
