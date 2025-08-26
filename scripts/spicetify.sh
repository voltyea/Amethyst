#!/bin/bash

while true; do
  read -p "Have you logged-in to Spotify yet? (Y/n): " answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
  if [[ -z "$answer" || "$answer" == "yes" || "$answer" == "y" ]]; then
    echo "Setting up spicetify."
    break
  elif [[ "$answer" == "no" || "$answer" == "n" ]]; then
    echo "Please log-in to Spotify first."
    break
  else
    echo "Invalid input. Please enter yes or no."
  fi
done

sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh

spicetify backup apply

spicetify config sidebar_config 0
spicetify apply
