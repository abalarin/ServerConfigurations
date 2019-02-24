#!/bin/bash

# <UDF name="username" Label="Create a new user" example="username" default="austin"/>
# <UDF name="password" Label="New User Password" default="linode!"/>
# <UDF name="hostname" Label="Change Hostname" example="localhost" default=""/>
# <UDF name="sshkey" Label="Add GPG Public Key" example="AAAAB3NzaC1yc2EAAAADAQABAAACAQCdZBMH9fKg995K" default="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdZBMH9fKg995Kt0cbpRGtg2LLNC1HPjVkL8njhonNMX0RsvmNUHBRbFoAPe240F5s4eSC7+Gi5SGx1218eGJl9olZ1hAvCBAiRerKiSSz7Q03vQqpy34fFdZ3rEhqHRD6DLUjH3aCUSXik5a9eMCFgUKhrZMQart21HHnyyNL+Uat2dRh1klZLzd3V6wYN2Nc9ZnD5CblY5XHA4Y4HS6AxCXaJ1I7jUbdkFla77WZhGszYLJ8SXrai5LHfn7BuN4dIhcxfxGQ1t1ig4cd5HKt5Xc65SPlKWinxvpbnhtBocU9GXJnCnYKAXppGWPckzyzisGaycnmRcp0vbnOLsaPK9cmjUWHzqS54079EEuSP342LOXdPAsnNfkUOgP2yFlzjgyvqCl+12zzO5WshvMz4e5L8wU1IZvOf+sdlymE3ulWcNllgDoUOkfmpHFIvlbEFyQlLjT05/hTeIKe1MBw45xDMd5DzLhe14Qzy4lVkSt/WFVYbF1wIuOg8/af2c9kdgVlLgVgJnAppMElPl+uLHqfn/rqfIFNGg8jAL87KxUbUB+f8GnGPqCUrFGnsYagGTdTsNIjzkrOXatOw9K12jXpx9fi+QFz+JPSkEBUSJCmZqqKyUS63jsXrCReaejfd8Je1yoGXYmqMzV3IMcDhJrsYypBFKG8hg98FURSGw== abalarin@Austins-MacBook-Pro.local"/>
# <UDF name="sysupgrade" Label="System Upgrade?" oneOf="Yes, No" default="Yes" />
# <UDF name="disableroot" Label="Disable Login with Password & Disable root Login?" oneOf="Yes, No" default="Yes" />
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
  # Disable root login
  echo "Disabling root login"
  sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
fi

echo $SYSUPGRADE
if [ "$SYSUPGRADE" == "Yes" ]
then
  sudo apt-get upgrade -y
fi

echo "    ~~~~~~~~ Ubuntu 18 LTS configuration is complete ~~~~~~~~"
sudo reboot
