#!/bin/bash

if [[ "$(whoami)" != "root" ]]; then
  echo "Only user root can run this script."
  exit 1
fi

install_if_needed() {
  if ! dpkg -s "$1" &>/dev/null; then
    sudo apt-get install -y "$1"
  fi
}

install_if_needed boxes
install_if_needed neofetch
install_if_needed docker.io
install_if_needed docker-compose
install_if_needed fail2ban
install_if_needed snort
install_if_needed clamav

while true; do
  # Display the Main Menu
  clear
  neofetch
  echo 'Ｍａｉｎ Ｍｅｎｕ' | boxes -d stone -p a2v1
  echo "
1. Update/Upgrade
2. Install applications
3. Package Cleanup
4. Malware Scanning
5. IDS
6. Exit"
  read -r option1

  case "$option1" in
    1)
      sudo apt update -y
      sudo apt upgrade -y
      sudo msfupdate
      ;;
    2)
      echo " 
1. My-Setup
2. Small Setup / Recommended"
      read -r option
      if [[ $option == 2 ]]; then
        clear
        echo "Hoping you updated because I'm not updating"
        sleep 1
        echo "Installing Parrot OS stuff"
        apps=(
          tilix neofetch sqlmap wireshark openvpn proxychains snapd 
          git terminator gufw tor torbrowser-launcher htop parrot-wallpapers 
          parrot-updater parrot-meta-privacy parrot-themes parrot-menu 
          parrot-interface-home parrot-drivers parrot-displaymanager aptitude 
          parrot-core parrot-archive-keyring anonsurf snapd kitty gufw
        )

        for app in "${apps[@]}"; do
          install_if_needed "$app"
        done

        sudo snap install snap-store discord telegram-desktop
      else
        echo "What is your user?"
        read -r user
        clear
        echo "Hoping you updated because I'm not updating"
        sleep 1
        echo "Installing Parrot OS stuff"
        apps=(
          tilix neofetch sqlmap wireshark openvpn proxychains vscode 
          snapd git terminator gufw tor torbrowser-launcher htop parrot-wallpapers 
          parrot-updater parrot-meta-privacy parrot-themes parrot-menu 
          parrot-interface-home parrot-drivers parrot-displaymanager aptitude 
          parrot-core parrot-archive-keyring anonsurf snapd kitty gufw
        )

        for app in "${apps[@]}"; do
          install_if_needed "$app"
        done

        sudo snap install snap-store fkill fakecam 
        sudo snap install sublime-text --classic

        echo "Installing Mullvad"

        # Create a variable for the user home directory
        user_home=$(eval echo ~$user)

        # Download the Mullvad VPN Debian package
        deb_url="https://mullvad.net/en/download/app/arm-deb/latest"
        deb_file="$user_home/Downloads/mullvad-latest.deb"
        wget -O "$deb_file" "$deb_url"

        # Extract the version number from the Debian package
        version=$(dpkg-deb -f "$deb_file" Version)

        # Install the Debian package
        sudo dpkg -i "$deb_file"

        # Install any missing dependencies
        sudo apt-get install -f

        echo "Mullvad VPN version $version installed"
        sleep 1
        clear

        echo "Installing Mullvad Browser"

        # Download the Mullvad Browser tarball
        browser_url="https://mullvad.net/en/download/browser/linux-x86_64/latest"
        wget --content-disposition "$browser_url" -P "$user_home/Downloads"

        # Navigate to the Downloads directory
        cd "$user_home/Downloads"

        # Extract the downloaded tarball
        tarball=$(ls mullvad-browser-linux-x86_64-*.tar.xz)
        tar -xvf "$tarball"

        # Extract the version number from the tarball name
        browser_version=$(echo "$tarball" | grep -oP '\d+\.\d+\.\d+')

        # Navigate to the Mullvad Browser directory
        cd "$user_home/Downloads/mullvad-browser-linux-x86_64-$browser_version"

        # Start the Mullvad Browser
        ./start-mullvad-browser.desktop

        cp ~/Downloads/mullvad-browser/start-mullvad-browser.desktop ~/.local/share/applications/
      fi
      ;;
    3)
      sudo apt-get autoremove -y
      sudo apt-get clean
      ;;
    4)
      sudo clamscan -r /
      ;;
    5)
      echo "Setting up Intrusion Detection System..."
      echo "1. Configure Snort"
      echo "2. Configure Fail2ban"
      read -r ids_option
      case "$ids_option" in
        1)
          sudo nano /etc/snort/snort.conf
          sudo systemctl restart snort
          ;;
        2)
          sudo nano /etc/fail2ban/jail.conf
          sudo systemctl restart fail2ban
          ;;
        *)
          echo "Invalid option."
          ;;
      esac
      ;;
    6)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option. Please select a valid option from the menu."
      ;;
  esac
done
