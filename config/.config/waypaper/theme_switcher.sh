#!/bin/bash

# Extract the full filename
filename=$(basename "$1")

# Extract the prefix (part before the first dot)
prefix="${filename%%.*}"

# Perform actions based on prefix
case "$prefix" in
Anemo)
  rsync -r $HOME/.local/share/Elements/dotfiles/Anemo/ $HOME/
  sudo mkdir -p /etc/sddm.conf.d/
  sudo rsync $HOME/.local/share/Elements/sddm/Anemo/sddm.conf /etc/sddm.conf.d/
  sudo rsync -r $HOME/.local/share/Elements/sddm/Anemo/Anemo/ /usr/share/sddm/themes/
  ;;

Electro)
  rsync -r $HOME/.local/share/Elements/dotfiles/Electro/ $HOME/
  sudo mkdir -p /etc/sddm.conf.d/
  sudo rsync $HOME/.local/share/Elements/sddm/Electro/sddm.conf /etc/sddm.conf.d/
  sudo rsync -r $HOME/.local/share/Elements/sddm/Electro/Electro/ /usr/share/sddm/themes/
  ;;

Cryo)
  rsync -r $HOME/.local/share/Elements/dotfiles/Cryo/ $HOME/
  sudo mkdir -p /etc/sddm.conf.d/
  sudo rsync $HOME/.local/share/Elements/sddm/Cryo/sddm.conf /etc/sddm.conf.d/
  sudo rsync -r $HOME/.local/share/Elements/sddm/Cryo/Cryo/ /usr/share/sddm/themes/
  ;;

Dendro)
  rsync -r $HOME/.local/share/Elements/dotfiles/Dendro/ $HOME/
  sudo mkdir -p /etc/sddm.conf.d/
  sudo rsync $HOME/.local/share/Elements/sddm/Dendro/sddm.conf /etc/sddm.conf.d/
  sudo rsync -r $HOME/.local/share/Elements/sddm/Dendro/Dendro/ /usr/share/sddm/themes/
  ;;

Hydro)
  rsync -r $HOME/.local/share/Elements/dotfiles/Hydro/ $HOME/
  sudo mkdir -p /etc/sddm.conf.d/
  sudo rsync $HOME/.local/share/Elements/sddm/Hydro/sddm.conf /etc/sddm.conf.d/
  sudo rsync -r $HOME/.local/share/Elements/sddm/Hydro/Hydro/ /usr/share/sddm/themes/
  ;;

Geo)
  rsync -r $HOME/.local/share/Elements/dotfiles/Geo/ $HOME/
  sudo mkdir -p /etc/sddm.conf.d/
  sudo rsync $HOME/.local/share/Elements/sddm/Geo/sddm.conf /etc/sddm.conf.d/
  sudo rsync -r $HOME/.local/share/Elements/sddm/Geo/Geo/ /usr/share/sddm/themes/
  ;;

Pyro)
  rsync -r $HOME/.local/share/Elements/dotfiles/Pyro/ $HOME/
  sudo mkdir -p /etc/sddm.conf.d/
  sudo rsync $HOME/.local/share/Elements/sddm/Pyro/sddm.conf /etc/sddm.conf.d/
  sudo rsync -r $HOME/.local/share/Elements/sddm/Pyro/Pyro/ /usr/share/sddm/themes/
  ;;

*) ;;
esac
