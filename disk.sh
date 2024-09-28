#!/bin/bash

######################################################################
# MIT License
#
# Copyright (c) 2024 brunets
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
######################################################################

######################################################################
# Script Name  : disk.sh
# Description  : When a new disk is connected, this script mounts the disk permanently and, if the user wants, makes it accessible with samba. The disk is mounted with ntfs file system.
# Author       : brunets
# Created      : 28-09-2024
# Version      : 1.0
######################################################################


if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be executed as root or with sudo permissions."
   exit 1
fi

# ----------------- CREATE DIR --------------------------
dir_disk=$1
if [ $# -ne 1 ]; then
    echo "ERROR: The script must have one argument: ./disk.sh /dev/sda1"
    exit 1
fi
disk=$(echo "$dir_disk" | sed 's|.*/||')

find /srv -type d -name 'sd*' -exec rm -rf {} +

mkdir -p /srv/$disk >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Directory /srv/$disk created successfully."
else
    echo "ERROR: Error while creating the directory /srv/$disk."
    exit 1
fi
# -------------------------------------------------------

# --------------------- MOUNT DISK ----------------------
id=$(lsblk -n -o UUID $1)

mount -U $id /srv/$disk >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Disk mounted on /srv/$disk successfully."
else
    echo "ERROR: Error while mounting the disk on /srv/$disk."
    exit 1
fi

if grep -q "UUID=$id" /etc/fstab; then
    sed -i "\|UUID=$id|c\UUID=$id /srv/$disk ntfs defaults 0 2" /etc/fstab
    echo "The entry with UUID=$id in /etc/fstab has been updated."
else
    echo "UUID=$id /srv/$disk ntfs defaults 0 2" >> /etc/fstab
    echo "The entry with UUID=$id has been added to /etc/fstab."
fi
# -------------------------------------------------------

read -p "Do you want to make the disk accesible through your local network with Samba? (y/n): " use_samba
use_samba=${use_samba,,}

# -------------------- SAMBA ----------------------------
if [ "$use_samba" == "y" ]; then
    echo "Installing Samba..."

    # Comprobar si Samba está instalado
    if ! dpkg -l | grep -q samba; then
        echo "Samba is not installed. It will be installed."
        sudo apt-get install -y samba >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Samba installed succesfully."
        else
            echo "ERROR: Error while installing Samba."
            exit 1
        fi
    else
        echo "Samba is already installed. Proceeding with configuration..."
    fi

    sed -i '/\[sd.*\]/,/^\s*$/d' /etc/samba/smb.conf

    echo -e "[$disk]\n\tcomment = Extern Disk\n\tpath = /srv/$disk\n\tread only = no\n\tbrowsable = yes\n\tguest ok = no" >> /etc/samba/smb.conf

    read -p "Introduce the name of your user for Samba login: " user_smb
    user_smb=${user_smb,,}
    echo "You will need to create a password for the user $user_smb for Samba."
    smbpasswd -a $user_smb
    systemctl restart smbd

    echo "Samba installed and configurated succesfully. The user is $user_smb."
elif [ "$use_samba" == "n" ]; then
    echo "Samba will not be installed."
else
    echo "ERROR: Invalid answer. Please, answer with \"y\" or \"n\"."
fi
# -------------------------------------------------------