#!/bin/bash

echo "    ~~~~ Running Ubuntu18LTS configuration ~~~~"

#Update
sudo apt-get update

read -p "Would you like to perform sys upgrade? [y/n]" response
if [[ "$response" == "yes" ]] || [[ "$response" == "Yes" ]] || [[ "$response" == "y" ]] || [[ "$response" == "Y" ]]
then
  sudo apt-get upgrade
fi

# Set date/Time to EST
sudo timedatectl set-timezone EST
date

# Create User
printf "Enter a username(return to skip): "
read user

if [ "$user" != "" ]
then
  sudo adduser $user
  sudo adduser $user sudo

  # SSH Harden
  sudo mkdir -p /home/$user/.ssh
  sudo chmod -R 700 /home/$user/.ssh
  sudo chown $user:$user /home/$user/.ssh

  sudo touch /home/$user/.ssh/authorized_keys

  # GPG Public Key
  sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdZBMH9fKg995Kt0cbpRGtg2LLNC1HPjVkL8njhonNMX0RsvmNUHBRbFoAPe240F5s4eSC7+Gi5SGx1218eGJl9olZ1hAvCBAiRerKiSSz7Q03vQqpy34fFdZ3rEhqHRD6DLUjH3aCUSXik5a9eMCFgUKhrZMQart21HHnyyNL+Uat2dRh1klZLzd3V6wYN2Nc9ZnD5CblY5XHA4Y4HS6AxCXaJ1I7jUbdkFla77WZhGszYLJ8SXrai5LHfn7BuN4dIhcxfxGQ1t1ig4cd5HKt5Xc65SPlKWinxvpbnhtBocU9GXJnCnYKAXppGWPckzyzisGaycnmRcp0vbnOLsaPK9cmjUWHzqS54079EEuSP342LOXdPAsnNfkUOgP2yFlzjgyvqCl+12zzO5WshvMz4e5L8wU1IZvOf+sdlymE3ulWcNllgDoUOkfmpHFIvlbEFyQlLjT05/hTeIKe1MBw45xDMd5DzLhe14Qzy4lVkSt/WFVYbF1wIuOg8/af2c9kdgVlLgVgJnAppMElPl+uLHqfn/rqfIFNGg8jAL87KxUbUB+f8GnGPqCUrFGnsYagGTdTsNIjzkrOXatOw9K12jXpx9fi+QFz+JPSkEBUSJCmZqqKyUS63jsXrCReaejfd8Je1yoGXYmqMzV3IMcDhJrsYypBFKG8hg98FURSGw== abalarin@Austins-MacBook-Pro.local" >> /home/$user/.ssh/authorized_keys

  # Disable Password login
  sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

  # Transfer my aliases to new user
  sudo cp ~/.bash_profile /home/$user/.bash_profile
fi

# Set Hostname
printf "Enter a hostname (return to skip): "
read hostname

# Check if hostname's been provided
if [ "$hostname" != "" ]
then
  hostnamectl set-hostname $hostname

  # Add hostname to Hosts
  myip="$(curl ifconfig.me)"
  sudo echo "$myip   $hostname" >> /etc/hosts

  echo "Host name changed to: " $hostname
fi


read -p "Would you like to disable root login and password login (for key/pair auth)[Y/n]?" response

if  [[ "$response" == "yes" ]] || [[ "$response" == "Yes" ]] || [[ "$response" == "y" ]] || [[ "$response" == "Y" ]]
then
  if [ "$user" == "" ]
  then
    echo "    ~~~~~~~~~ Warning!! ~~~~~~~~~"
    echo "No User added if you disable root and password login you may lock yourself out!"
    read -p "Continue? [Y/n]: " response
    if [[ "$response" == "yes" ]] || [[ "$response" == "Yes" ]] || [[ "$response" == "y" ]] || [[ "$response" == "Y" ]]
    then
      # Disable root login
      echo "Disabling root login"
      sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
      sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    fi
  else
    # Disable root login
    echo "Disabling root login"
    sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  fi
fi

echo "    ~~~~~~~~ Ubuntu 18 LTS configuration is complete ~~~~~~~~"

sudo reboot
