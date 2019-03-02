#!/bin/bash

# <UDF name="username" Label="Create New User" example="username" default=""/>
# <UDF name="password" Label="New User Password" default=""/>
# <UDF name="hostname" Label="Change Hostname" example="localhost" default=""/>
# <UDF name="sshkey" Label="Add GPG Public Key" example="AAAAB3NzaC1yc2EAAAADAQABAAACAQCdZBMH9fKg995K" default=""/>
# <UDF name="sysupgrade" Label="System Upgrade?" oneOf="Yes,No" default="No" />
# <UDF name="disableroot" Label="Disable Login with Password & Disable root user Login?" oneOf="Yes,No" default="Yes" />
# <UDF name="timezone" Label="Set Date Time Zone" oneOf="EST, UTC, MST" default="EST" />

echo "    ~~~~ Running Ubuntu18LTS configuration ~~~~"

#Update
sudo apt-get update

# Set date/Time to EST
echo $TIMEZONE | sudo timedatectl set-timezone $TIMEZONE
date


echo $USERNAME
if [ "$USERNAME" != "" ]
then
  echo $USERNAME | adduser --disabled-password --shell /bin/bash --gecos "User" $USERNAME
  echo $USERNAME:$PASSWORD | chpasswd
  sudo adduser $USERNAME sudo

  # SSH Harden
  sudo mkdir -p /home/$USERNAME/.ssh
  sudo chmod -R 700 /home/$USERNAME/.ssh
  sudo chown $USERNAME:$USERNAME /home/$USERNAME/.ssh

  sudo touch /home/$USERNAME/.ssh/authorized_keys

  # GPG Public Key
  sudo echo $SSHKEY >> /home/$USERNAME/.ssh/authorized_keys

  # ADD Aliases
  cd ~
  rm .bash_aliases
  wget https://raw.githubusercontent.com/abalarin/Server_config_scripts/master/.bash_aliases

  cp .bash_aliases /home/$USERNAME
fi

echo $HOSTNAME
# Check if hostname's been provided
if [ "$HOSTNAME" != "" ]
then
  hostnamectl set-hostname $HOSTNAME

  # Add hostname to Hosts
  myip="$(curl ifconfig.me)"
  sudo echo "$myip   $HOSTNAME" >> /etc/hosts

  echo "Host name changed to: " $HOSTNAME
fi

echo $DISABLEROOT
if  [ "$DISABLEROOT" == "Yes" ]
then

  # Make sure a user is provided in order to prevent being locked out
  if [ "$USERNAME" != "" ]
  then
    # Disable root login
    echo "Disabling root login"
    sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

    # If GPG key is provided disable login by password
    if [ "$SSHKEY" != "" ]
    then
      sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    fi

  fi
fi

echo $SYSUPGRADE
if [ "$SYSUPGRADE" == "Yes" ]
then
  sudo apt-get upgrade -y
fi

echo "    ~~~~~~~~ Ubuntu 18 LTS configuration is complete ~~~~~~~~"
sudo reboot
